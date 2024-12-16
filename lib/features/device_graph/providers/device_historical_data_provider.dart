import 'dart:async';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final deviceHistoricalDataProvider = AsyncNotifierProvider.family.autoDispose<
    _DeviceHistoricalDataNotifier,
    List<DeviceData>,
    (String, GraphDataDuration)>(_DeviceHistoricalDataNotifier.new);

class _DeviceHistoricalDataNotifier extends AutoDisposeFamilyAsyncNotifier<
    List<DeviceData>, (String, GraphDataDuration)> {
  final IsarService _isarService = IsarService();

  String get deviceId => arg.$1;

  GraphDataDuration get duration => arg.$2;

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

  (DateTime, DateTime) get dateTimeRange => duration.getDateTimeRange();

  @override
  FutureOr<List<DeviceData>> build(arg) {
    final (startDate, endDate) = dateTimeRange;

    // First, try to get data from the local database
    _isarService.deviceDatas
        .where()
        .deviceIdEqualTo(deviceId)
        .dateTimeBetween(startDate, endDate)
        .watch(fireImmediately: true)
        .listen((event) {
      state = AsyncData(event);
    });

    fetchDataFromDevice();

    return future;
  }

  void fetchDataFromDevice({bool force = false}) {
    var (startDate, endDate) = dateTimeRange;

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
          DeviceCmdUtils.getCo2History(startDate: startDate, endDate: endDate));

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
          DeviceCmdUtils.getCo2History(startDate: startDate, endDate: endDate));

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
          DeviceCmdUtils.getCo2History(
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
