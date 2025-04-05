import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final populateFakeDataProvider = NotifierProvider.family<
    _PopulateFakeDataNotifier,
    AsyncProgressValue,
    String>(_PopulateFakeDataNotifier.new);

class _PopulateFakeDataNotifier
    extends FamilyNotifier<AsyncProgressValue, String> {
  @override
  AsyncProgressValue build(String arg) {
    return AsyncNone();
  }

  void populateFakeData() {
    state = AsyncInProgress(0.0, message: "Populating fake data...");

    ref
        .read(bleDeviceCommunicationProvider(arg).notifier)
        .sendCommand(DeviceCmdUtils.populateFakeData());
  }

  void populateFakeDataComplete() {
    state = AsyncSuccess(null);
  }
}
