import 'dart:async';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_data_type.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/utils/app_utils.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_graph/providers/device_history_data_request_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';

class DeviceHistoryDataRequest {
  final String deviceId;
  final GraphDataDuration duration;

  DeviceHistoryDataRequest(this.deviceId, this.duration);

  @override
  String toString() {
    return 'DeviceHistoryDataRequest(deviceId: $deviceId, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    if (other is! DeviceHistoryDataRequest) {
      return false;
    }
    return deviceId == other.deviceId && duration == other.duration;
  }

  @override
  int get hashCode => deviceId.hashCode ^ duration.hashCode;
}

final deviceHistoricalDataProvider = AsyncNotifierProvider.family.autoDispose<
    _DeviceHistoricalDataNotifier,
    List<DeviceData>,
    DeviceHistoryDataRequest>(_DeviceHistoricalDataNotifier.new);

class _DeviceHistoricalDataNotifier extends AutoDisposeFamilyAsyncNotifier<
    List<DeviceData>, DeviceHistoryDataRequest> {
  final IsarService _isarService = IsarService();

  String get deviceId => arg.deviceId;

  GraphDataDuration get duration => arg.duration;

  Iterable<dynamic> get values => state.value?.map((e) => e.value) ?? [];

  DeviceData? get maxValue {
    if (state.valueOrNull == null) {
      return null;
    }

    if (state.valueOrNull!.isEmpty) {
      return null;
    }

    return state.value?.reduce(
        (value, element) => value.value > element.value ? value : element);
  }

  DeviceData? get minValue {
    if (state.valueOrNull == null) {
      return null;
    }

    if (state.valueOrNull!.isEmpty) {
      return null;
    }

    return state.value?.reduce(
        (value, element) => value.value < element.value ? value : element);
  }

  DateTimeRange get dateTimeRange => duration.dateTimeRange;

  @override
  FutureOr<List<DeviceData>> build(arg) {
    final endDate =
        dateTimeRange.end.isToday ? DateTime.now().endOfDay : dateTimeRange.end;

    // First, try to get data from the local database
    _isarService.deviceDatas
        .where()
        .deviceIdEqualTo(deviceId)
        .dateTimeBetween(dateTimeRange.start, endDate)
        .typeEqualTo(DeviceDataType.co2.index)
        .valueGreaterThan(0)
        .sortByDateTime()
        .watch(fireImmediately: true)
        .listen((event) {
      state = AsyncData(event);
    });

    final BleDevice bleDevice = ref.read(bleDeviceProvider(deviceId));
    final bool isSlim = bleDevice.deviceModel == DeviceModel.airspotSlim;
    final String deviceFirmwareVersion = bleDevice.firmwareVersion;

    // Slim always uses the half-page history protocol. The date-range "old"
    // protocol is not implemented by Slim firmware (it would mis-read the date
    // bytes as a half-page index), so never fall back to it for Slim.
    if (!isSlim && !AppUtils.isNewFirmwareVersion(deviceFirmwareVersion)) {
      requestHistoricalDataOld();
    } else {
      ref.read(deviceHistoryDataRequestProvider(deviceId).notifier).request(
          duration.name == 'today'
              ? GraphDataDuration.today
              : GraphDataDuration.custom(dateTimeRange));
    }

    return future;
  }

  void requestHistoricalDataOld({bool force = false}) {
    DateTime startDate = dateTimeRange.start;
    DateTime endDate = dateTimeRange.end;

    // if start date is today then end date should be now because dateTimeRange returns the end of the day for today
    if (startDate.isToday) {
      endDate = DateTime.now();
    }

    // Retrieve the BLE device information from the local database
    final bleDevice = _isarService.read<BleDevice?>((isar) =>
        isar.bleDevices.where().deviceIdEqualTo(deviceId).findFirst());

    if (bleDevice == null) {
      return;
    }

    // ref.read(bleDeviceCommunicationProvider(deviceId).notifier).sendCommand(
    //     DeviceCmdUtils.getCo2History(startDate: startDate, endDate: endDate));

    // return;

    if (force) {
      ref.read(bleDeviceCommunicationProvider(deviceId).notifier).sendCommand(
          DeviceCmdUtils.getCo2HistoryOld(
              startDate: startDate, endDate: endDate));

      // Update lastFetchedStartDate and lastFetchedEndDate in the local database
      _isarService.write((isar) {
        isar.bleDevices.put(bleDevice.copyWith(
            lastFetchedStartDate: startDate, lastFetchedEndDate: endDate));
      });

      return;
    }

    // Check existing fetched dates
    final lastFetchedStartDate = bleDevice.lastFetchedStartDate;
    final lastFetchedEndDate = bleDevice.lastFetchedEndDate;

    debugPrint(
        'Last fetched start date: $lastFetchedStartDate, Last fetched end date: $lastFetchedEndDate');

    if (lastFetchedStartDate == null || lastFetchedEndDate == null) {
      // No data has been fetched yet; fetch all data
      ref.read(bleDeviceCommunicationProvider(deviceId).notifier).sendCommand(
          DeviceCmdUtils.getCo2HistoryOld(
              startDate: startDate, endDate: endDate));

      // Update lastFetchedStartDate and lastFetchedEndDate in the local database
      _isarService.write((isar) {
        isar.bleDevices.put(bleDevice.copyWith(
            lastFetchedStartDate: startDate, lastFetchedEndDate: endDate));
      });

      return;
    }

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

    debugPrint('Fetch start: $fetchStart, Fetch end: $fetchEnd');

    // If fetch range is determined, send the command to the device
    if (fetchStart != null && fetchEnd != null) {
      ref.read(bleDeviceCommunicationProvider(deviceId).notifier).sendCommand(
          DeviceCmdUtils.getCo2HistoryOld(
              startDate: fetchStart, endDate: fetchEnd));

      // Update lastFetchedStartDate and lastFetchedEndDate in the local database
      _isarService.write((isar) {
        isar.bleDevices.put(bleDevice.copyWith(
          lastFetchedStartDate: fetchStart!.isBefore(lastFetchedStartDate)
              ? fetchStart
              : lastFetchedStartDate,
          lastFetchedEndDate: fetchEnd!.isAfter(lastFetchedEndDate)
              ? fetchEnd
              : lastFetchedEndDate,
        ));
      });
    }
  }
}
