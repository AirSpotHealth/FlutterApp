// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetNotificationPreferencesCollection on Isar {
  IsarCollection<String, NotificationPreferences> get notificationPreferences =>
      this.collection();
}

final NotificationPreferencesSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'NotificationPreferences',
    idName: 'deviceId',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'deviceId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'smartNotificationsEnabled',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'notifyStuffy',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'notifyPoor',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'notifyImproved',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'vibrationEnabled',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'showInForeground',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'remindersEnabled',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'stuffyThreshold',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'betterThreshold',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'poorThreshold',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'stuffyPersistMinutes',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'betterPersistMinutes',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'poorPersistMinutes',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'reminderMinutes',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'highPriorityReminderMinutes',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'recoveryMinutes',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'quietHoursEnabled',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'quietHoursStart',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'quietHoursEnd',
        type: IsarType.dateTime,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, NotificationPreferences>(
    serialize: serializeNotificationPreferences,
    deserialize: deserializeNotificationPreferences,
    deserializeProperty: deserializeNotificationPreferencesProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeNotificationPreferences(
    IsarWriter writer, NotificationPreferences object) {
  IsarCore.writeString(writer, 1, object.deviceId);
  IsarCore.writeBool(writer, 2, value: object.smartNotificationsEnabled);
  IsarCore.writeBool(writer, 3, value: object.notifyStuffy);
  IsarCore.writeBool(writer, 4, value: object.notifyPoor);
  IsarCore.writeBool(writer, 5, value: object.notifyImproved);
  IsarCore.writeBool(writer, 6, value: object.vibrationEnabled);
  IsarCore.writeBool(writer, 7, value: object.showInForeground);
  IsarCore.writeBool(writer, 8, value: object.remindersEnabled);
  IsarCore.writeLong(writer, 9, object.stuffyThreshold);
  IsarCore.writeLong(writer, 10, object.betterThreshold);
  IsarCore.writeLong(writer, 11, object.poorThreshold);
  IsarCore.writeLong(writer, 12, object.stuffyPersistMinutes);
  IsarCore.writeLong(writer, 13, object.betterPersistMinutes);
  IsarCore.writeLong(writer, 14, object.poorPersistMinutes);
  IsarCore.writeLong(writer, 15, object.reminderMinutes);
  IsarCore.writeLong(writer, 16, object.highPriorityReminderMinutes);
  IsarCore.writeLong(writer, 17, object.recoveryMinutes);
  IsarCore.writeBool(writer, 18, value: object.quietHoursEnabled);
  IsarCore.writeLong(
      writer,
      19,
      object.quietHoursStart?.toUtc().microsecondsSinceEpoch ??
          -9223372036854775808);
  IsarCore.writeLong(
      writer,
      20,
      object.quietHoursEnd?.toUtc().microsecondsSinceEpoch ??
          -9223372036854775808);
  return Isar.fastHash(object.deviceId);
}

@isarProtected
NotificationPreferences deserializeNotificationPreferences(IsarReader reader) {
  final String _deviceId;
  _deviceId = IsarCore.readString(reader, 1) ?? '';
  final bool _smartNotificationsEnabled;
  _smartNotificationsEnabled = IsarCore.readBool(reader, 2);
  final bool _notifyStuffy;
  {
    if (IsarCore.readNull(reader, 3)) {
      _notifyStuffy = true;
    } else {
      _notifyStuffy = IsarCore.readBool(reader, 3);
    }
  }
  final bool _notifyPoor;
  {
    if (IsarCore.readNull(reader, 4)) {
      _notifyPoor = true;
    } else {
      _notifyPoor = IsarCore.readBool(reader, 4);
    }
  }
  final bool _notifyImproved;
  {
    if (IsarCore.readNull(reader, 5)) {
      _notifyImproved = true;
    } else {
      _notifyImproved = IsarCore.readBool(reader, 5);
    }
  }
  final bool _vibrationEnabled;
  {
    if (IsarCore.readNull(reader, 6)) {
      _vibrationEnabled = true;
    } else {
      _vibrationEnabled = IsarCore.readBool(reader, 6);
    }
  }
  final bool _showInForeground;
  {
    if (IsarCore.readNull(reader, 7)) {
      _showInForeground = true;
    } else {
      _showInForeground = IsarCore.readBool(reader, 7);
    }
  }
  final bool _remindersEnabled;
  {
    if (IsarCore.readNull(reader, 8)) {
      _remindersEnabled = true;
    } else {
      _remindersEnabled = IsarCore.readBool(reader, 8);
    }
  }
  final int _stuffyThreshold;
  {
    final value = IsarCore.readLong(reader, 9);
    if (value == -9223372036854775808) {
      _stuffyThreshold = 800;
    } else {
      _stuffyThreshold = value;
    }
  }
  final int _betterThreshold;
  {
    final value = IsarCore.readLong(reader, 10);
    if (value == -9223372036854775808) {
      _betterThreshold = 1000;
    } else {
      _betterThreshold = value;
    }
  }
  final int _poorThreshold;
  {
    final value = IsarCore.readLong(reader, 11);
    if (value == -9223372036854775808) {
      _poorThreshold = 1500;
    } else {
      _poorThreshold = value;
    }
  }
  final int _stuffyPersistMinutes;
  {
    final value = IsarCore.readLong(reader, 12);
    if (value == -9223372036854775808) {
      _stuffyPersistMinutes = 5;
    } else {
      _stuffyPersistMinutes = value;
    }
  }
  final int _betterPersistMinutes;
  {
    final value = IsarCore.readLong(reader, 13);
    if (value == -9223372036854775808) {
      _betterPersistMinutes = 10;
    } else {
      _betterPersistMinutes = value;
    }
  }
  final int _poorPersistMinutes;
  {
    final value = IsarCore.readLong(reader, 14);
    if (value == -9223372036854775808) {
      _poorPersistMinutes = 10;
    } else {
      _poorPersistMinutes = value;
    }
  }
  final int _reminderMinutes;
  {
    final value = IsarCore.readLong(reader, 15);
    if (value == -9223372036854775808) {
      _reminderMinutes = 10;
    } else {
      _reminderMinutes = value;
    }
  }
  final int _highPriorityReminderMinutes;
  {
    final value = IsarCore.readLong(reader, 16);
    if (value == -9223372036854775808) {
      _highPriorityReminderMinutes = 5;
    } else {
      _highPriorityReminderMinutes = value;
    }
  }
  final int _recoveryMinutes;
  {
    final value = IsarCore.readLong(reader, 17);
    if (value == -9223372036854775808) {
      _recoveryMinutes = 5;
    } else {
      _recoveryMinutes = value;
    }
  }
  final bool _quietHoursEnabled;
  _quietHoursEnabled = IsarCore.readBool(reader, 18);
  final DateTime? _quietHoursStart;
  {
    final value = IsarCore.readLong(reader, 19);
    if (value == -9223372036854775808) {
      _quietHoursStart = null;
    } else {
      _quietHoursStart =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final DateTime? _quietHoursEnd;
  {
    final value = IsarCore.readLong(reader, 20);
    if (value == -9223372036854775808) {
      _quietHoursEnd = null;
    } else {
      _quietHoursEnd =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final object = NotificationPreferences(
    deviceId: _deviceId,
    smartNotificationsEnabled: _smartNotificationsEnabled,
    notifyStuffy: _notifyStuffy,
    notifyPoor: _notifyPoor,
    notifyImproved: _notifyImproved,
    vibrationEnabled: _vibrationEnabled,
    showInForeground: _showInForeground,
    remindersEnabled: _remindersEnabled,
    stuffyThreshold: _stuffyThreshold,
    betterThreshold: _betterThreshold,
    poorThreshold: _poorThreshold,
    stuffyPersistMinutes: _stuffyPersistMinutes,
    betterPersistMinutes: _betterPersistMinutes,
    poorPersistMinutes: _poorPersistMinutes,
    reminderMinutes: _reminderMinutes,
    highPriorityReminderMinutes: _highPriorityReminderMinutes,
    recoveryMinutes: _recoveryMinutes,
    quietHoursEnabled: _quietHoursEnabled,
    quietHoursStart: _quietHoursStart,
    quietHoursEnd: _quietHoursEnd,
  );
  return object;
}

@isarProtected
dynamic deserializeNotificationPreferencesProp(
    IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readBool(reader, 2);
    case 3:
      {
        if (IsarCore.readNull(reader, 3)) {
          return true;
        } else {
          return IsarCore.readBool(reader, 3);
        }
      }
    case 4:
      {
        if (IsarCore.readNull(reader, 4)) {
          return true;
        } else {
          return IsarCore.readBool(reader, 4);
        }
      }
    case 5:
      {
        if (IsarCore.readNull(reader, 5)) {
          return true;
        } else {
          return IsarCore.readBool(reader, 5);
        }
      }
    case 6:
      {
        if (IsarCore.readNull(reader, 6)) {
          return true;
        } else {
          return IsarCore.readBool(reader, 6);
        }
      }
    case 7:
      {
        if (IsarCore.readNull(reader, 7)) {
          return true;
        } else {
          return IsarCore.readBool(reader, 7);
        }
      }
    case 8:
      {
        if (IsarCore.readNull(reader, 8)) {
          return true;
        } else {
          return IsarCore.readBool(reader, 8);
        }
      }
    case 9:
      {
        final value = IsarCore.readLong(reader, 9);
        if (value == -9223372036854775808) {
          return 800;
        } else {
          return value;
        }
      }
    case 10:
      {
        final value = IsarCore.readLong(reader, 10);
        if (value == -9223372036854775808) {
          return 1000;
        } else {
          return value;
        }
      }
    case 11:
      {
        final value = IsarCore.readLong(reader, 11);
        if (value == -9223372036854775808) {
          return 1500;
        } else {
          return value;
        }
      }
    case 12:
      {
        final value = IsarCore.readLong(reader, 12);
        if (value == -9223372036854775808) {
          return 5;
        } else {
          return value;
        }
      }
    case 13:
      {
        final value = IsarCore.readLong(reader, 13);
        if (value == -9223372036854775808) {
          return 10;
        } else {
          return value;
        }
      }
    case 14:
      {
        final value = IsarCore.readLong(reader, 14);
        if (value == -9223372036854775808) {
          return 10;
        } else {
          return value;
        }
      }
    case 15:
      {
        final value = IsarCore.readLong(reader, 15);
        if (value == -9223372036854775808) {
          return 10;
        } else {
          return value;
        }
      }
    case 16:
      {
        final value = IsarCore.readLong(reader, 16);
        if (value == -9223372036854775808) {
          return 5;
        } else {
          return value;
        }
      }
    case 17:
      {
        final value = IsarCore.readLong(reader, 17);
        if (value == -9223372036854775808) {
          return 5;
        } else {
          return value;
        }
      }
    case 18:
      return IsarCore.readBool(reader, 18);
    case 19:
      {
        final value = IsarCore.readLong(reader, 19);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 20:
      {
        final value = IsarCore.readLong(reader, 20);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _NotificationPreferencesUpdate {
  bool call({
    required String deviceId,
    bool? smartNotificationsEnabled,
    bool? notifyStuffy,
    bool? notifyPoor,
    bool? notifyImproved,
    bool? vibrationEnabled,
    bool? showInForeground,
    bool? remindersEnabled,
    int? stuffyThreshold,
    int? betterThreshold,
    int? poorThreshold,
    int? stuffyPersistMinutes,
    int? betterPersistMinutes,
    int? poorPersistMinutes,
    int? reminderMinutes,
    int? highPriorityReminderMinutes,
    int? recoveryMinutes,
    bool? quietHoursEnabled,
    DateTime? quietHoursStart,
    DateTime? quietHoursEnd,
  });
}

class _NotificationPreferencesUpdateImpl
    implements _NotificationPreferencesUpdate {
  const _NotificationPreferencesUpdateImpl(this.collection);

  final IsarCollection<String, NotificationPreferences> collection;

  @override
  bool call({
    required String deviceId,
    Object? smartNotificationsEnabled = ignore,
    Object? notifyStuffy = ignore,
    Object? notifyPoor = ignore,
    Object? notifyImproved = ignore,
    Object? vibrationEnabled = ignore,
    Object? showInForeground = ignore,
    Object? remindersEnabled = ignore,
    Object? stuffyThreshold = ignore,
    Object? betterThreshold = ignore,
    Object? poorThreshold = ignore,
    Object? stuffyPersistMinutes = ignore,
    Object? betterPersistMinutes = ignore,
    Object? poorPersistMinutes = ignore,
    Object? reminderMinutes = ignore,
    Object? highPriorityReminderMinutes = ignore,
    Object? recoveryMinutes = ignore,
    Object? quietHoursEnabled = ignore,
    Object? quietHoursStart = ignore,
    Object? quietHoursEnd = ignore,
  }) {
    return collection.updateProperties([
          deviceId
        ], {
          if (smartNotificationsEnabled != ignore)
            2: smartNotificationsEnabled as bool?,
          if (notifyStuffy != ignore) 3: notifyStuffy as bool?,
          if (notifyPoor != ignore) 4: notifyPoor as bool?,
          if (notifyImproved != ignore) 5: notifyImproved as bool?,
          if (vibrationEnabled != ignore) 6: vibrationEnabled as bool?,
          if (showInForeground != ignore) 7: showInForeground as bool?,
          if (remindersEnabled != ignore) 8: remindersEnabled as bool?,
          if (stuffyThreshold != ignore) 9: stuffyThreshold as int?,
          if (betterThreshold != ignore) 10: betterThreshold as int?,
          if (poorThreshold != ignore) 11: poorThreshold as int?,
          if (stuffyPersistMinutes != ignore) 12: stuffyPersistMinutes as int?,
          if (betterPersistMinutes != ignore) 13: betterPersistMinutes as int?,
          if (poorPersistMinutes != ignore) 14: poorPersistMinutes as int?,
          if (reminderMinutes != ignore) 15: reminderMinutes as int?,
          if (highPriorityReminderMinutes != ignore)
            16: highPriorityReminderMinutes as int?,
          if (recoveryMinutes != ignore) 17: recoveryMinutes as int?,
          if (quietHoursEnabled != ignore) 18: quietHoursEnabled as bool?,
          if (quietHoursStart != ignore) 19: quietHoursStart as DateTime?,
          if (quietHoursEnd != ignore) 20: quietHoursEnd as DateTime?,
        }) >
        0;
  }
}

sealed class _NotificationPreferencesUpdateAll {
  int call({
    required List<String> deviceId,
    bool? smartNotificationsEnabled,
    bool? notifyStuffy,
    bool? notifyPoor,
    bool? notifyImproved,
    bool? vibrationEnabled,
    bool? showInForeground,
    bool? remindersEnabled,
    int? stuffyThreshold,
    int? betterThreshold,
    int? poorThreshold,
    int? stuffyPersistMinutes,
    int? betterPersistMinutes,
    int? poorPersistMinutes,
    int? reminderMinutes,
    int? highPriorityReminderMinutes,
    int? recoveryMinutes,
    bool? quietHoursEnabled,
    DateTime? quietHoursStart,
    DateTime? quietHoursEnd,
  });
}

class _NotificationPreferencesUpdateAllImpl
    implements _NotificationPreferencesUpdateAll {
  const _NotificationPreferencesUpdateAllImpl(this.collection);

  final IsarCollection<String, NotificationPreferences> collection;

  @override
  int call({
    required List<String> deviceId,
    Object? smartNotificationsEnabled = ignore,
    Object? notifyStuffy = ignore,
    Object? notifyPoor = ignore,
    Object? notifyImproved = ignore,
    Object? vibrationEnabled = ignore,
    Object? showInForeground = ignore,
    Object? remindersEnabled = ignore,
    Object? stuffyThreshold = ignore,
    Object? betterThreshold = ignore,
    Object? poorThreshold = ignore,
    Object? stuffyPersistMinutes = ignore,
    Object? betterPersistMinutes = ignore,
    Object? poorPersistMinutes = ignore,
    Object? reminderMinutes = ignore,
    Object? highPriorityReminderMinutes = ignore,
    Object? recoveryMinutes = ignore,
    Object? quietHoursEnabled = ignore,
    Object? quietHoursStart = ignore,
    Object? quietHoursEnd = ignore,
  }) {
    return collection.updateProperties(deviceId, {
      if (smartNotificationsEnabled != ignore)
        2: smartNotificationsEnabled as bool?,
      if (notifyStuffy != ignore) 3: notifyStuffy as bool?,
      if (notifyPoor != ignore) 4: notifyPoor as bool?,
      if (notifyImproved != ignore) 5: notifyImproved as bool?,
      if (vibrationEnabled != ignore) 6: vibrationEnabled as bool?,
      if (showInForeground != ignore) 7: showInForeground as bool?,
      if (remindersEnabled != ignore) 8: remindersEnabled as bool?,
      if (stuffyThreshold != ignore) 9: stuffyThreshold as int?,
      if (betterThreshold != ignore) 10: betterThreshold as int?,
      if (poorThreshold != ignore) 11: poorThreshold as int?,
      if (stuffyPersistMinutes != ignore) 12: stuffyPersistMinutes as int?,
      if (betterPersistMinutes != ignore) 13: betterPersistMinutes as int?,
      if (poorPersistMinutes != ignore) 14: poorPersistMinutes as int?,
      if (reminderMinutes != ignore) 15: reminderMinutes as int?,
      if (highPriorityReminderMinutes != ignore)
        16: highPriorityReminderMinutes as int?,
      if (recoveryMinutes != ignore) 17: recoveryMinutes as int?,
      if (quietHoursEnabled != ignore) 18: quietHoursEnabled as bool?,
      if (quietHoursStart != ignore) 19: quietHoursStart as DateTime?,
      if (quietHoursEnd != ignore) 20: quietHoursEnd as DateTime?,
    });
  }
}

extension NotificationPreferencesUpdate
    on IsarCollection<String, NotificationPreferences> {
  _NotificationPreferencesUpdate get update =>
      _NotificationPreferencesUpdateImpl(this);

  _NotificationPreferencesUpdateAll get updateAll =>
      _NotificationPreferencesUpdateAllImpl(this);
}

sealed class _NotificationPreferencesQueryUpdate {
  int call({
    bool? smartNotificationsEnabled,
    bool? notifyStuffy,
    bool? notifyPoor,
    bool? notifyImproved,
    bool? vibrationEnabled,
    bool? showInForeground,
    bool? remindersEnabled,
    int? stuffyThreshold,
    int? betterThreshold,
    int? poorThreshold,
    int? stuffyPersistMinutes,
    int? betterPersistMinutes,
    int? poorPersistMinutes,
    int? reminderMinutes,
    int? highPriorityReminderMinutes,
    int? recoveryMinutes,
    bool? quietHoursEnabled,
    DateTime? quietHoursStart,
    DateTime? quietHoursEnd,
  });
}

class _NotificationPreferencesQueryUpdateImpl
    implements _NotificationPreferencesQueryUpdate {
  const _NotificationPreferencesQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<NotificationPreferences> query;
  final int? limit;

  @override
  int call({
    Object? smartNotificationsEnabled = ignore,
    Object? notifyStuffy = ignore,
    Object? notifyPoor = ignore,
    Object? notifyImproved = ignore,
    Object? vibrationEnabled = ignore,
    Object? showInForeground = ignore,
    Object? remindersEnabled = ignore,
    Object? stuffyThreshold = ignore,
    Object? betterThreshold = ignore,
    Object? poorThreshold = ignore,
    Object? stuffyPersistMinutes = ignore,
    Object? betterPersistMinutes = ignore,
    Object? poorPersistMinutes = ignore,
    Object? reminderMinutes = ignore,
    Object? highPriorityReminderMinutes = ignore,
    Object? recoveryMinutes = ignore,
    Object? quietHoursEnabled = ignore,
    Object? quietHoursStart = ignore,
    Object? quietHoursEnd = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (smartNotificationsEnabled != ignore)
        2: smartNotificationsEnabled as bool?,
      if (notifyStuffy != ignore) 3: notifyStuffy as bool?,
      if (notifyPoor != ignore) 4: notifyPoor as bool?,
      if (notifyImproved != ignore) 5: notifyImproved as bool?,
      if (vibrationEnabled != ignore) 6: vibrationEnabled as bool?,
      if (showInForeground != ignore) 7: showInForeground as bool?,
      if (remindersEnabled != ignore) 8: remindersEnabled as bool?,
      if (stuffyThreshold != ignore) 9: stuffyThreshold as int?,
      if (betterThreshold != ignore) 10: betterThreshold as int?,
      if (poorThreshold != ignore) 11: poorThreshold as int?,
      if (stuffyPersistMinutes != ignore) 12: stuffyPersistMinutes as int?,
      if (betterPersistMinutes != ignore) 13: betterPersistMinutes as int?,
      if (poorPersistMinutes != ignore) 14: poorPersistMinutes as int?,
      if (reminderMinutes != ignore) 15: reminderMinutes as int?,
      if (highPriorityReminderMinutes != ignore)
        16: highPriorityReminderMinutes as int?,
      if (recoveryMinutes != ignore) 17: recoveryMinutes as int?,
      if (quietHoursEnabled != ignore) 18: quietHoursEnabled as bool?,
      if (quietHoursStart != ignore) 19: quietHoursStart as DateTime?,
      if (quietHoursEnd != ignore) 20: quietHoursEnd as DateTime?,
    });
  }
}

extension NotificationPreferencesQueryUpdate
    on IsarQuery<NotificationPreferences> {
  _NotificationPreferencesQueryUpdate get updateFirst =>
      _NotificationPreferencesQueryUpdateImpl(this, limit: 1);

  _NotificationPreferencesQueryUpdate get updateAll =>
      _NotificationPreferencesQueryUpdateImpl(this);
}

class _NotificationPreferencesQueryBuilderUpdateImpl
    implements _NotificationPreferencesQueryUpdate {
  const _NotificationPreferencesQueryBuilderUpdateImpl(this.query,
      {this.limit});

  final QueryBuilder<NotificationPreferences, NotificationPreferences,
      QOperations> query;
  final int? limit;

  @override
  int call({
    Object? smartNotificationsEnabled = ignore,
    Object? notifyStuffy = ignore,
    Object? notifyPoor = ignore,
    Object? notifyImproved = ignore,
    Object? vibrationEnabled = ignore,
    Object? showInForeground = ignore,
    Object? remindersEnabled = ignore,
    Object? stuffyThreshold = ignore,
    Object? betterThreshold = ignore,
    Object? poorThreshold = ignore,
    Object? stuffyPersistMinutes = ignore,
    Object? betterPersistMinutes = ignore,
    Object? poorPersistMinutes = ignore,
    Object? reminderMinutes = ignore,
    Object? highPriorityReminderMinutes = ignore,
    Object? recoveryMinutes = ignore,
    Object? quietHoursEnabled = ignore,
    Object? quietHoursStart = ignore,
    Object? quietHoursEnd = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (smartNotificationsEnabled != ignore)
          2: smartNotificationsEnabled as bool?,
        if (notifyStuffy != ignore) 3: notifyStuffy as bool?,
        if (notifyPoor != ignore) 4: notifyPoor as bool?,
        if (notifyImproved != ignore) 5: notifyImproved as bool?,
        if (vibrationEnabled != ignore) 6: vibrationEnabled as bool?,
        if (showInForeground != ignore) 7: showInForeground as bool?,
        if (remindersEnabled != ignore) 8: remindersEnabled as bool?,
        if (stuffyThreshold != ignore) 9: stuffyThreshold as int?,
        if (betterThreshold != ignore) 10: betterThreshold as int?,
        if (poorThreshold != ignore) 11: poorThreshold as int?,
        if (stuffyPersistMinutes != ignore) 12: stuffyPersistMinutes as int?,
        if (betterPersistMinutes != ignore) 13: betterPersistMinutes as int?,
        if (poorPersistMinutes != ignore) 14: poorPersistMinutes as int?,
        if (reminderMinutes != ignore) 15: reminderMinutes as int?,
        if (highPriorityReminderMinutes != ignore)
          16: highPriorityReminderMinutes as int?,
        if (recoveryMinutes != ignore) 17: recoveryMinutes as int?,
        if (quietHoursEnabled != ignore) 18: quietHoursEnabled as bool?,
        if (quietHoursStart != ignore) 19: quietHoursStart as DateTime?,
        if (quietHoursEnd != ignore) 20: quietHoursEnd as DateTime?,
      });
    } finally {
      q.close();
    }
  }
}

extension NotificationPreferencesQueryBuilderUpdate on QueryBuilder<
    NotificationPreferences, NotificationPreferences, QOperations> {
  _NotificationPreferencesQueryUpdate get updateFirst =>
      _NotificationPreferencesQueryBuilderUpdateImpl(this, limit: 1);

  _NotificationPreferencesQueryUpdate get updateAll =>
      _NotificationPreferencesQueryBuilderUpdateImpl(this);
}

extension NotificationPreferencesQueryFilter on QueryBuilder<
    NotificationPreferences, NotificationPreferences, QFilterCondition> {
  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> deviceIdGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> deviceIdGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> deviceIdLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> deviceIdLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> deviceIdBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
          QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
          QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> smartNotificationsEnabledEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> notifyStuffyEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> notifyPoorEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> notifyImprovedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> vibrationEnabledEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> showInForegroundEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> remindersEnabledEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> stuffyThresholdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> stuffyThresholdGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> stuffyThresholdGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> stuffyThresholdLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> stuffyThresholdLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> stuffyThresholdBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> betterThresholdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> betterThresholdGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> betterThresholdGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> betterThresholdLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> betterThresholdLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> betterThresholdBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 10,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> poorThresholdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 11,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> poorThresholdGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 11,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> poorThresholdGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 11,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> poorThresholdLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 11,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> poorThresholdLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 11,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> poorThresholdBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 11,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> stuffyPersistMinutesEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 12,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> stuffyPersistMinutesGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 12,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> stuffyPersistMinutesGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 12,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> stuffyPersistMinutesLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 12,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> stuffyPersistMinutesLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 12,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> stuffyPersistMinutesBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 12,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> betterPersistMinutesEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 13,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> betterPersistMinutesGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 13,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> betterPersistMinutesGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 13,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> betterPersistMinutesLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 13,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> betterPersistMinutesLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 13,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> betterPersistMinutesBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 13,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> poorPersistMinutesEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> poorPersistMinutesGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> poorPersistMinutesGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> poorPersistMinutesLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> poorPersistMinutesLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> poorPersistMinutesBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 14,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> reminderMinutesEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 15,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> reminderMinutesGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 15,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> reminderMinutesGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 15,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> reminderMinutesLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 15,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> reminderMinutesLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 15,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> reminderMinutesBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 15,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> highPriorityReminderMinutesEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 16,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> highPriorityReminderMinutesGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 16,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> highPriorityReminderMinutesGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 16,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> highPriorityReminderMinutesLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 16,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> highPriorityReminderMinutesLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 16,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> highPriorityReminderMinutesBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 16,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> recoveryMinutesEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 17,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> recoveryMinutesGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 17,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> recoveryMinutesGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 17,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> recoveryMinutesLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 17,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> recoveryMinutesLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 17,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> recoveryMinutesBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 17,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursEnabledEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 18,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 19));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursStartIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 19));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursStartEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 19,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursStartGreaterThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 19,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursStartGreaterThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 19,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursStartLessThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 19,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursStartLessThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 19,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursStartBetween(
    DateTime? lower,
    DateTime? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 19,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursEndIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 20));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursEndIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 20));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursEndEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 20,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursEndGreaterThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 20,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursEndGreaterThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 20,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursEndLessThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 20,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursEndLessThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 20,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> quietHoursEndBetween(
    DateTime? lower,
    DateTime? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 20,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }
}

extension NotificationPreferencesQueryObject on QueryBuilder<
    NotificationPreferences, NotificationPreferences, QFilterCondition> {}

extension NotificationPreferencesQuerySortBy
    on QueryBuilder<NotificationPreferences, NotificationPreferences, QSortBy> {
  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByDeviceIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortBySmartNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortBySmartNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByNotifyStuffy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByNotifyStuffyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByNotifyPoor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByNotifyPoorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByNotifyImproved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByNotifyImprovedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByVibrationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByVibrationEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByShowInForeground() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByShowInForegroundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByStuffyThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByStuffyThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByBetterThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByBetterThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByPoorThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByPoorThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByStuffyPersistMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByStuffyPersistMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByBetterPersistMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByBetterPersistMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByPoorPersistMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByPoorPersistMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByReminderMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByReminderMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByHighPriorityReminderMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByHighPriorityReminderMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByRecoveryMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByRecoveryMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByQuietHoursEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByQuietHoursEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByQuietHoursStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByQuietHoursStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByQuietHoursEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(20);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByQuietHoursEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(20, sort: Sort.desc);
    });
  }
}

extension NotificationPreferencesQuerySortThenBy on QueryBuilder<
    NotificationPreferences, NotificationPreferences, QSortThenBy> {
  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByDeviceIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenBySmartNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenBySmartNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByNotifyStuffy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByNotifyStuffyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByNotifyPoor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByNotifyPoorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByNotifyImproved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByNotifyImprovedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByVibrationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByVibrationEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByShowInForeground() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByShowInForegroundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByRemindersEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByStuffyThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByStuffyThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByBetterThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByBetterThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByPoorThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByPoorThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByStuffyPersistMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByStuffyPersistMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByBetterPersistMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByBetterPersistMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByPoorPersistMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByPoorPersistMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByReminderMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByReminderMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByHighPriorityReminderMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByHighPriorityReminderMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByRecoveryMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByRecoveryMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByQuietHoursEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByQuietHoursEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByQuietHoursStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByQuietHoursStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByQuietHoursEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(20);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByQuietHoursEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(20, sort: Sort.desc);
    });
  }
}

extension NotificationPreferencesQueryWhereDistinct on QueryBuilder<
    NotificationPreferences, NotificationPreferences, QDistinct> {
  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctBySmartNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByNotifyStuffy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByNotifyPoor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByNotifyImproved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByVibrationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByShowInForeground() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByRemindersEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByStuffyThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByBetterThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByPoorThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByStuffyPersistMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(12);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByBetterPersistMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(13);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByPoorPersistMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(14);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByReminderMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(15);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByHighPriorityReminderMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(16);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByRecoveryMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(17);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByQuietHoursEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(18);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByQuietHoursStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(19);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByQuietHoursEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(20);
    });
  }
}

extension NotificationPreferencesQueryProperty1 on QueryBuilder<
    NotificationPreferences, NotificationPreferences, QProperty> {
  QueryBuilder<NotificationPreferences, String, QAfterProperty>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NotificationPreferences, bool, QAfterProperty>
      smartNotificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NotificationPreferences, bool, QAfterProperty>
      notifyStuffyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NotificationPreferences, bool, QAfterProperty>
      notifyPoorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NotificationPreferences, bool, QAfterProperty>
      notifyImprovedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<NotificationPreferences, bool, QAfterProperty>
      vibrationEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<NotificationPreferences, bool, QAfterProperty>
      showInForegroundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<NotificationPreferences, bool, QAfterProperty>
      remindersEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<NotificationPreferences, int, QAfterProperty>
      stuffyThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<NotificationPreferences, int, QAfterProperty>
      betterThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<NotificationPreferences, int, QAfterProperty>
      poorThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<NotificationPreferences, int, QAfterProperty>
      stuffyPersistMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<NotificationPreferences, int, QAfterProperty>
      betterPersistMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<NotificationPreferences, int, QAfterProperty>
      poorPersistMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<NotificationPreferences, int, QAfterProperty>
      reminderMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<NotificationPreferences, int, QAfterProperty>
      highPriorityReminderMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<NotificationPreferences, int, QAfterProperty>
      recoveryMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }

  QueryBuilder<NotificationPreferences, bool, QAfterProperty>
      quietHoursEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(18);
    });
  }

  QueryBuilder<NotificationPreferences, DateTime?, QAfterProperty>
      quietHoursStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(19);
    });
  }

  QueryBuilder<NotificationPreferences, DateTime?, QAfterProperty>
      quietHoursEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(20);
    });
  }
}

extension NotificationPreferencesQueryProperty2<R>
    on QueryBuilder<NotificationPreferences, R, QAfterProperty> {
  QueryBuilder<NotificationPreferences, (R, String), QAfterProperty>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NotificationPreferences, (R, bool), QAfterProperty>
      smartNotificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NotificationPreferences, (R, bool), QAfterProperty>
      notifyStuffyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NotificationPreferences, (R, bool), QAfterProperty>
      notifyPoorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NotificationPreferences, (R, bool), QAfterProperty>
      notifyImprovedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<NotificationPreferences, (R, bool), QAfterProperty>
      vibrationEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<NotificationPreferences, (R, bool), QAfterProperty>
      showInForegroundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<NotificationPreferences, (R, bool), QAfterProperty>
      remindersEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<NotificationPreferences, (R, int), QAfterProperty>
      stuffyThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<NotificationPreferences, (R, int), QAfterProperty>
      betterThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<NotificationPreferences, (R, int), QAfterProperty>
      poorThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<NotificationPreferences, (R, int), QAfterProperty>
      stuffyPersistMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<NotificationPreferences, (R, int), QAfterProperty>
      betterPersistMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<NotificationPreferences, (R, int), QAfterProperty>
      poorPersistMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<NotificationPreferences, (R, int), QAfterProperty>
      reminderMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<NotificationPreferences, (R, int), QAfterProperty>
      highPriorityReminderMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<NotificationPreferences, (R, int), QAfterProperty>
      recoveryMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }

  QueryBuilder<NotificationPreferences, (R, bool), QAfterProperty>
      quietHoursEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(18);
    });
  }

  QueryBuilder<NotificationPreferences, (R, DateTime?), QAfterProperty>
      quietHoursStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(19);
    });
  }

  QueryBuilder<NotificationPreferences, (R, DateTime?), QAfterProperty>
      quietHoursEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(20);
    });
  }
}

extension NotificationPreferencesQueryProperty3<R1, R2>
    on QueryBuilder<NotificationPreferences, (R1, R2), QAfterProperty> {
  QueryBuilder<NotificationPreferences, (R1, R2, String), QOperations>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, bool), QOperations>
      smartNotificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, bool), QOperations>
      notifyStuffyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, bool), QOperations>
      notifyPoorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, bool), QOperations>
      notifyImprovedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, bool), QOperations>
      vibrationEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, bool), QOperations>
      showInForegroundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, bool), QOperations>
      remindersEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, int), QOperations>
      stuffyThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, int), QOperations>
      betterThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, int), QOperations>
      poorThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, int), QOperations>
      stuffyPersistMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, int), QOperations>
      betterPersistMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, int), QOperations>
      poorPersistMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, int), QOperations>
      reminderMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, int), QOperations>
      highPriorityReminderMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, int), QOperations>
      recoveryMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, bool), QOperations>
      quietHoursEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(18);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, DateTime?), QOperations>
      quietHoursStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(19);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, DateTime?), QOperations>
      quietHoursEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(20);
    });
  }
}
