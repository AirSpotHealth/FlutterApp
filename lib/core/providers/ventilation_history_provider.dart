import 'package:airspothealth/core/models/ventilation_event.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';

/// Bumped by the coordinator whenever an event is written, so history pages
/// rebuild without polling.
final ventilationHistoryVersionProvider = StateProvider<int>((_) => 0);

/// All ventilation events for a device, newest first.
final ventilationHistoryProvider =
    Provider.autoDispose.family<List<VentilationEvent>, String>((ref, deviceId) {
  ref.watch(ventilationHistoryVersionProvider);
  return IsarService().read<List<VentilationEvent>>((isar) => isar
      .ventilationEvents
      .where()
      .deviceIdEqualTo(deviceId)
      .sortByStartedAtDesc()
      .findAll());
});

/// One event by id.
final ventilationEventProvider =
    Provider.autoDispose.family<VentilationEvent?, String>((ref, eventId) {
  ref.watch(ventilationHistoryVersionProvider);
  return IsarService()
      .read<VentilationEvent?>((isar) => isar.ventilationEvents.get(eventId));
});
