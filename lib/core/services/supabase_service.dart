import 'dart:convert';

import 'package:airspothealth/core/models/device_data.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
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
    // For native Google Sign In on Android/iOS, we use the standard OAuth flow
    // which opens a browser/modal.
    // Ensure you have configured the redirect URL in Supabase and the deep link in your app.
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'airspothealth://login-callback',
    );
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
      debugPrint('Error claiming device: $e');
      rethrow;
    }
  }

  // Data Sync
  Future<void> uploadReadings(List<DeviceData> readings) async {
    final user = currentUser;
    if (user == null) return;

    if (readings.isEmpty) return;

    final List<Map<String, dynamic>> records = readings.map((r) {
      return {
        'device_id': r.deviceId,
        'timestamp': r.dateTime.toIso8601String(),
        'value': r.value,
        'type': r.type,
        'user_id': user.id, // RLS will also enforce this
        'created_at': DateTime.now().toIso8601String(),
      };
    }).toList();

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
}
