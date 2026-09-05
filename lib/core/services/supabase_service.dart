import 'package:airspothealth/core/services/cloud_sync_access.dart';
import 'dart:convert';

import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // Auth
  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithApple() async {
    if (kIsWeb) {
      throw UnimplementedError('signInWithApple is not implemented on web');
    } else {
      // Native iOS Flow
      final rawNonce = _client.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthException(
            'Could not find ID Token from generated credential.');
      }

      final authResponse = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      // Apple only provides the user's full name on the first sign-in
      // Save it to user metadata if available
      if (credential.givenName != null || credential.familyName != null) {
        final nameParts = <String>[];
        if (credential.givenName != null) nameParts.add(credential.givenName!);
        if (credential.familyName != null) {
          nameParts.add(credential.familyName!);
        }

        final fullName = nameParts.join(' ');

        await _client.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': fullName,
              'given_name': credential.givenName,
              'family_name': credential.familyName,
            },
          ),
        );
      }

      return authResponse;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web Flow (redirect)
        await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: '${Uri.base.origin}/auth/callback',
        );
        return;
      }

      // Native Flow (google_sign_in v7+)
      // Supabase needs: idToken + accessToken for Google. :contentReference[oaicite:1]{index=1}
      const scopes = <String>['email', 'profile'];

      final googleSignIn = GoogleSignIn.instance;

      // NOTE:
      // - serverClientId = "Web client ID" from Google Cloud OAuth credentials
      // - clientId (iOS) only needed for iOS (from Google Cloud iOS OAuth client)
      // This matches the v7 initialization style. :contentReference[oaicite:2]{index=2}
      await googleSignIn.initialize(
        serverClientId: Constants.googleClientId, // <-- your WEB client id
        clientId: Constants
            .iosClientId, // <-- your iOS client id (keep if you need iOS)
      );

      // Attempts silent / lightweight auth first; you can replace with `authenticate()` if you prefer.
      final googleUser =
          await googleSignIn.attemptLightweightAuthentication() ??
              await googleSignIn.authenticate();

      // Get ID token
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw const AuthException('No ID Token found.');
      }

      // Get Access Token (v7+ requires scopes authorization to obtain it)
      final authorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes) ??
              await googleUser.authorizationClient.authorizeScopes(scopes);

      final accessToken = authorization.accessToken;
      if (accessToken.isEmpty) {
        throw const AuthException('No Access Token found.');
      }

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      // keep your logging style
      // ignore: avoid_print
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Device Ownership
  Future<void> claimDevice(
    String deviceId, {
    String? deviceName,
    String? deviceAlias,
  }) async {
    CloudSyncAccess.requireEnabled();
    final user = currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final record = <String, dynamic>{
        'user_id': user.id,
        'device_id': deviceId,
        'claimed_at': DateTime.now().toUtc().toIso8601String(),
      };

      // Only include name/alias fields if they have values
      if (deviceName != null && deviceName.isNotEmpty) {
        record['device_name'] = deviceName;
      }
      if (deviceAlias != null && deviceAlias.isNotEmpty) {
        record['device_alias'] = deviceAlias;
      }

      await _client.from('user_devices').upsert(
            record,
            onConflict: 'device_id',
          );

      // Also sync the friendly name to the devices table (for dashboard)
      final friendlyName = (deviceAlias?.isNotEmpty == true)
          ? deviceAlias
          : (deviceName?.isNotEmpty == true)
              ? deviceName
              : deviceId;
      await _client
          .from('devices')
          .update({'name': friendlyName}).eq('device_id', deviceId);

      debugPrint(
          'Device claimed/updated: $deviceId (name: $deviceName, alias: $deviceAlias)');
    } catch (e) {
      debugPrint('Error claiming device: $e');
    }
  }

  // Data Sync
  Future<void> uploadReadings(List<DeviceData> readings,
      {String? targetDeviceId}) async {
    CloudSyncAccess.requireEnabled();
    final user = currentUser;
    if (user == null) return;

    if (readings.isEmpty) return;

    // Deduplicate readings based on (device_id, timestamp, type)
    // Use a Map to keep only the last occurrence of each unique key
    final Map<String, Map<String, dynamic>> uniqueRecords = {};

    for (var r in readings) {
      final deviceId = targetDeviceId ?? r.deviceId;
      // IMPORTANT: Always convert to UTC before sending to Supabase.
      // Dart's toIso8601String() on local DateTimes omits timezone info,
      // and Supabase would interpret it as UTC, causing offset errors.
      final timestamp = r.dateTime.toUtc().toIso8601String();
      final type = r.type;
      final key = '$deviceId-$timestamp-$type';

      uniqueRecords[key] = {
        'device_id': deviceId,
        'timestamp': timestamp,
        'value': r.value,
        'type': type,
        'user_id': user.id, // RLS will also enforce this
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };
    }

    final List<Map<String, dynamic>> records = uniqueRecords.values.toList();

    try {
      // Upsert based on (device_id, timestamp, type)
      await _client.from('readings').upsert(
            records,
            onConflict: 'device_id, timestamp, type',
            ignoreDuplicates: true,
          );
    } catch (e) {
      debugPrint('Error uploading readings: $e');
      rethrow;
    }
  }

  Future<List<DeviceData>> fetchReadings(
      String deviceId, DateTime since) async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('readings')
          .select()
          .eq('device_id', deviceId)
          .gt('timestamp', since.toIso8601String())
          .order('timestamp', ascending: true);

      return (response as List).map((json) {
        return DeviceData(
          deviceId: json['device_id'],
          dateTime: DateTime.parse(json['timestamp']),
          value: json['value'],
          type: json['type'],
          // synced: true, // Will be marked as synced when saved
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching readings: $e');
      return [];
    }
  }

  Future<DateTime?> getLastSyncedDate(String deviceId) async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('readings')
          .select('timestamp')
          .eq('device_id', deviceId)
          .order('timestamp', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return DateTime.parse(response['timestamp']);
    } catch (e) {
      debugPrint('Error fetching last synced date: $e');
      return null;
    }
  }
}
