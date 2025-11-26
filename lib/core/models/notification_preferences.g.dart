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
        name: 'smartphoneNotificationsEnabled',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'notificationThresholds',
        type: IsarType.objectList,
        target: 'NotificationThreshold',
      ),
      IsarPropertySchema(
        name: 'notificationVibrationEnabled',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'showInForeground',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'cooldownMode',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'cooldownMinutes',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'lastNotificationTime',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'lastTriggeredThresholdValue',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'triggeredThresholds',
        type: IsarType.longList,
      ),
      IsarPropertySchema(
        name: 'canSendNotification',
        type: IsarType.bool,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, NotificationPreferences>(
    serialize: serializeNotificationPreferences,
    deserialize: deserializeNotificationPreferences,
    deserializeProperty: deserializeNotificationPreferencesProp,
  ),
  getEmbeddedSchemas: () => [NotificationThresholdSchema],
);

@isarProtected
int serializeNotificationPreferences(
    IsarWriter writer, NotificationPreferences object) {
  IsarCore.writeString(writer, 1, object.deviceId);
  IsarCore.writeBool(writer, 2, value: object.smartphoneNotificationsEnabled);
  {
    final list = object.notificationThresholds;
    final listWriter = IsarCore.beginList(writer, 3, list.length);
    for (var i = 0; i < list.length; i++) {
      {
        final value = list[i];
        final objectWriter = IsarCore.beginObject(listWriter, i);
        serializeNotificationThreshold(objectWriter, value);
        IsarCore.endObject(listWriter, objectWriter);
      }
    }
    IsarCore.endList(writer, listWriter);
  }
  IsarCore.writeBool(writer, 4, value: object.notificationVibrationEnabled);
  IsarCore.writeBool(writer, 5, value: object.showInForeground);
  IsarCore.writeString(writer, 6, object.cooldownMode);
  IsarCore.writeLong(writer, 7, object.cooldownMinutes);
  IsarCore.writeLong(
      writer,
      8,
      object.lastNotificationTime?.toUtc().microsecondsSinceEpoch ??
          -9223372036854775808);
  IsarCore.writeLong(
      writer, 9, object.lastTriggeredThresholdValue ?? -9223372036854775808);
  {
    final list = object.triggeredThresholds;
    final listWriter = IsarCore.beginList(writer, 10, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeLong(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  IsarCore.writeBool(writer, 11, value: object.canSendNotification);
  return Isar.fastHash(object.deviceId);
}

@isarProtected
NotificationPreferences deserializeNotificationPreferences(IsarReader reader) {
  final String _deviceId;
  _deviceId = IsarCore.readString(reader, 1) ?? '';
  final bool _smartphoneNotificationsEnabled;
  _smartphoneNotificationsEnabled = IsarCore.readBool(reader, 2);
  final List<NotificationThreshold> _notificationThresholds;
  {
    final length = IsarCore.readList(reader, 3, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        _notificationThresholds = defaultNotificationThresholds;
      } else {
        final list = List<NotificationThreshold>.filled(
            length,
            NotificationThreshold(
              id: -9223372036854775808,
              co2Threshold: -9223372036854775808,
              enabled: false,
            ),
            growable: true);
        for (var i = 0; i < length; i++) {
          {
            final objectReader = IsarCore.readObject(reader, i);
            if (objectReader.isNull) {
              list[i] = NotificationThreshold(
                id: -9223372036854775808,
                co2Threshold: -9223372036854775808,
                enabled: false,
              );
            } else {
              final embedded = deserializeNotificationThreshold(objectReader);
              IsarCore.freeReader(objectReader);
              list[i] = embedded;
            }
          }
        }
        IsarCore.freeReader(reader);
        _notificationThresholds = list;
      }
    }
  }
  final bool _notificationVibrationEnabled;
  {
    if (IsarCore.readNull(reader, 4)) {
      _notificationVibrationEnabled = true;
    } else {
      _notificationVibrationEnabled = IsarCore.readBool(reader, 4);
    }
  }
  final bool _showInForeground;
  {
    if (IsarCore.readNull(reader, 5)) {
      _showInForeground = true;
    } else {
      _showInForeground = IsarCore.readBool(reader, 5);
    }
  }
  final String _cooldownMode;
  _cooldownMode = IsarCore.readString(reader, 6) ?? 'once';
  final int _cooldownMinutes;
  {
    final value = IsarCore.readLong(reader, 7);
    if (value == -9223372036854775808) {
      _cooldownMinutes = 5;
    } else {
      _cooldownMinutes = value;
    }
  }
  final DateTime? _lastNotificationTime;
  {
    final value = IsarCore.readLong(reader, 8);
    if (value == -9223372036854775808) {
      _lastNotificationTime = null;
    } else {
      _lastNotificationTime =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final int? _lastTriggeredThresholdValue;
  {
    final value = IsarCore.readLong(reader, 9);
    if (value == -9223372036854775808) {
      _lastTriggeredThresholdValue = null;
    } else {
      _lastTriggeredThresholdValue = value;
    }
  }
  final List<int> _triggeredThresholds;
  {
    final length = IsarCore.readList(reader, 10, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        _triggeredThresholds = const [];
      } else {
        final list =
            List<int>.filled(length, -9223372036854775808, growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readLong(reader, i);
        }
        IsarCore.freeReader(reader);
        _triggeredThresholds = list;
      }
    }
  }
  final object = NotificationPreferences(
    deviceId: _deviceId,
    smartphoneNotificationsEnabled: _smartphoneNotificationsEnabled,
    notificationThresholds: _notificationThresholds,
    notificationVibrationEnabled: _notificationVibrationEnabled,
    showInForeground: _showInForeground,
    cooldownMode: _cooldownMode,
    cooldownMinutes: _cooldownMinutes,
    lastNotificationTime: _lastNotificationTime,
    lastTriggeredThresholdValue: _lastTriggeredThresholdValue,
    triggeredThresholds: _triggeredThresholds,
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
        final length = IsarCore.readList(reader, 3, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return defaultNotificationThresholds;
          } else {
            final list = List<NotificationThreshold>.filled(
                length,
                NotificationThreshold(
                  id: -9223372036854775808,
                  co2Threshold: -9223372036854775808,
                  enabled: false,
                ),
                growable: true);
            for (var i = 0; i < length; i++) {
              {
                final objectReader = IsarCore.readObject(reader, i);
                if (objectReader.isNull) {
                  list[i] = NotificationThreshold(
                    id: -9223372036854775808,
                    co2Threshold: -9223372036854775808,
                    enabled: false,
                  );
                } else {
                  final embedded =
                      deserializeNotificationThreshold(objectReader);
                  IsarCore.freeReader(objectReader);
                  list[i] = embedded;
                }
              }
            }
            IsarCore.freeReader(reader);
            return list;
          }
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
      return IsarCore.readString(reader, 6) ?? 'once';
    case 7:
      {
        final value = IsarCore.readLong(reader, 7);
        if (value == -9223372036854775808) {
          return 5;
        } else {
          return value;
        }
      }
    case 8:
      {
        final value = IsarCore.readLong(reader, 8);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 9:
      {
        final value = IsarCore.readLong(reader, 9);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 10:
      {
        final length = IsarCore.readList(reader, 10, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const [];
          } else {
            final list =
                List<int>.filled(length, -9223372036854775808, growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readLong(reader, i);
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    case 11:
      return IsarCore.readBool(reader, 11);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _NotificationPreferencesUpdate {
  bool call({
    required String deviceId,
    bool? smartphoneNotificationsEnabled,
    bool? notificationVibrationEnabled,
    bool? showInForeground,
    String? cooldownMode,
    int? cooldownMinutes,
    DateTime? lastNotificationTime,
    int? lastTriggeredThresholdValue,
    bool? canSendNotification,
  });
}

class _NotificationPreferencesUpdateImpl
    implements _NotificationPreferencesUpdate {
  const _NotificationPreferencesUpdateImpl(this.collection);

  final IsarCollection<String, NotificationPreferences> collection;

  @override
  bool call({
    required String deviceId,
    Object? smartphoneNotificationsEnabled = ignore,
    Object? notificationVibrationEnabled = ignore,
    Object? showInForeground = ignore,
    Object? cooldownMode = ignore,
    Object? cooldownMinutes = ignore,
    Object? lastNotificationTime = ignore,
    Object? lastTriggeredThresholdValue = ignore,
    Object? canSendNotification = ignore,
  }) {
    return collection.updateProperties([
          deviceId
        ], {
          if (smartphoneNotificationsEnabled != ignore)
            2: smartphoneNotificationsEnabled as bool?,
          if (notificationVibrationEnabled != ignore)
            4: notificationVibrationEnabled as bool?,
          if (showInForeground != ignore) 5: showInForeground as bool?,
          if (cooldownMode != ignore) 6: cooldownMode as String?,
          if (cooldownMinutes != ignore) 7: cooldownMinutes as int?,
          if (lastNotificationTime != ignore)
            8: lastNotificationTime as DateTime?,
          if (lastTriggeredThresholdValue != ignore)
            9: lastTriggeredThresholdValue as int?,
          if (canSendNotification != ignore) 11: canSendNotification as bool?,
        }) >
        0;
  }
}

sealed class _NotificationPreferencesUpdateAll {
  int call({
    required List<String> deviceId,
    bool? smartphoneNotificationsEnabled,
    bool? notificationVibrationEnabled,
    bool? showInForeground,
    String? cooldownMode,
    int? cooldownMinutes,
    DateTime? lastNotificationTime,
    int? lastTriggeredThresholdValue,
    bool? canSendNotification,
  });
}

class _NotificationPreferencesUpdateAllImpl
    implements _NotificationPreferencesUpdateAll {
  const _NotificationPreferencesUpdateAllImpl(this.collection);

  final IsarCollection<String, NotificationPreferences> collection;

  @override
  int call({
    required List<String> deviceId,
    Object? smartphoneNotificationsEnabled = ignore,
    Object? notificationVibrationEnabled = ignore,
    Object? showInForeground = ignore,
    Object? cooldownMode = ignore,
    Object? cooldownMinutes = ignore,
    Object? lastNotificationTime = ignore,
    Object? lastTriggeredThresholdValue = ignore,
    Object? canSendNotification = ignore,
  }) {
    return collection.updateProperties(deviceId, {
      if (smartphoneNotificationsEnabled != ignore)
        2: smartphoneNotificationsEnabled as bool?,
      if (notificationVibrationEnabled != ignore)
        4: notificationVibrationEnabled as bool?,
      if (showInForeground != ignore) 5: showInForeground as bool?,
      if (cooldownMode != ignore) 6: cooldownMode as String?,
      if (cooldownMinutes != ignore) 7: cooldownMinutes as int?,
      if (lastNotificationTime != ignore) 8: lastNotificationTime as DateTime?,
      if (lastTriggeredThresholdValue != ignore)
        9: lastTriggeredThresholdValue as int?,
      if (canSendNotification != ignore) 11: canSendNotification as bool?,
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
    bool? smartphoneNotificationsEnabled,
    bool? notificationVibrationEnabled,
    bool? showInForeground,
    String? cooldownMode,
    int? cooldownMinutes,
    DateTime? lastNotificationTime,
    int? lastTriggeredThresholdValue,
    bool? canSendNotification,
  });
}

class _NotificationPreferencesQueryUpdateImpl
    implements _NotificationPreferencesQueryUpdate {
  const _NotificationPreferencesQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<NotificationPreferences> query;
  final int? limit;

  @override
  int call({
    Object? smartphoneNotificationsEnabled = ignore,
    Object? notificationVibrationEnabled = ignore,
    Object? showInForeground = ignore,
    Object? cooldownMode = ignore,
    Object? cooldownMinutes = ignore,
    Object? lastNotificationTime = ignore,
    Object? lastTriggeredThresholdValue = ignore,
    Object? canSendNotification = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (smartphoneNotificationsEnabled != ignore)
        2: smartphoneNotificationsEnabled as bool?,
      if (notificationVibrationEnabled != ignore)
        4: notificationVibrationEnabled as bool?,
      if (showInForeground != ignore) 5: showInForeground as bool?,
      if (cooldownMode != ignore) 6: cooldownMode as String?,
      if (cooldownMinutes != ignore) 7: cooldownMinutes as int?,
      if (lastNotificationTime != ignore) 8: lastNotificationTime as DateTime?,
      if (lastTriggeredThresholdValue != ignore)
        9: lastTriggeredThresholdValue as int?,
      if (canSendNotification != ignore) 11: canSendNotification as bool?,
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
    Object? smartphoneNotificationsEnabled = ignore,
    Object? notificationVibrationEnabled = ignore,
    Object? showInForeground = ignore,
    Object? cooldownMode = ignore,
    Object? cooldownMinutes = ignore,
    Object? lastNotificationTime = ignore,
    Object? lastTriggeredThresholdValue = ignore,
    Object? canSendNotification = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (smartphoneNotificationsEnabled != ignore)
          2: smartphoneNotificationsEnabled as bool?,
        if (notificationVibrationEnabled != ignore)
          4: notificationVibrationEnabled as bool?,
        if (showInForeground != ignore) 5: showInForeground as bool?,
        if (cooldownMode != ignore) 6: cooldownMode as String?,
        if (cooldownMinutes != ignore) 7: cooldownMinutes as int?,
        if (lastNotificationTime != ignore)
          8: lastNotificationTime as DateTime?,
        if (lastTriggeredThresholdValue != ignore)
          9: lastTriggeredThresholdValue as int?,
        if (canSendNotification != ignore) 11: canSendNotification as bool?,
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
      QAfterFilterCondition> smartphoneNotificationsEnabledEqualTo(
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
      QAfterFilterCondition> notificationThresholdsIsEmpty() {
    return not().notificationThresholdsIsNotEmpty();
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> notificationThresholdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 3, value: null),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> notificationVibrationEnabledEqualTo(
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
      QAfterFilterCondition> showInForegroundEqualTo(
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
      QAfterFilterCondition> cooldownModeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> cooldownModeGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> cooldownModeGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> cooldownModeLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> cooldownModeLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> cooldownModeBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> cooldownModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> cooldownModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
          QAfterFilterCondition>
      cooldownModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
          QAfterFilterCondition>
      cooldownModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 6,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> cooldownModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> cooldownModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> cooldownMinutesEqualTo(
    int value,
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
      QAfterFilterCondition> cooldownMinutesGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> cooldownMinutesGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> cooldownMinutesLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> cooldownMinutesLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> cooldownMinutesBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> lastNotificationTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 8));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> lastNotificationTimeIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 8));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> lastNotificationTimeEqualTo(
    DateTime? value,
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
      QAfterFilterCondition> lastNotificationTimeGreaterThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> lastNotificationTimeGreaterThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> lastNotificationTimeLessThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> lastNotificationTimeLessThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> lastNotificationTimeBetween(
    DateTime? lower,
    DateTime? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 8,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> lastTriggeredThresholdValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> lastTriggeredThresholdValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> lastTriggeredThresholdValueEqualTo(
    int? value,
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
      QAfterFilterCondition> lastTriggeredThresholdValueGreaterThan(
    int? value,
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
      QAfterFilterCondition> lastTriggeredThresholdValueGreaterThanOrEqualTo(
    int? value,
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
      QAfterFilterCondition> lastTriggeredThresholdValueLessThan(
    int? value,
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
      QAfterFilterCondition> lastTriggeredThresholdValueLessThanOrEqualTo(
    int? value,
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
      QAfterFilterCondition> lastTriggeredThresholdValueBetween(
    int? lower,
    int? upper,
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
      QAfterFilterCondition> triggeredThresholdsElementEqualTo(
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
      QAfterFilterCondition> triggeredThresholdsElementGreaterThan(
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
      QAfterFilterCondition> triggeredThresholdsElementGreaterThanOrEqualTo(
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
      QAfterFilterCondition> triggeredThresholdsElementLessThan(
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
      QAfterFilterCondition> triggeredThresholdsElementLessThanOrEqualTo(
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
      QAfterFilterCondition> triggeredThresholdsElementBetween(
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
      QAfterFilterCondition> triggeredThresholdsIsEmpty() {
    return not().triggeredThresholdsIsNotEmpty();
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> triggeredThresholdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 10, value: null),
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences,
      QAfterFilterCondition> canSendNotificationEqualTo(
    bool value,
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
      sortBySmartphoneNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortBySmartphoneNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByNotificationVibrationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByNotificationVibrationEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByShowInForeground() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByShowInForegroundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByCooldownMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByCooldownModeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByCooldownMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByCooldownMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByLastNotificationTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByLastNotificationTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByLastTriggeredThresholdValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByLastTriggeredThresholdValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByCanSendNotification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      sortByCanSendNotificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
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
      thenBySmartphoneNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenBySmartphoneNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByNotificationVibrationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByNotificationVibrationEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByShowInForeground() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByShowInForegroundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByCooldownMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByCooldownModeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByCooldownMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByCooldownMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByLastNotificationTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByLastNotificationTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByLastTriggeredThresholdValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByLastTriggeredThresholdValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByCanSendNotification() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterSortBy>
      thenByCanSendNotificationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }
}

extension NotificationPreferencesQueryWhereDistinct on QueryBuilder<
    NotificationPreferences, NotificationPreferences, QDistinct> {
  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctBySmartphoneNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByNotificationVibrationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByShowInForeground() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByCooldownMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByCooldownMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByLastNotificationTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByLastTriggeredThresholdValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByTriggeredThresholds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }

  QueryBuilder<NotificationPreferences, NotificationPreferences, QAfterDistinct>
      distinctByCanSendNotification() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11);
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
      smartphoneNotificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NotificationPreferences, List<NotificationThreshold>,
      QAfterProperty> notificationThresholdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NotificationPreferences, bool, QAfterProperty>
      notificationVibrationEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NotificationPreferences, bool, QAfterProperty>
      showInForegroundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<NotificationPreferences, String, QAfterProperty>
      cooldownModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<NotificationPreferences, int, QAfterProperty>
      cooldownMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<NotificationPreferences, DateTime?, QAfterProperty>
      lastNotificationTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<NotificationPreferences, int?, QAfterProperty>
      lastTriggeredThresholdValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<NotificationPreferences, List<int>, QAfterProperty>
      triggeredThresholdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<NotificationPreferences, bool, QAfterProperty>
      canSendNotificationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
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
      smartphoneNotificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NotificationPreferences, (R, List<NotificationThreshold>),
      QAfterProperty> notificationThresholdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NotificationPreferences, (R, bool), QAfterProperty>
      notificationVibrationEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NotificationPreferences, (R, bool), QAfterProperty>
      showInForegroundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<NotificationPreferences, (R, String), QAfterProperty>
      cooldownModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<NotificationPreferences, (R, int), QAfterProperty>
      cooldownMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<NotificationPreferences, (R, DateTime?), QAfterProperty>
      lastNotificationTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<NotificationPreferences, (R, int?), QAfterProperty>
      lastTriggeredThresholdValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<NotificationPreferences, (R, List<int>), QAfterProperty>
      triggeredThresholdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<NotificationPreferences, (R, bool), QAfterProperty>
      canSendNotificationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
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
      smartphoneNotificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, List<NotificationThreshold>),
      QOperations> notificationThresholdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, bool), QOperations>
      notificationVibrationEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, bool), QOperations>
      showInForegroundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, String), QOperations>
      cooldownModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, int), QOperations>
      cooldownMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, DateTime?), QOperations>
      lastNotificationTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, int?), QOperations>
      lastTriggeredThresholdValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, List<int>), QOperations>
      triggeredThresholdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<NotificationPreferences, (R1, R2, bool), QOperations>
      canSendNotificationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }
}

// **************************************************************************
// _IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

final NotificationThresholdSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'NotificationThreshold',
    embedded: true,
    properties: [
      IsarPropertySchema(
        name: 'id',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'co2Threshold',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'enabled',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'message',
        type: IsarType.string,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<void, NotificationThreshold>(
    serialize: serializeNotificationThreshold,
    deserialize: deserializeNotificationThreshold,
  ),
);

@isarProtected
int serializeNotificationThreshold(
    IsarWriter writer, NotificationThreshold object) {
  IsarCore.writeLong(writer, 1, object.id);
  IsarCore.writeLong(writer, 2, object.co2Threshold);
  IsarCore.writeBool(writer, 3, value: object.enabled);
  {
    final value = object.message;
    if (value == null) {
      IsarCore.writeNull(writer, 4);
    } else {
      IsarCore.writeString(writer, 4, value);
    }
  }
  return 0;
}

@isarProtected
NotificationThreshold deserializeNotificationThreshold(IsarReader reader) {
  final int _id;
  _id = IsarCore.readLong(reader, 1);
  final int _co2Threshold;
  _co2Threshold = IsarCore.readLong(reader, 2);
  final bool _enabled;
  _enabled = IsarCore.readBool(reader, 3);
  final String? _message;
  _message = IsarCore.readString(reader, 4);
  final object = NotificationThreshold(
    id: _id,
    co2Threshold: _co2Threshold,
    enabled: _enabled,
    message: _message,
  );
  return object;
}

extension NotificationThresholdQueryFilter on QueryBuilder<
    NotificationThreshold, NotificationThreshold, QFilterCondition> {
  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> idGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> co2ThresholdEqualTo(
    int value,
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

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> co2ThresholdGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> co2ThresholdGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> co2ThresholdLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> co2ThresholdLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> co2ThresholdBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> enabledEqualTo(
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

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> messageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> messageIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> messageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> messageGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> messageGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> messageLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> messageLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> messageBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> messageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> messageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
          QAfterFilterCondition>
      messageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
          QAfterFilterCondition>
      messageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 4,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> messageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NotificationThreshold, NotificationThreshold,
      QAfterFilterCondition> messageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }
}

extension NotificationThresholdQueryObject on QueryBuilder<
    NotificationThreshold, NotificationThreshold, QFilterCondition> {}
