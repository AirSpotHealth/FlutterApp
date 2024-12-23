import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
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

  static final _unsyncedThresholdDate =
      DateTime.fromMillisecondsSinceEpoch(Constants.syncedTimeThreshold * 1000);

  @override
  build(String arg) {
    return AsyncNone();
  }

  void request(GraphDataDuration duration) {
    if (this.duration != duration) {
      currentPageNumber = null;
      numberOfPagesFetched = 0;
    }

    this.duration = duration;
    dateTimeRange = duration.getDateTimeRange();

    debugPrint('Requesting historical data for $dateTimeRange');

    _requestData();
  }

  void _requestData() {
    debugPrint('Current page number: $currentPageNumber');

    if (currentPageNumber == null) {
      ref
          .read(bleDeviceCommunicationProvider(deviceId).notifier)
          .sendCommand(DeviceCmdUtils.getCurrentFlashPage());
      state = AsyncInProgress(0.1, message: "Getting the last recorded data");
    } else {
      ref
          .read(bleDeviceCommunicationProvider(deviceId).notifier)
          .sendCommand(DeviceCmdUtils.getCo2History(currentPageNumber!));
      state = AsyncInProgress(0.1,
          message: "Getting historical data for page $currentPageNumber");
    }
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

    numberOfPagesFetched = numberOfPagesFetched + 1;
    currentPageNumber = (currentPageNumber ?? 0) - 1;

    // print first and last timestamp
    debugPrint(
        'First timestamp: ${deviceDataList.first.dateTime.toIso8601String()}');
    debugPrint(
        'Last timestamp: ${deviceDataList.last.dateTime.toIso8601String()}');

    // save the data to the local database
    ref.read(isarServiceProvider).write((isar) {
      isar.deviceDatas.putAll(deviceDataList);
    });

    // first datetime of the list
    final DateTime firstDateTime = deviceDataList.first.dateTime;

    if (firstDateTime.isAfter(_unsyncedThresholdDate) &&
        firstDateTime.isBefore(dateTimeRange!.start)) {
      handleHistoricalDataFetchComplete();
      return;
    }

    if (currentPageNumber! < 0) {
      currentPageNumber = Constants.maxFlashPageCount - 1;

      debugPrint('Current page number reset to $currentPageNumber');

      if (numberOfPagesFetched >= Constants.maxFlashPageCount) {
        handleHistoricalDataFetchComplete();
        return;
      }
    }

    _requestData();
  }

  void handleHistoricalDataFetchComplete() {
    debugPrint(
        'That was last: Total number of pages fetched: $numberOfPagesFetched');

    // if the date time range is last 7 days, then update the download data provider that the data is downloaded
    if (duration == GraphDataDuration.last7Days) {
      ref
          .read(deviceDataDownloadProvider(deviceId).notifier)
          .setDataDownloadedFromDevice();
    }

    dateTimeRange = null;
    state = AsyncSuccess(null);
  }
}
