import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:airspothealth/core/services/ble_communicator_service.dart';
import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/models/history_coverage.dart';
import 'package:airspothealth/core/services/history_coverage_service.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_data_type.dart';
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

// Injectable transport keeps the history state machine testable without BLE.
final historyCommandSenderProvider =
    Provider.family<Future<bool> Function(Uint8List), String>((ref, deviceId) =>
        (command) => ref
            .read(bleDeviceCommunicationProvider(deviceId).notifier)
            .sendCommand(command));

final deviceHistoryDataRequestProvider = NotifierProvider.family<
    _DeviceHistoryDataRequestNotifier,
    AsyncProgressValue,
    String>(_DeviceHistoryDataRequestNotifier.new);

class _DeviceHistoryDataRequestNotifier
    extends FamilyNotifier<AsyncProgressValue, String> {
  String get deviceId => arg;

  int? currentPageNumber;
  int? _startPageNumber;
  bool _hasWrappedAround = false;
  int numberOfPagesFetched = 0;

  int numberOfBlankPagesFetched = 0;

  DateTimeRange? requestedDateTimeRange;
  DateTimeRange? pendingDateTimeRange;

  GraphDataDuration? duration;

  BleDevice? bleDevice;

  bool get _isSlim => bleDevice?.deviceModel == DeviceModel.airspotSlim;
  final Queue<HistoryCoverage> _missingIntervals = Queue();
  HistoryCoverage? _activeInterval;
  bool _reachedIntervalStart = false;
  int _requestGeneration = 0;

  final List<DeviceData> _dataBuffer = [];
  static final int _batchSize = 400; // Save in batches of 400 records

  static final _unsyncedThresholdDate =
      DateTime.fromMillisecondsSinceEpoch(Constants.syncedTimeThreshold);

  bool _pausedForUpdate = false;
  Timer? _flushTimer;
  Timer? _timeoutTimer;
  static const _requestTimeout = Duration(seconds: 30);

  @override
  build(String arg) {
    ref.onDispose(() {
      _flushTimer?.cancel();
      _timeoutTimer?.cancel();
      _requestGeneration++;
    });
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
    if (_isSlim) {
      _requestGeneration++;
      _timeoutTimer?.cancel();
      _flushTimer?.cancel();
      _missingIntervals.clear();
      _activeInterval = null;
      if (!_commitData()) return;
    }
    this.duration = duration;
    requestedDateTimeRange = duration.dateTimeRange;

    debugPrint(
        'REQUEST:Requesting historical data for $requestedDateTimeRange');
    numberOfPagesFetched = 0;
    numberOfBlankPagesFetched = 0;
    currentPageNumber = null;
    _startPageNumber = null;
    _hasWrappedAround = false;

    if (_isSlim) {
      try {
        final requested = HistoryCoverageService.requested(
            deviceId, requestedDateTimeRange!, DateTime.now());
        if (requested != null) {
          _missingIntervals.addAll(
              ref.read(historyCoverageServiceProvider).missing(requested));
        }
        _startNextInterval();
      } catch (error) {
        _fail('Could not read download coverage: $error');
      }
    } else {
      _requestData();
    }
  }

  void _startNextInterval() {
    if (_missingIntervals.isEmpty) {
      _finishRequest();
      return;
    }
    _activeInterval = _missingIntervals.removeFirst();
    pendingDateTimeRange = HistoryCoverageService.dateRange(_activeInterval!);
    _reachedIntervalStart = false;
    currentPageNumber = null;
    _startPageNumber = null;
    _hasWrappedAround = false;
    numberOfPagesFetched = 0;
    numberOfBlankPagesFetched = 0;
    _requestData();
  }

  void pauseForUpdate() {
    _pausedForUpdate = true;
    _requestGeneration++;
    _activeInterval = null;
    _missingIntervals.clear();
    _timeoutTimer?.cancel();
    _flushTimer?.cancel();
    _commitData();
    state = const AsyncNone();
  }

  void resumeAfterUpdate() {
    if (BleCommunicatorService.instance.communicator(deviceId).isSuspended) {
      return;
    }
    if (!_pausedForUpdate) return;
    _pausedForUpdate = false;
    final requested = duration;
    if (requested != null) request(requested);
  }

  void _requestData() {
    if (BleCommunicatorService.instance.communicator(deviceId).isSuspended) {
      return;
    }
    debugPrint('REQUEST:Current page number: $currentPageNumber');
    _startTimeoutTimer();

    if (currentPageNumber == null) {
      _sendCommand(DeviceCmdUtils.getCurrentFlashPage(),
          "Getting the last recorded data");
    } else {
      if (!_isSlim) _setPendingDateTimeRange();
      _sendCommand(DeviceCmdUtils.getCo2History(currentPageNumber!),
          "Getting historical data for page $currentPageNumber");
    }
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(_requestTimeout, () {
      debugPrint('REQUEST:Timeout occurred while waiting for device response');
      _handleTimeout();
    });
  }

  void _fail(String message) {
    _timeoutTimer?.cancel();
    _flushTimer?.cancel();
    _activeInterval = null;
    _missingIntervals.clear();
    state = AsyncFailure(message);
  }

  void _handleTimeout() {
    if (_isSlim) {
      _fail('Timeout occurred while waiting for device response');
      return;
    }
    state = AsyncFailure(
      'Timeout occurred while waiting for device response',
    );
  }

  void handleDisconnected() {
    if (_isSlim && state is AsyncInProgress) {
      _fail('Device disconnected before history download completed');
    }
  }

  void _sendCommand(Uint8List command, String message) {
    state = AsyncInProgress(0.1, message: message);
    final generation = _requestGeneration;
    ref.read(historyCommandSenderProvider(deviceId))(command).then((sent) {
      if (_isSlim &&
          generation == _requestGeneration &&
          state is AsyncInProgress &&
          !sent) {
        _fail('Could not send history request');
      }
    }).catchError((Object error) {
      if (_isSlim &&
          generation == _requestGeneration &&
          state is AsyncInProgress) {
        _fail('Could not send history request: $error');
      }
    });
  }

  void handleHistoricalDataResponse(dynamic data, {int? pageNumber}) {
    if (BleCommunicatorService.instance.communicator(deviceId).isSuspended) {
      return;
    }
    if (_isSlim) {
      if (state is! AsyncInProgress || _activeInterval == null) return;
      if (data is int) {
        // A delayed write-pointer response must not restart an active scan.
        if (currentPageNumber != null) return;
      } else if (data is! List<DeviceData> || data.isEmpty) {
        _fail('Invalid Slim history response; please retry');
        return;
      } else if (currentPageNumber == null || pageNumber != currentPageNumber) {
        // Ignore stale/duplicate pages without cancelling the response timeout.
        return;
      }
    }
    // Cancel timeout timer when we get a response
    _timeoutTimer?.cancel();

    if (data is int) {
      currentPageNumber = data;
      _startPageNumber = data;
      _hasWrappedAround = false;
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
    if (_isSlim) {
      _reachedIntervalStart |= deviceDataList.any((record) =>
          record.type != DeviceDataType.empty.index &&
          record.dateTime.isAfter(_unsyncedThresholdDate) &&
          !record.dateTime.isAfter(pendingDateTimeRange!.start));
    }

    numberOfPagesFetched++;
    currentPageNumber = (currentPageNumber ?? 0) - 1;

    if (currentPageNumber! < 0) {
      if (_hasWrappedAround || _shouldStopRingWrap()) {
        debugPrint(
            'REQUEST:End of flash scan at page 0 (start=$_startPageNumber, wrapped=$_hasWrappedAround)');
        if (!_saveData(deviceDataList)) return;
        handleHistoricalDataFetchComplete();
        return;
      }
      _hasWrappedAround = true;
      currentPageNumber = Constants.maxFlashPageIndex;
    }

    debugPrint(
        'REQUEST:Current page number: $currentPageNumber, number of pages fetched: $numberOfPagesFetched');

    if (!_saveData(deviceDataList)) return;

    if (_shouldFetchMoreData(deviceDataList)) {
      _requestData();
    } else {
      handleHistoricalDataFetchComplete();
    }
  }

  bool _saveData(List<DeviceData> deviceDataList) {
    // check if the whole data is empty i.e every value is 0
    if (deviceDataList.every((data) => data.value == 0)) {
      debugPrint('REQUEST:All data values are 0, skipping save.');
      return true;
    }

    _dataBuffer.addAll(deviceDataList
        .where((data) => data.type != DeviceDataType.empty.index));

    debugPrint('REQUEST:Buffer size: ${_dataBuffer.length}');

    if (_dataBuffer.length >= _batchSize) {
      return _commitData();
    } else {
      _startFlushTimer(); // Ensure it gets saved if no more data arrives
    }
    return true;
  }

  bool _commitData() {
    debugPrint('REQUEST:Committing data: ${_dataBuffer.length}');
    if (_dataBuffer.isEmpty) return true;

    try {
      // Write to Isar database one by one to catch any failures
      ref.read(isarServiceProvider).write((isar) {
        isar.deviceDatas.putAll(_dataBuffer);
      });

      debugPrint("REQUEST:Successfully saved ${_dataBuffer.length} data");
    } catch (e) {
      debugPrint('REQUEST:Database save operation failed: error: $e');
      if (_isSlim) {
        _fail('Could not save history readings: $e');
        return false;
      }
    }

    _dataBuffer.clear();
    return true;
  }

  /// Skip wrapping from page 0 → 16382 when the write pointer is still in the
  /// low part of flash (partially-filled log). Full ring buffers need one wrap.
  bool _shouldStopRingWrap() {
    final start = _startPageNumber;
    if (start == null) {
      return true;
    }
    return start < Constants.maxFlashPageIndex;
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
    if (_isSlim && (state is! AsyncInProgress || _activeInterval == null)) {
      return;
    }
    // Cancel any pending timers
    _timeoutTimer?.cancel();
    _flushTimer?.cancel();

    debugPrint(
        'REQUEST:That was last: Total number of pages fetched: $numberOfPagesFetched');

    // Save any remaining buffered data
    if (!_commitData()) return;

    if (_isSlim && _activeInterval != null) {
      if (state is! AsyncInProgress) return;
      try {
        // A scan stopped by the existing flash/blank-page limit cannot prove
        // the entire requested interval was examined. Leave it retryable.
        if (_reachedIntervalStart) {
          ref.read(historyCoverageServiceProvider).complete(_activeInterval!);
        }
      } catch (error) {
        _fail('Could not save download coverage: $error');
        return;
      }
      _activeInterval = null;
      _startNextInterval();
      return;
    }
    _finishRequest();
  }

  void _finishRequest() {
    debugPrint(
        'REQUEST:Device data download provider: ${ref.read(deviceDataDownloadProvider(deviceId))}');

    if (ref.read(deviceDataDownloadProvider(deviceId)) is AsyncInProgress) {
      debugPrint('REQUEST:Setting data downloaded from device');
      ref
          .read(deviceDataDownloadProvider(deviceId).notifier)
          .setDataDownloadedFromDevice();
    }

    if (!_isSlim) _saveLastFetchedDateTimeRange();

    requestedDateTimeRange = null;
    duration = null;
    currentPageNumber = null;
    _startPageNumber = null;
    _hasWrappedAround = false;
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

    debugPrint(
        'REQUEST:Fetch start: $fetchStart, Fetch end: $fetchEnd, Last fetched start: $lastFetchedStartDate, Last fetched end: $lastFetchedEndDate');

    if (fetchStart != null && fetchEnd != null) {
      pendingDateTimeRange = DateTimeRange(start: fetchStart, end: fetchEnd);
    }

    debugPrint('REQUEST:Pending date time range: $pendingDateTimeRange');
  }

  void clear() {
    _requestGeneration++;
    _activeInterval = null;
    _missingIntervals.clear();
    // Cancellation never certifies the interrupted interval.
    if (_isSlim) _dataBuffer.clear();
    // Cancel any pending timers
    _timeoutTimer?.cancel();
    _flushTimer?.cancel();

    state = AsyncNone();

    currentPageNumber = null;
    _startPageNumber = null;
    _hasWrappedAround = false;
    numberOfPagesFetched = 0;
    requestedDateTimeRange = null;
    pendingDateTimeRange = null;
    duration = null;
  }
}
