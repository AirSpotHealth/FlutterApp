import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:flutter/material.dart';
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

  @override
  Stream<List<DeviceData>> build(arg) {
    final range = duration.getDateTimeRange();

    debugPrint('DeviceHistoricalDataProvider: $range');

    return _isarService.deviceDatas
        .where()
        .deviceIdEqualTo(deviceId)
        .dateTimeBetween(range.$1, range.$2)
        .sortByDateTime()
        .watch(fireImmediately: true);
  }
}
