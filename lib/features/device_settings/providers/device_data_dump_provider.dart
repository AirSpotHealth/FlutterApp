import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/service/data_dump_builder.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceDataDumpProvider = NotifierProvider.family<_DeviceDataDumpNotifier,
    AsyncProgressValue, String>(_DeviceDataDumpNotifier.new);

class _DeviceDataDumpNotifier
    extends FamilyNotifier<AsyncProgressValue, String> {
  String get deviceId => arg;

  late DataDumpBuilder _dataDumpBuilder;

  int currentPageNumber = 0;

  int expectedPageCount = 16383;
  // static const expectedPageCount = 100;

  @override
  AsyncProgressValue build(String arg) {
    _dataDumpBuilder = DataDumpBuilder(arg);
    currentPageNumber = 0;
    return AsyncNone();
  }

  void startDataDump({int? numberOfPages}) {
    expectedPageCount = numberOfPages ?? 16383;

    state = const AsyncInProgress(0, message: 'Dumping data...');
    _dataDumpBuilder.createFile();

    _getData();
  }

  void _getData() {
    ref
        .read(bleDeviceCommunicationProvider(deviceId).notifier)
        .sendCommand(DeviceCmdUtils.getCo2History(currentPageNumber));

    state = AsyncInProgress(
      currentPageNumber / expectedPageCount,
      message: 'Dumping data for page $currentPageNumber',
    );

    currentPageNumber += 1;
  }

  void updateData(String data) {
    _dataDumpBuilder.writeData(
        "${currentPageNumber.isEven ? 'PAGE $currentPageNumber :' : ''}$data",
        newLine: currentPageNumber.isEven);

    debugPrint('Data Dumped for page $currentPageNumber');

    if (currentPageNumber >= expectedPageCount) {
      ref
          .read(bleDeviceCommunicationProvider(deviceId).notifier)
          .sendCommand(DeviceCmdUtils.getMemoryDump());

      state = const AsyncInProgress(0.9, message: 'Fetching memory dump...');
    } else {
      _getData();
    }
  }

  void addMemoryDump(String data) {
    _dataDumpBuilder.writeData("MEMORY DUMP : $data");

    // finish the data dump
    finishDataDump();
  }

  void finishDataDump() async {
    state = const AsyncInProgress(1, message: 'Data dumped successfully');
    _dataDumpBuilder.build();

    currentPageNumber = 0;

    // show a download dialog
    await FileSaver.instance.saveAs(
      name: _dataDumpBuilder.fileName,
      bytes: await _dataDumpBuilder.file!.readAsBytes(),
      mimeType: MimeType.text,
      ext: 'txt',
    );

    // reset the builder
    _dataDumpBuilder = DataDumpBuilder(deviceId);

    state = const AsyncSuccess(true);
  }
}
