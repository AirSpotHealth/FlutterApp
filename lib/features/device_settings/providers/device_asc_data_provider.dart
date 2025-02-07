import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_settings/models/asc_data.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceASCDataProvider = NotifierProvider.family
    .autoDispose<_DeviceASCDataNotifierNotifier, AsyncProgressValue, String>(
        _DeviceASCDataNotifierNotifier.new);

class _DeviceASCDataNotifierNotifier
    extends AutoDisposeFamilyNotifier<AsyncProgressValue, String> {
  @override
  AsyncProgressValue build(String arg) {
    return AsyncNone();
  }

  void request() {
    state = AsyncInProgress(0, message: "Requesting ASC data....");
    ref
        .read(bleDeviceCommunicationProvider(arg).notifier)
        .sendCommand(DeviceCmdUtils.getAscData());

    // after 5 seconds, reset the state
    Future.delayed(const Duration(seconds: 5), () {
      if (state is AsyncInProgress) {
        state = AsyncFailure("Failed to get ASC data: Timeout");
      }
    });
  }

  void setAscData(AscData data) {
    state = AsyncSuccess(data);
  }

  void cancelRequest() {
    if (state is AsyncInProgress) {
      state = AsyncNone();
    }
  }
}
