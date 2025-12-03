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
        // Web Flow
        await _client.auth.signInWithOAuth(
          OAuthProvider.google,
        );
      } else {
        // Native Flow
        // 1. Google Sign In
        final GoogleSignIn googleSignIn = GoogleSignIn(
          clientId: Constants.iosClientId,
          serverClientId: Constants.googleClientId,
        );

        final googleUser = await googleSignIn.signIn();
        final googleAuth = await googleUser?.authentication;
        final accessToken = googleAuth?.accessToken;
        final idToken = googleAuth?.idToken;

        if (accessToken == null) {
          throw 'No Access Token found.';
        }
        if (idToken == null) {
          throw 'No ID Token found.';
        }

        // 2. Supabase Sign In
        await _client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Device Ownership
  Future<void> claimDevice(String deviceId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      await _client.from('user_devices').insert({
        'user_id': user.id,
        'device_id': deviceId,
        'claimed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Handle unique constraint violation (device already claimed)
      // Postgres error code 23505 is unique_violation
      if (e.toString().contains('23505')) {
        debugPrint('Device already claimed: $deviceId');
        return;
      }
      debugPrint('Error claiming device: $e');
      // If it's not a duplicate error, we might want to rethrow or handle it
      // For now, let's log and continue, assuming it might be a permission issue or similar
      // that shouldn't block the flow if the device is already there.
    }
  }

  // Data Sync
  Future<void> uploadReadings(List<DeviceData> readings,
      {String? targetDeviceId}) async {
    final user = currentUser;
    if (user == null) return;

    if (readings.isEmpty) return;

    // Deduplicate readings based on (device_id, timestamp, type)
    // Use a Map to keep only the last occurrence of each unique key
    final Map<String, Map<String, dynamic>> uniqueRecords = {};

    for (var r in readings) {
      final deviceId = targetDeviceId ?? r.deviceId;
      final timestamp = r.dateTime.toIso8601String();
      final type = r.type;
      final key = '$deviceId-$timestamp-$type';

      uniqueRecords[key] = {
        'device_id': deviceId,
        'timestamp': timestamp,
        'value': r.value,
        'type': type,
        'user_id': user.id, // RLS will also enforce this
        'created_at': DateTime.now().toIso8601String(),
      };
    }

    final List<Map<String, dynamic>> records = uniqueRecords.values.toList();

    try {
      // Upsert based on (device_id, timestamp, type)
      await _client.from('readings').upsert(
            records,
            onConflict: 'device_id, timestamp, type',
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
