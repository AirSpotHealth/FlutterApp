import 'dart:async';

import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/services/network_service.dart';
import 'package:airspothealth/core/utils/api_endpoints.dart';
import 'package:airspothealth/features/device_settings/models/remote_version.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Scoped by deviceId so each device fetches firmware appropriate to its model.
final firmwareRemoteVersionProvider = AsyncNotifierProvider.autoDispose
    .family<_FirmwareRemoteVersionNotifier, RemoteVersion?, String>(
  _FirmwareRemoteVersionNotifier.new,
);

class _FirmwareRemoteVersionNotifier
    extends AutoDisposeFamilyAsyncNotifier<RemoteVersion?, String> {
  final NetworkService _networkService = NetworkService.instance;

  @override
  FutureOr<RemoteVersion?> build(String deviceId) {
    fetchRemoteVersion();
    return future;
  }

  Future<void> fetchRemoteVersion() async {
    state = const AsyncLoading();

    try {
      final deviceId = arg;
      final device =
          ref.read(bleSavedDevicesProvider.notifier).getDeviceById(deviceId);
      // Slim OTA disabled — skip server check (avoids "update available" noise).
      if (device?.deviceModel == DeviceModel.airspotSlim) {
        state = const AsyncData(null);
        return;
      }
      final deviceModel = 'screen';

      String? currentVersion = (await PackageInfo.fromPlatform()).version;

      final bool beta = () {
        final parts = currentVersion.split('.');
        return parts.isNotEmpty && parts.last != '0';
      }();

      debugPrint('Fetching firmware: device_model=$deviceModel beta=$beta');

      final Response<dynamic> result = await _networkService.get(
        '${ApiEndpoints.versionCheck}'
        '?beta=$beta'
        '&app_version=$currentVersion'
        '&device_model=$deviceModel',
        {},
      );

      if (result.statusCode == 200) {
        state = AsyncData(RemoteVersion.fromJson(result.data as Map<String, dynamic>));
      } else {
        state = const AsyncData(null);
      }
    } on DioException catch (e) {
      // 404 means no firmware exists for this device model — not an error worth surfacing.
      if (e.response?.statusCode == 404) {
        state = const AsyncData(null);
      } else {
        state = AsyncError(
          'Failed to fetch remote version\n'
          '${e.response?.data?['error'] ?? e.response?.statusCode}',
          StackTrace.current,
        );
      }
    }
  }
}
