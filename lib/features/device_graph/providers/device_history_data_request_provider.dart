import 'dart:async';
import 'dart:typed_data';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_data_type.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/core/services/isar_service.dart';
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

  int numberOfBlankPagesFetched = 0;

  DateTimeRange? requestedDateTimeRange;
  DateTimeRange? pendingDateTimeRange;

  GraphDataDuration? duration;

  BleDevice? bleDevice;

  final List<DeviceData> _dataBuffer = [];
  static final int _batchSize = 400; // Save in batches of 400 records

  static final _unsyncedThresholdDate =
      DateTime.fromMillisecondsSinceEpoch(Constants.syncedTimeThreshold);

  Timer? _flushTimer;

  @override
  build(String arg) {
    bleDevice = ref.read(bleDeviceProvider(deviceId));
    return AsyncNone();
  }

  void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer(const Duration(seconds: 2), () {
      _commitData();
    });
  }

  void request(GraphDataDuration duration) {
    this.duration = duration;
    requestedDateTimeRange = duration.dateTimeRange;

    debugPrint(
        'REQUEST:Requesting historical data for $requestedDateTimeRange');
    numberOfPagesFetched = 0;
    numberOfBlankPagesFetched = 0;
    currentPageNumber = null;

    _requestData();
  }

  void _requestData() {
    debugPrint('REQUEST:Current page number: $currentPageNumber');

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
      debugPrint('REQUEST:No data received');
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
        'REQUEST:Current page number: $currentPageNumber, number of pages fetched: $numberOfPagesFetched');

    _saveData(deviceDataList);

    if (_shouldFetchMoreData(deviceDataList)) {
      _requestData();
    } else {
      handleHistoricalDataFetchComplete();
    }
  }

  void _saveData(List<DeviceData> deviceDataList) {
    // check if the whole data is empty i.e every value is 0
    if (deviceDataList.every((data) => data.value == 0)) {
      debugPrint('REQUEST:All data values are 0, skipping save.');
      return;
    }

    debugPrint(
        'REQUEST:Saving data: ${deviceDataList.map((e) => DeviceDataType.values[e.type].name)}');

    debugPrint('REQUEST:Device data list: $deviceDataList');

    _dataBuffer.addAll(deviceDataList
        .where((data) => data.type != DeviceDataType.empty.index));

    debugPrint('REQUEST:Buffer size: ${_dataBuffer.length}');

    if (_dataBuffer.length >= _batchSize) {
      _commitData();
    } else {
      _startFlushTimer(); // Ensure it gets saved if no more data arrives
    }
  }

  void _commitData() async {
    debugPrint('REQUEST:Committing data: ${_dataBuffer.length}');
    if (_dataBuffer.isEmpty) return;

    try {
      // Write to Isar database one by one to catch any failures
      IsarService().write((isar) async {
        isar.deviceDatas.putAll(_dataBuffer);
      });

      debugPrint("REQUEST:Successfully saved ${_dataBuffer.length} data");
    } catch (e) {
      debugPrint('REQUEST:Database save operation failed: error: $e');
    }

    _dataBuffer.clear();
  }

  bool _shouldFetchMoreData(List<DeviceData> deviceDataList) {
    final DateTime firstDateTime = deviceDataList
        .firstWhere(
          (element) => element.type == DeviceDataType.co2.index,
          orElse: () => deviceDataList.first,
        )
        .dateTime;

    debugPrint(
        'REQUEST:First date time: $firstDateTime, Pending date time range: $pendingDateTimeRange');

    if (pendingDateTimeRange == null) {
      return false;
    }

    debugPrint(
        '''REQUEST:First date time: $firstDateTime, Last date time: ${deviceDataList.last.dateTime}, Pending date time range: $pendingDateTimeRange''');

    // Check if the data is within the requested range
    if (firstDateTime.isAfter(_unsyncedThresholdDate) &&
        firstDateTime.isBefore(pendingDateTimeRange!.start)) {
      return false;
    }

    // if the first date is the date of the empty data, then we don't need to fetch more data
    if (firstDateTime.isAfter(DateTime(2100))) {
      numberOfBlankPagesFetched += 1;
      debugPrint(
          'Blank page detected: Incrementing blank page count to $numberOfBlankPagesFetched');
      if (numberOfBlankPagesFetched > 2) {
        numberOfBlankPagesFetched = 0;
        return false;
      }

      return true;
    }

    if (numberOfPagesFetched >= Constants.maxFlashPageCount) {
      return false;
    }

    numberOfBlankPagesFetched = 0;
    return true;
  }

  void handleHistoricalDataFetchComplete() {
    debugPrint(
        'REQUEST:That was last: Total number of pages fetched: $numberOfPagesFetched');

    // Save any remaining buffered data
    _commitData();

    debugPrint(
        'REQUEST:Device data download provider: ${ref.read(deviceDataDownloadProvider(deviceId))}');

    if (ref.read(deviceDataDownloadProvider(deviceId)) is AsyncInProgress) {
      debugPrint('REQUEST:Setting data downloaded from device');
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
        'REQUEST:Set last fetched date time range: ${bleDevice!.lastFetchedDateTimeRange}');
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
        'REQUEST:Setting pending date time range, Last fetched: ${bleDevice?.lastFetchedDateTimeRange}');

    if (bleDevice?.lastFetchedDateTimeRange == null) {
      debugPrint('REQUEST:No last fetched date time range');
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
          'REQUEST:No need to fetch data; the required range is already covered');
      pendingDateTimeRange = null;
      return;
    }

    // Determine the range(s) to fetch
    DateTime? fetchStart;
    DateTime? fetchEnd;

    debugPrint(
        'REQUEST:Last fetched start: $lastFetchedStartDate, Last fetched end: $lastFetchedEndDate');
    debugPrint('REQUEST:Requested start: $startDate, Requested end: $endDate');

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

    debugPrint('REQUEST:Pending date time range: $pendingDateTimeRange');
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
