import 'dart:typed_data';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
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
  int numberOfPagesFetched = 0;

  DateTimeRange? requestedDateTimeRange;
  DateTimeRange? pendingDateTimeRange;

  GraphDataDuration? duration;

  BleDevice? bleDevice;

  static final _unsyncedThresholdDate =
      DateTime.fromMillisecondsSinceEpoch(Constants.syncedTimeThreshold);

  @override
  build(String arg) {
    bleDevice = ref.read(bleDeviceProvider(deviceId));
    return AsyncNone();
  }

  void request(GraphDataDuration duration) {
    this.duration = duration;
    requestedDateTimeRange = duration.getDateTimeRange(isTonightEnd: false);

    debugPrint('Requesting historical data for $requestedDateTimeRange');
    numberOfPagesFetched = 0;
    currentPageNumber = null;

    _requestData();
  }

  void _requestData() {
    debugPrint('Current page number: $currentPageNumber');

    if (currentPageNumber == null) {
      _sendCommand(DeviceCmdUtils.getCurrentFlashPage(),
          "Getting the last recorded data");
    } else {
      _setPendingDateTimeRange();
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
      debugPrint('No data received');
      handleHistoricalDataFetchComplete();
      return;
    }

    if (requestedDateTimeRange == null) {
      throw Exception('Date range is null');
    }

    final List<DeviceData> deviceDataList = data as List<DeviceData>;

    numberOfPagesFetched++;
    currentPageNumber = (currentPageNumber ?? 0) - 1;

    if (currentPageNumber! < 0) {
      currentPageNumber = Constants.maxFlashPageCount - 1;
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

    if (pendingDateTimeRange == null) {
      return false;
    }

    debugPrint(
        'First date time: $firstDateTime, Pending date time range: $pendingDateTimeRange');

    // Check if the data is within the requested range
    if (firstDateTime.isAfter(_unsyncedThresholdDate) &&
        firstDateTime.isBefore(pendingDateTimeRange!.start)) {
      return false;
    }

    // if the first date is ahead of the pending date range end then stop fetching
    if (firstDateTime.isAfter(pendingDateTimeRange!.end)) {
      return false;
    }

    if (numberOfPagesFetched >= Constants.maxFlashPageCount) {
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

    requestedDateTimeRange = null;
    duration = null;
    currentPageNumber = null;
    numberOfPagesFetched = 0;
    state = AsyncSuccess(null);
  }

  void _saveLastFetchedDateTimeRange() {
    if (bleDevice == null) {
      return;
    }

    final DateTimeRange fetchedDateTimeRange = _calculateFetchedDateTimeRange();

    bleDevice = bleDevice!.copyWith(
      lastFetchedStartDate: fetchedDateTimeRange.start,
      lastFetchedEndDate: fetchedDateTimeRange.end,
    );

    ref.read(isarServiceProvider).write((isar) {
      isar.bleDevices.put(bleDevice!);
    });

    debugPrint(
        'Last fetched date time range: ${bleDevice!.lastFetchedDateTimeRange}');
  }

  DateTimeRange _calculateFetchedDateTimeRange() {
    if (bleDevice?.lastFetchedDateTimeRange == null) {
      return requestedDateTimeRange!;
    }

    final DateTime start =
        requestedDateTimeRange!.start.isBefore(bleDevice!.lastFetchedStartDate!)
            ? requestedDateTimeRange!.start
            : bleDevice!.lastFetchedStartDate!;
    final DateTime end =
        requestedDateTimeRange!.end.isAfter(bleDevice!.lastFetchedEndDate!)
            ? requestedDateTimeRange!.end
            : bleDevice!.lastFetchedEndDate!;

    return DateTimeRange(start: start, end: end);
  }

  void _setPendingDateTimeRange() {
    debugPrint(
        'Setting pending date time range, Last fetched: ${bleDevice?.lastFetchedDateTimeRange}');

    if (bleDevice?.lastFetchedDateTimeRange == null) {
      debugPrint('No last fetched date time range');
      pendingDateTimeRange = requestedDateTimeRange;
      return;
    }

    final DateTime lastFetchedStartDate = bleDevice!.lastFetchedStartDate!;
    final DateTime lastFetchedEndDate = bleDevice!.lastFetchedEndDate!;

    final DateTime startDate = requestedDateTimeRange!.start;
    final DateTime endDate = requestedDateTimeRange!.end;

    // Condition 1: Check if the lastFetched range fully includes the requested range
    if (lastFetchedStartDate.isBeforeOrEqual(startDate) &&
        lastFetchedEndDate.isAfterOrEqual(endDate)) {
      // No need to fetch data; the required range is already covered
      debugPrint(
          'No need to fetch data; the required range is already covered');
      return;
    }

    // Determine the range(s) to fetch
    DateTime? fetchStart;
    DateTime? fetchEnd;

    debugPrint(
        'Last fetched start: $lastFetchedStartDate, Last fetched end: $lastFetchedEndDate');
    debugPrint('Requested start: $startDate, Requested end: $endDate');

    if (startDate.isAfterOrEqual(lastFetchedEndDate)) {
      // Condition 2: Requested range is after the last fetched range
      fetchStart = startDate;
      fetchEnd = endDate;
    } else if (endDate.isBeforeOrEqual(lastFetchedStartDate)) {
      // Condition 3: Requested range is before the last fetched range
      fetchStart = startDate;
      fetchEnd = endDate;
    } else {
      // Condition 4: Requested range overlaps with the last fetched range
      if (startDate.isBefore(lastFetchedStartDate)) {
        fetchStart = startDate;
        fetchEnd = lastFetchedStartDate.subtract(const Duration(seconds: 1));
      } else if (endDate.isAfter(lastFetchedEndDate)) {
        fetchStart = lastFetchedEndDate.add(const Duration(seconds: 1));
        fetchEnd = endDate;
      }
    }

    if (fetchStart != null && fetchEnd != null) {
      pendingDateTimeRange = DateTimeRange(start: fetchStart, end: fetchEnd);
    }

    debugPrint('Pending date time range: $pendingDateTimeRange');
  }

  void clear() {
    state = AsyncNone();

    currentPageNumber = null;
    numberOfPagesFetched = 0;
    requestedDateTimeRange = null;
    pendingDateTimeRange = null;
    duration = null;
  }
}
