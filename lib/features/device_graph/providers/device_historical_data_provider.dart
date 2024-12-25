import 'dart:async';

import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/providers/device_history_data_request_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

typedef DeviceHistoryDataRequest = (
  String deviceId,
  GraphDataDuration duration
);

final deviceHistoricalDataProvider = AsyncNotifierProvider.family.autoDispose<
    _DeviceHistoricalDataNotifier,
    List<DeviceData>,
    DeviceHistoryDataRequest>(_DeviceHistoricalDataNotifier.new);

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

  DateTimeRange get dateTimeRange => duration.getDateTimeRange();

  @override
  FutureOr<List<DeviceData>> build(arg) {
    // First, try to get data from the local database
    _isarService.deviceDatas
        .where()
        .deviceIdEqualTo(deviceId)
        .dateTimeBetween(dateTimeRange.start, dateTimeRange.end)
        .sortByDateTime()
        .watch(fireImmediately: true)
        .listen((event) {
      state = AsyncData(event);
    });

    ref
        .read(deviceHistoryDataRequestProvider(deviceId).notifier)
        .request(duration);

    return future;
  }
}
