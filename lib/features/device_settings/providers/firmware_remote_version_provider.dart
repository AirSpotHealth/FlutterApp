import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/services/network_service.dart';
import 'package:airspothealth/core/utils/api_endpoints.dart';
import 'package:airspothealth/features/device_settings/models/remote_version.dart';
import 'package:airspothealth/features/device_settings/service/hosted_firmware.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Scoped by deviceId and rebuilt when service discovery corrects its model.
final firmwareRemoteVersionProvider = AsyncNotifierProvider.autoDispose
    .family<_FirmwareRemoteVersionNotifier, RemoteVersion?, String>(
  _FirmwareRemoteVersionNotifier.new,
);

class _FirmwareRemoteVersionNotifier
    extends AutoDisposeFamilyAsyncNotifier<RemoteVersion?, String> {
  @override
  Future<RemoteVersion?> build(String deviceId) async {
    final model = ref.watch(bleSavedDevicesProvider.select((devices) {
      for (final device in devices) {
        if (device.deviceId == deviceId) return device.deviceModel ?? DeviceModel.unknown;
      }
      return DeviceModel.unknown;
    }));
    final appVersion = (await PackageInfo.fromPlatform()).version;
    try {
      final result = await NetworkService.instance.get(
        HostedFirmware.checkUrl(ApiEndpoints.versionCheck, model, appVersion),
        {},
      );
      return result.statusCode == 200
          ? HostedFirmware.parseResponse(result.data, model)
          : null;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      throw StateError('Failed to fetch remote version: '
          '${error.response?.statusCode ?? 'Network unavailable'}');
    }
  }

  Future<void> fetchRemoteVersion() async {
    ref.invalidateSelf();
    // Errors are exposed by AsyncValue; button/pull-to-refresh callbacks need not throw.
    try {
      await future;
    } catch (_) {
      // The widget renders the provider's error state.
    }
  }
}
