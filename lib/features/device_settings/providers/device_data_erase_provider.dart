import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceDataEraseProvider = NotifierProvider.family<
    _DeviceDataEraseNotifier,
    AsyncProgressValue,
    String>(_DeviceDataEraseNotifier.new);

class _DeviceDataEraseNotifier
    extends FamilyNotifier<AsyncProgressValue, String> {
  String get deviceId => arg;

  @override
  AsyncProgressValue build(String arg) {
    return AsyncNone();
  }

  Future<void> eraseDeviceData() async {
    state = AsyncInProgress(0.0, message: 'Erasing device data....');

    if (!ref.read(bleDeviceConnectionProvider(deviceId).notifier).isConnected) {
      state = AsyncFailure('Device is not connected');
      return;
    }

    ref
        .read(bleDeviceCommunicationProvider(deviceId).notifier)
        .sendCommand(DeviceCmdUtils.eraseData())
        .then((_) {})
        .catchError((error) {
      state = AsyncFailure(error.toString());

      // wait for 1 minutes so that data can be erased
      // if the state is not updated to success, then show failure
      Future.delayed(const Duration(minutes: 1), () {
        if (state is AsyncInProgress) {
          state = AsyncFailure('Failed to erase device data: Timeout');
        }
      });
    });
  }

  void setProgress(double progress) {
    state = AsyncInProgress(progress, message: 'Erasing device data....');
  }

  void setSuccess() {
    state = AsyncSuccess(true);
  }
}
