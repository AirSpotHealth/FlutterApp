import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Deterioration levels of a ventilation event, lowest to highest.
/// [none] means the air is in the lowest band (below the stuffy threshold).
enum VentilationLevel { none, stuffy, better, poor }

/// What a notification inside an event was for.
enum VentilationNotificationKind { alert, reminder, recovery }

/// The response a user recorded after "I've taken action".
enum VentilationUserAction {
  none,
  openedWindowOrDoor,
  increasedVentilation,
  movedElsewhere,
  reducedOccupancy,
  somethingElse,
}

/// Lifecycle of a ventilation event.
enum VentilationEventStatus { active, recovered, expired }

/// Notification action identifiers shared by iOS categories, Android action
/// buttons, in-app alert cards and the response handler.
class VentilationActionIds {
  VentilationActionIds._();

  static const takenAction = 'ventilation_taken_action';
  static const whatCanIDo = 'ventilation_what_can_i_do';
  static const remind = 'ventilation_remind';
  static const viewResult = 'ventilation_view_result';
  static const done = 'ventilation_done';

  static const takenActionLabel = 'I’ve taken action';
  static const whatCanIDoLabel = 'What can I do?';
  static const viewResultLabel = 'View result';
  static const doneLabel = 'Done';

  static String remindLabel(int minutes) => 'Remind me in $minutes min';
}

extension VentilationLevelX on VentilationLevel {
  bool get isDeterioration => this != VentilationLevel.none;

  /// Numeric rank used for escalation comparisons.
  int get rank => index;

  /// Notification / alert title. The recovery title lives in
  /// [VentilationCopy.recoveryTitle] because recovery is not a level.
  String get title {
    switch (this) {
      case VentilationLevel.none:
        return VentilationCopy.recoveryTitle;
      case VentilationLevel.stuffy:
        return 'Air is getting stuffy';
      case VentilationLevel.better:
        return 'Ventilation could be better';
      case VentilationLevel.poor:
        return 'Poor ventilation detected';
    }
  }

  /// Short state label shown on the live reading and in history.
  String get stateLabel {
    switch (this) {
      case VentilationLevel.none:
        return 'Air is fresh';
      case VentilationLevel.stuffy:
        return 'Air is getting stuffy';
      case VentilationLevel.better:
        return 'Ventilation could be better';
      case VentilationLevel.poor:
        return 'Poor ventilation';
    }
  }

  Color get color {
    switch (this) {
      case VentilationLevel.none:
        return AppColors.ventGreen;
      case VentilationLevel.stuffy:
        return AppColors.ventAmber;
      case VentilationLevel.better:
        return AppColors.ventRed;
      case VentilationLevel.poor:
        return AppColors.ventDarkRed;
    }
  }

  Color get paleColor {
    switch (this) {
      case VentilationLevel.none:
        return AppColors.ventGreenPale;
      case VentilationLevel.stuffy:
        return AppColors.ventAmberPale;
      case VentilationLevel.better:
        return AppColors.ventRedPale;
      case VentilationLevel.poor:
        return AppColors.ventDarkRedPale;
    }
  }

  IconData get icon {
    switch (this) {
      case VentilationLevel.none:
        return Icons.check_circle_rounded;
      case VentilationLevel.stuffy:
        return Icons.air_rounded;
      case VentilationLevel.better:
        return Icons.warning_amber_rounded;
      case VentilationLevel.poor:
        return Icons.warning_rounded;
    }
  }

  /// Android large-icon drawable name (see android/app/src/main/res/drawable).
  String get androidLargeIcon {
    switch (this) {
      case VentilationLevel.none:
        return '@drawable/ic_notif_green';
      case VentilationLevel.stuffy:
        return '@drawable/ic_notif_amber';
      case VentilationLevel.better:
        return '@drawable/ic_notif_red';
      case VentilationLevel.poor:
        return '@drawable/ic_notif_darkred';
    }
  }

  /// iOS notification category identifier.
  String get iosCategoryId {
    switch (this) {
      case VentilationLevel.none:
        return 'ventilation_recovered';
      case VentilationLevel.stuffy:
        return 'ventilation_stuffy';
      case VentilationLevel.better:
        return 'ventilation_better';
      case VentilationLevel.poor:
        return 'ventilation_poor';
    }
  }
}

extension VentilationUserActionX on VentilationUserAction {
  String get label {
    switch (this) {
      case VentilationUserAction.none:
        return 'No action recorded';
      case VentilationUserAction.openedWindowOrDoor:
        return 'Opened a window or door';
      case VentilationUserAction.increasedVentilation:
        return 'Increased ventilation';
      case VentilationUserAction.movedElsewhere:
        return 'Moved somewhere else';
      case VentilationUserAction.reducedOccupancy:
        return 'Reduced occupancy';
      case VentilationUserAction.somethingElse:
        return 'Something else';
    }
  }

  IconData get icon {
    switch (this) {
      case VentilationUserAction.none:
        return Icons.remove_rounded;
      case VentilationUserAction.openedWindowOrDoor:
        return Icons.north_east_rounded;
      case VentilationUserAction.increasedVentilation:
        return Icons.waves_rounded;
      case VentilationUserAction.movedElsewhere:
        return Icons.east_rounded;
      case VentilationUserAction.reducedOccupancy:
        return Icons.remove_rounded;
      case VentilationUserAction.somethingElse:
        return Icons.more_horiz_rounded;
    }
  }

  /// Options offered in the "What did you do?" sheet, in spec order.
  static const choices = [
    VentilationUserAction.openedWindowOrDoor,
    VentilationUserAction.increasedVentilation,
    VentilationUserAction.movedElsewhere,
    VentilationUserAction.reducedOccupancy,
    VentilationUserAction.somethingElse,
  ];
}

/// Maps a live reading onto the four state bands used everywhere in the app.
class VentilationBands {
  VentilationBands._();

  static VentilationLevel forReading(
    int? value, {
    required int stuffyThreshold,
    required int betterThreshold,
    required int poorThreshold,
  }) {
    if (value == null) return VentilationLevel.none;
    if (value >= poorThreshold) return VentilationLevel.poor;
    if (value >= betterThreshold) return VentilationLevel.better;
    if (value >= stuffyThreshold) return VentilationLevel.stuffy;
    return VentilationLevel.none;
  }
}

/// Exact user-facing wording from the notification actions specification.
/// Only dynamic values (reading, peak, elapsed time) are substituted.
class VentilationCopy {
  VentilationCopy._();

  static final NumberFormat _ppm = NumberFormat.decimalPattern('en');

  static const recoveryTitle = 'The air has improved';

  static const smartNotificationsTitle = 'Smart notifications';
  static const smartNotificationsSubtitle =
      'Useful prompts when ventilation deteriorates or improves';

  static const guidanceTitle = 'Improve the air';
  static const guidanceIntro =
      'If practical, try one or more of these actions.';
  static const guidanceItems = [
    'Open an external window or door',
    'Increase the system’s outdoor-air setting',
    'Move closer to fresh air or outdoors',
    'Reduce the number of people in the space',
  ];
  static const guidanceNote =
      'Air cleaners can remove airborne particles, but most do not lower CO₂.';

  static const takenActionTitle = 'What did you do?';
  static const takenActionIntro =
      'This helps AirSpot show whether conditions improved afterwards.';

  static String ppm(int value) => _ppm.format(value);

  /// Compact elapsed time: "12 min", "1 h 5 min", "2 h".
  static String elapsed(Duration d) {
    final minutes = d.inMinutes;
    if (minutes < 1) return 'under 1 min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    if (hours == 0) return '$minutes min';
    if (rest == 0) return '$hours h';
    return '$hours h $rest min';
  }

  static String body({
    required VentilationLevel level,
    required int currentValue,
    required int betterThreshold,
    required int betterPersistMinutes,
    required int poorThreshold,
  }) {
    switch (level) {
      case VentilationLevel.stuffy:
        return 'CO₂ ${ppm(currentValue)} ppm and rising — let in outdoor air if practical.';
      case VentilationLevel.better:
        return 'CO₂ above ${ppm(betterThreshold)} ppm for $betterPersistMinutes min — improve ventilation.';
      case VentilationLevel.poor:
        return 'CO₂ above ${ppm(poorThreshold)} ppm — improve ventilation or move.';
      case VentilationLevel.none:
        throw ArgumentError('Use recoveryBody for the recovered state');
    }
  }

  static String recoveryBody({
    required int peakValue,
    required int currentValue,
    required Duration elapsed,
  }) =>
      'CO₂ fell from ${ppm(peakValue)} to ${ppm(currentValue)} ppm in ${VentilationCopy.elapsed(elapsed)}.';

  /// Reminder interval offered on the notification for a level.
  static int reminderMinutesFor(
    VentilationLevel level, {
    required int reminderMinutes,
    required int highPriorityReminderMinutes,
  }) =>
      level == VentilationLevel.poor
          ? highPriorityReminderMinutes
          : reminderMinutes;
}
