import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final deviceHistoricalDataProvider = StreamNotifierProvider.family.autoDispose<
    _DeviceHistoricalDataNotifier,
    List<DeviceData>,
    (String, GraphDataDuration)>(_DeviceHistoricalDataNotifier.new);

class _DeviceHistoricalDataNotifier extends AutoDisposeFamilyStreamNotifier<
    List<DeviceData>, (String, GraphDataDuration)> {
  final IsarService _isarService = IsarService();

  String get deviceId => arg.$1;

  GraphDataDuration get duration => arg.$2;

  List<dynamic> get values {
    if (state.valueOrNull.isNullOrEmpty) {
      return [];
    }
    return state.value!.map((e) => e.value).toList();
  }

  DeviceData? get maxValue {
    if (state.value.isNullOrEmpty) {
      return null;
    }

    return state.value!.reduce(
        (value, element) => value.value > element.value ? value : element);
  }

  DeviceData? get minValue {
    if (state.value.isNullOrEmpty) {
      return null;
    }
    return state.value!.reduce(
        (value, element) => value.value < element.value ? value : element);
  }

  (DateTime, DateTime) get dateTimeRange => duration.getDateTimeRange();

  @override
  Stream<List<DeviceData>> build(arg) {
    final (startDate, endDate) = dateTimeRange;

    // First, try to get data from the local database
    final localDataStream = _isarService.deviceDatas
        .where()
        .deviceIdEqualTo(deviceId)
        .dateTimeBetween(startDate, endDate)
        .sortByDateTime()
        .watch(fireImmediately: true);

    _fetchDataFromDevice();

    return localDataStream;
  }

  void _fetchDataFromDevice() async {
    final currentDateTime = DateTime.now();
    final (startDate, endDate) = dateTimeRange;

    ref
        .read(bleDeviceCommunicationProvider(deviceId).notifier)
        .sendCommand(DeviceCmdUtils.getCo2History(
          startDate: startDate,
          endDate: endDate,
        ));

    return;

    // Read the existing device data from the database
    final bleDevice = _isarService.read<BleDevice?>((isar) =>
        isar.bleDevices.where().deviceIdEqualTo(deviceId).findFirst());

    DateTime fetchStartDate = startDate;
    DateTime fetchEndDate = endDate;

    // If data has been previously fetched, adjust the start date
    if (bleDevice != null && bleDevice.lastFetchedEndDate != null) {
      final lastFetchedEndDate = bleDevice.lastFetchedEndDate!;

      // If the last fetched end date is after the current start date, use it as the new start date
      if (lastFetchedEndDate.isAfter(startDate)) {
        fetchStartDate = lastFetchedEndDate;
      }
    }

    // Set the end date to current time if it exceeds the current end date
    if (fetchEndDate.isAfter(currentDateTime)) {
      fetchEndDate = currentDateTime;
    }

    // Only fetch if there is a valid time gap
    if (fetchStartDate.isBefore(fetchEndDate)) {
      ref.read(bleDeviceCommunicationProvider(deviceId).notifier).sendCommand(
            DeviceCmdUtils.getCo2History(
              startDate: fetchStartDate,
              endDate: fetchEndDate,
            ),
          );

      // Update the last fetched range in the BleDevice model
      if (bleDevice != null) {
        _isarService.write((isar) {
          final updatedBleDevice = bleDevice.copyWith(
            lastFetchedStartDate: fetchStartDate,
            lastFetchedEndDate: fetchEndDate,
          );
          return isar.bleDevices.put(updatedBleDevice);
        });
      }
    }
  }
}
