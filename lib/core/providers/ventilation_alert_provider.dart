import 'package:airspothealth/core/models/ventilation_level.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// An AirSpot-controlled alert shown inside the app while it is open.
class VentilationAlert {
  const VentilationAlert({
    required this.deviceId,
    required this.eventId,
    required this.level,
    required this.kind,
    required this.title,
    required this.body,
    required this.reminderMinutes,
    required this.remindersEnabled,
  });

  final String deviceId;
  final String eventId;
  final VentilationLevel level;
  final VentilationNotificationKind kind;
  final String title;
  final String body;
  final int reminderMinutes;
  final bool remindersEnabled;

  bool get isRecovery => kind == VentilationNotificationKind.recovery;

  /// Display level: recovery uses the green "none" band.
  VentilationLevel get displayLevel =>
      isRecovery ? VentilationLevel.none : level;
}

final ventilationAlertProvider =
    NotifierProvider<VentilationAlertNotifier, VentilationAlert?>(
        VentilationAlertNotifier.new);

class VentilationAlertNotifier extends Notifier<VentilationAlert?> {
  @override
  VentilationAlert? build() => null;

  void show(VentilationAlert alert) => state = alert;

  void dismiss({String? deviceId}) {
    if (deviceId == null || state?.deviceId == deviceId) state = null;
  }
}
