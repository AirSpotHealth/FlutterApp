import 'dart:typed_data';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/device_data_download_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceHistoryDataRequestProvider = NotifierProvider.family<
    _DeviceHistoryDataRequestNotifier,
    AsyncProgressValue,
    String>(_DeviceHistoryDataRequestNotifier.new);

class _DeviceHistoryDataRequestNotifier
    extends FamilyNotifier<AsyncProgressValue, String> {
  String get deviceId => arg;

  int? currentPageNumber;
  int get maxFlashPageCount => Constants.maxFlashPageCount;
  int numberOfPagesFetched = 0;

  DateTimeRange? dateTimeRange;
  GraphDataDuration? duration;

  BleDevice? bleDevice;

  static final _unsyncedThresholdDate =
      DateTime.fromMillisecondsSinceEpoch(Constants.syncedTimeThreshold * 1000);

  @override
  build(String arg) {
    bleDevice = ref.read(bleDeviceProvider(deviceId));
    return AsyncNone();
  }

  void request(GraphDataDuration duration) {
    this.duration = duration;
    dateTimeRange = duration.getDateTimeRange();

    debugPrint('Requesting historical data for $dateTimeRange');

    _requestData();
  }

  void _requestData() {
    debugPrint('Current page number: $currentPageNumber');

    if (currentPageNumber == null) {
      _sendCommand(DeviceCmdUtils.getCurrentFlashPage(),
          "Getting the last recorded data");
    } else {
      _sendCommand(DeviceCmdUtils.getCo2History(currentPageNumber!),
          "Getting historical data for page $currentPageNumber");
    }
  }

  void _sendCommand(Uint8List command, String message) {
    ref
        .read(bleDeviceCommunicationProvider(deviceId).notifier)
        .sendCommand(command);
    state = AsyncInProgress(0.1, message: message);
  }

  void handleHistoricalDataResponse(dynamic data) {
    if (data is int) {
      currentPageNumber = data;
      _requestData();
      return;
    }

    if (data is List && data.isEmpty) {
      handleHistoricalDataFetchComplete();
      return;
    }

    if (dateTimeRange == null) {
      throw Exception('Date range is null');
    }

    final List<DeviceData> deviceDataList = data as List<DeviceData>;

    numberOfPagesFetched++;
    currentPageNumber = (currentPageNumber ?? 0) - 1;

    if (currentPageNumber! < 0) {
      currentPageNumber = maxFlashPageCount - 1;
    }

    debugPrint(
        'Current page number: $currentPageNumber, number of pages fetched: $numberOfPagesFetched');

    _saveData(deviceDataList);

    if (_shouldFetchMoreData(deviceDataList)) {
      _requestData();
    } else {
      handleHistoricalDataFetchComplete();
    }
  }

  void _saveData(List<DeviceData> deviceDataList) {
    ref.read(isarServiceProvider).write((isar) {
      isar.deviceDatas.putAll(deviceDataList);
    });
  }

  bool _shouldFetchMoreData(List<DeviceData> deviceDataList) {
    final DateTime firstDateTime = deviceDataList.first.dateTime;

    if (firstDateTime.isAfter(_unsyncedThresholdDate) &&
        firstDateTime.isBefore(dateTimeRange!.start)) {
      return false;
    }

    if (numberOfPagesFetched >= maxFlashPageCount) {
      return false;
    }

    return true;
  }

  void handleHistoricalDataFetchComplete() {
    debugPrint(
        'That was last: Total number of pages fetched: $numberOfPagesFetched');

    if (duration == GraphDataDuration.last7Days) {
      ref
          .read(deviceDataDownloadProvider(deviceId).notifier)
          .setDataDownloadedFromDevice();
    }

    _saveLastFetchedDateTimeRange();

    dateTimeRange = null;
    duration = null;
    currentPageNumber = null;
    state = AsyncSuccess(null);
  }

  void _saveLastFetchedDateTimeRange() {
    if (bleDevice == null) {
      return;
    }

    final DateTimeRange fetchedDateTimeRange = _calculateFetchedDateTimeRange();

    ref.read(isarServiceProvider).write((isar) {
      isar.bleDevices.put(bleDevice!.copyWith(
        lastFetchedStartDate: fetchedDateTimeRange.start,
        lastFetchedEndDate: fetchedDateTimeRange.end,
      ));
    });

    debugPrint('Last fetched date time range: $fetchedDateTimeRange');
  }

  DateTimeRange _calculateFetchedDateTimeRange() {
    if (bleDevice?.lastFetchedDateTimeRange == null) {
      return dateTimeRange!;
    }

    final DateTime start =
        dateTimeRange!.start.isBefore(bleDevice!.lastFetchedStartDate!)
            ? dateTimeRange!.start
            : bleDevice!.lastFetchedStartDate!;
    final DateTime end =
        dateTimeRange!.end.isAfter(bleDevice!.lastFetchedEndDate!)
            ? dateTimeRange!.end
            : bleDevice!.lastFetchedEndDate!;

    return DateTimeRange(start: start, end: end);
  }
}
