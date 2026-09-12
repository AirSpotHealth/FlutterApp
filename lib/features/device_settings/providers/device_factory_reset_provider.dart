import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/services/ble_communicator_service.dart';
import 'package:airspothealth/features/device_settings/service/slim_factory_reset.dart';
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
    if (state is AsyncInProgress) return;
    state = AsyncInProgress(0.0, message: 'Resetting device....');

    if (!ref.read(bleDeviceConnectionProvider(deviceId).notifier).isConnected) {
      state = AsyncFailure('Device is not connected');
      return;
    }

    try {
      final communicator =
          BleCommunicatorService.instance.communicator(deviceId);
      final model = ref
          .read(bleSavedDevicesProvider.notifier)
          .getDeviceById(deviceId)
          ?.deviceModel;
      if (communicator.isSlimDevice || model == DeviceModel.airspotSlim) {
        await SlimFactoryReset.run(
          responses: communicator.dataStream,
          send: () => communicator.sendCommand(DeviceCmdUtils.factoryReset()),
        );
      } else {
        // Screen retains its existing write-completion reset flow.
        await ref
            .read(bleDeviceCommunicationProvider(deviceId).notifier)
            .sendCommand(DeviceCmdUtils.factoryReset());
      }
      ref.read(bleSavedDevicesProvider.notifier).resetDeviceFetchTime(deviceId);
      ref.read(isarServiceProvider).write((isar) {
        isar.deviceSettings.where().deviceIdEqualTo(deviceId).deleteAll();
        isar.deviceDatas.where().deviceIdEqualTo(deviceId).deleteAll();
      });
      state = AsyncSuccess(true);
    } catch (error) {
      state = AsyncFailure(error.toString());
    }
  }

  void setProgress(double progress) {
    state = AsyncInProgress(progress, message: 'Resetting device....');
  }
}
