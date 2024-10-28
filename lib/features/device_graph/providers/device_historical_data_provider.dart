import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final deviceHistoricalDataProvider = NotifierProvider.family<
    _DeviceHistoricalDataNotifier,
    List<DeviceData>,
    String>(_DeviceHistoricalDataNotifier.new);

class _DeviceHistoricalDataNotifier
    extends FamilyNotifier<List<DeviceData>, String> {
  final IsarService _isarService = IsarService();

  GraphDataDuration _duration = GraphDataDuration.today;

  String get deviceId => arg;

  GraphDataDuration get duration => _duration;

  List<dynamic> get values {
    if (state.isEmpty) {
      return [];
    }
    return state.map((e) => e.value).toList();
  }

  DeviceData? get maxValue {
    if (state.isEmpty) {
      return null;
    }

    return state.reduce(
        (value, element) => value.value > element.value ? value : element);
  }

  DeviceData? get minValue {
    if (state.isEmpty) {
      return null;
    }
    return state.reduce(
        (value, element) => value.value < element.value ? value : element);
  }

  void setDuration(GraphDataDuration duration) {
    _duration = duration;
    _getDeviceData();
    // build(deviceId);
  }

  @override
  List<DeviceData> build(String arg) {
    final DateTimeRange range = _duration.getDateTimeRange();

    _isarService.read((isar) {
      isar.deviceDatas
          .where()
          .deviceIdEqualTo(deviceId)
          .dateTimeBetween(range.$1, range.$2)
          .sortByDateTime()
          .watch(fireImmediately: true)
          .listen((event) {
        state = event;
      });
    });

    // _getDeviceData();

    return [];
  }

  void _getDeviceData() {
    ref
        .read(bleDeviceCommunicationProvider(deviceId).notifier)
        .sendCommand(DeviceCmdUtils.getCo2History());
  }
}
