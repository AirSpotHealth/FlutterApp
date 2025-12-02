import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';

final deviceFactoryResetProvider = NotifierProvider.family<
    _DeviceFactoryResetNotifier,
    AsyncProgressValue,
    String>(_DeviceFactoryResetNotifier.new);

class _DeviceFactoryResetNotifier
    extends FamilyNotifier<AsyncProgressValue, String> {
  String get deviceId => arg;

  @override
  AsyncProgressValue build(String arg) {
    return AsyncNone();
  }

  Future<void> factoryResetDevice() async {
    state = AsyncInProgress(0.0, message: 'Resetting device....');

    if (!ref.read(bleDeviceConnectionProvider(deviceId).notifier).isConnected) {
      state = AsyncFailure('Device is not connected');
      return;
    }

    ref
        .read(bleDeviceCommunicationProvider(deviceId).notifier)
        .sendCommand(DeviceCmdUtils.factoryReset())
        .then((_) {
      ref.read(bleSavedDevicesProvider.notifier).resetDeviceFetchTime(deviceId);
      ref.read(isarServiceProvider).write((isar) {
        isar.deviceSettings.where().deviceIdEqualTo(deviceId).deleteAll();
        isar.deviceDatas.where().deviceIdEqualTo(deviceId).deleteAll();
      });

      state = AsyncSuccess(true);
    }).catchError((error) {
      state = AsyncFailure(error.toString());

      // wait for 1 minutes so that data can be erased
      // if the state is not updated to success, then show failure
      Future.delayed(const Duration(minutes: 1), () {
        if (state is AsyncInProgress) {
          state = AsyncFailure('Failed to reset device: Timeout');
        }
      });
    });
  }

  void setProgress(double progress) {
    state = AsyncInProgress(progress, message: 'Resetting device....');
  }
}
