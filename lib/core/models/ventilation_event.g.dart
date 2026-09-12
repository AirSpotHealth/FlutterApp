// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ventilation_event.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetVentilationEventCollection on Isar {
  IsarCollection<String, VentilationEvent> get ventilationEvents =>
      this.collection();
}

final VentilationEventSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'VentilationEvent',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'id',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'deviceId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'deviceName',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'startedAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'endedAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'status',
        type: IsarType.byte,
        enumMap: {"active": 0, "recovered": 1, "expired": 2},
      ),
      IsarPropertySchema(
        name: 'startValue',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'peakValue',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'peakAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'lastValue',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'lastReadingAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'highestLevelNotified',
        type: IsarType.byte,
        enumMap: {"none": 0, "stuffy": 1, "better": 2, "poor": 3},
      ),
      IsarPropertySchema(
        name: 'notifications',
        type: IsarType.objectList,
        target: 'VentilationNotificationRecord',
      ),
      IsarPropertySchema(
        name: 'userAction',
        type: IsarType.byte,
        enumMap: {
          "none": 0,
          "openedWindowOrDoor": 1,
          "increasedVentilation": 2,
          "movedElsewhere": 3,
          "reducedOccupancy": 4,
          "somethingElse": 5
        },
      ),
      IsarPropertySchema(
        name: 'userActionAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'reminderDueAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'reminderLevel',
        type: IsarType.byte,
        enumMap: {"none": 0, "stuffy": 1, "better": 2, "poor": 3},
      ),
      IsarPropertySchema(
        name: 'recoveredAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'recoveryValue',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'recoveryNotified',
        type: IsarType.bool,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'deviceId',
        properties: [
          "deviceId",
        ],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<String, VentilationEvent>(
    serialize: serializeVentilationEvent,
    deserialize: deserializeVentilationEvent,
    deserializeProperty: deserializeVentilationEventProp,
  ),
  getEmbeddedSchemas: () => [VentilationNotificationRecordSchema],
);

@isarProtected
int serializeVentilationEvent(IsarWriter writer, VentilationEvent object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.deviceId);
  IsarCore.writeString(writer, 3, object.deviceName);
  IsarCore.writeLong(
      writer, 4, object.startedAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(writer, 5,
      object.endedAt?.toUtc().microsecondsSinceEpoch ?? -9223372036854775808);
  IsarCore.writeByte(writer, 6, object.status.index);
  IsarCore.writeLong(writer, 7, object.startValue);
  IsarCore.writeLong(writer, 8, object.peakValue);
  IsarCore.writeLong(writer, 9, object.peakAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(writer, 10, object.lastValue);
  IsarCore.writeLong(
      writer, 11, object.lastReadingAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeByte(writer, 12, object.highestLevelNotified.index);
  {
    final list = object.notifications;
    final listWriter = IsarCore.beginList(writer, 13, list.length);
    for (var i = 0; i < list.length; i++) {
      {
        final value = list[i];
        final objectWriter = IsarCore.beginObject(listWriter, i);
        serializeVentilationNotificationRecord(objectWriter, value);
        IsarCore.endObject(listWriter, objectWriter);
      }
    }
    IsarCore.endList(writer, listWriter);
  }
  IsarCore.writeByte(writer, 14, object.userAction.index);
  IsarCore.writeLong(
      writer,
      15,
      object.userActionAt?.toUtc().microsecondsSinceEpoch ??
          -9223372036854775808);
  IsarCore.writeLong(
      writer,
      16,
      object.reminderDueAt?.toUtc().microsecondsSinceEpoch ??
          -9223372036854775808);
  IsarCore.writeByte(writer, 17, object.reminderLevel.index);
  IsarCore.writeLong(
      writer,
      18,
      object.recoveredAt?.toUtc().microsecondsSinceEpoch ??
          -9223372036854775808);
  IsarCore.writeLong(writer, 19, object.recoveryValue ?? -9223372036854775808);
  IsarCore.writeBool(writer, 20, value: object.recoveryNotified);
  return Isar.fastHash(object.id);
}

@isarProtected
VentilationEvent deserializeVentilationEvent(IsarReader reader) {
  final String _id;
  _id = IsarCore.readString(reader, 1) ?? '';
  final String _deviceId;
  _deviceId = IsarCore.readString(reader, 2) ?? '';
  final String _deviceName;
  _deviceName = IsarCore.readString(reader, 3) ?? '';
  final DateTime _startedAt;
  {
    final value = IsarCore.readLong(reader, 4);
    if (value == -9223372036854775808) {
      _startedAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _startedAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final DateTime? _endedAt;
  {
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      _endedAt = null;
    } else {
      _endedAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final VentilationEventStatus _status;
  {
    if (IsarCore.readNull(reader, 6)) {
      _status = VentilationEventStatus.active;
    } else {
      _status = _ventilationEventStatus[IsarCore.readByte(reader, 6)] ??
          VentilationEventStatus.active;
    }
  }
  final int _startValue;
  _startValue = IsarCore.readLong(reader, 7);
  final int _peakValue;
  _peakValue = IsarCore.readLong(reader, 8);
  final DateTime _peakAt;
  {
    final value = IsarCore.readLong(reader, 9);
    if (value == -9223372036854775808) {
      _peakAt = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _peakAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final int _lastValue;
  _lastValue = IsarCore.readLong(reader, 10);
  final DateTime _lastReadingAt;
  {
    final value = IsarCore.readLong(reader, 11);
    if (value == -9223372036854775808) {
      _lastReadingAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _lastReadingAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final VentilationLevel _highestLevelNotified;
  {
    if (IsarCore.readNull(reader, 12)) {
      _highestLevelNotified = VentilationLevel.none;
    } else {
      _highestLevelNotified = _ventilationEventHighestLevelNotified[
              IsarCore.readByte(reader, 12)] ??
          VentilationLevel.none;
    }
  }
  final List<VentilationNotificationRecord> _notifications;
  {
    final length = IsarCore.readList(reader, 13, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        _notifications = const [];
      } else {
        final list = List<VentilationNotificationRecord>.filled(
            length, VentilationNotificationRecord(),
            growable: true);
        for (var i = 0; i < length; i++) {
          {
            final objectReader = IsarCore.readObject(reader, i);
            if (objectReader.isNull) {
              list[i] = VentilationNotificationRecord();
            } else {
              final embedded =
                  deserializeVentilationNotificationRecord(objectReader);
              IsarCore.freeReader(objectReader);
              list[i] = embedded;
            }
          }
        }
        IsarCore.freeReader(reader);
        _notifications = list;
      }
    }
  }
  final VentilationUserAction _userAction;
  {
    if (IsarCore.readNull(reader, 14)) {
      _userAction = VentilationUserAction.none;
    } else {
      _userAction =
          _ventilationEventUserAction[IsarCore.readByte(reader, 14)] ??
              VentilationUserAction.none;
    }
  }
  final DateTime? _userActionAt;
  {
    final value = IsarCore.readLong(reader, 15);
    if (value == -9223372036854775808) {
      _userActionAt = null;
    } else {
      _userActionAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final DateTime? _reminderDueAt;
  {
    final value = IsarCore.readLong(reader, 16);
    if (value == -9223372036854775808) {
      _reminderDueAt = null;
    } else {
      _reminderDueAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final VentilationLevel _reminderLevel;
  {
    if (IsarCore.readNull(reader, 17)) {
      _reminderLevel = VentilationLevel.none;
    } else {
      _reminderLevel =
          _ventilationEventReminderLevel[IsarCore.readByte(reader, 17)] ??
              VentilationLevel.none;
    }
  }
  final DateTime? _recoveredAt;
  {
    final value = IsarCore.readLong(reader, 18);
    if (value == -9223372036854775808) {
      _recoveredAt = null;
    } else {
      _recoveredAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final int? _recoveryValue;
  {
    final value = IsarCore.readLong(reader, 19);
    if (value == -9223372036854775808) {
      _recoveryValue = null;
    } else {
      _recoveryValue = value;
    }
  }
  final bool _recoveryNotified;
  _recoveryNotified = IsarCore.readBool(reader, 20);
  final object = VentilationEvent(
    id: _id,
    deviceId: _deviceId,
    deviceName: _deviceName,
    startedAt: _startedAt,
    endedAt: _endedAt,
    status: _status,
    startValue: _startValue,
    peakValue: _peakValue,
    peakAt: _peakAt,
    lastValue: _lastValue,
    lastReadingAt: _lastReadingAt,
    highestLevelNotified: _highestLevelNotified,
    notifications: _notifications,
    userAction: _userAction,
    userActionAt: _userActionAt,
    reminderDueAt: _reminderDueAt,
    reminderLevel: _reminderLevel,
    recoveredAt: _recoveredAt,
    recoveryValue: _recoveryValue,
    recoveryNotified: _recoveryNotified,
  );
  return object;
}

@isarProtected
dynamic deserializeVentilationEventProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      {
        final value = IsarCore.readLong(reader, 4);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 5:
      {
        final value = IsarCore.readLong(reader, 5);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 6:
      {
        if (IsarCore.readNull(reader, 6)) {
          return VentilationEventStatus.active;
        } else {
          return _ventilationEventStatus[IsarCore.readByte(reader, 6)] ??
              VentilationEventStatus.active;
        }
      }
    case 7:
      return IsarCore.readLong(reader, 7);
    case 8:
      return IsarCore.readLong(reader, 8);
    case 9:
      {
        final value = IsarCore.readLong(reader, 9);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 10:
      return IsarCore.readLong(reader, 10);
    case 11:
      {
        final value = IsarCore.readLong(reader, 11);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 12:
      {
        if (IsarCore.readNull(reader, 12)) {
          return VentilationLevel.none;
        } else {
          return _ventilationEventHighestLevelNotified[
                  IsarCore.readByte(reader, 12)] ??
              VentilationLevel.none;
        }
      }
    case 13:
      {
        final length = IsarCore.readList(reader, 13, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const [];
          } else {
            final list = List<VentilationNotificationRecord>.filled(
                length, VentilationNotificationRecord(),
                growable: true);
            for (var i = 0; i < length; i++) {
              {
                final objectReader = IsarCore.readObject(reader, i);
                if (objectReader.isNull) {
                  list[i] = VentilationNotificationRecord();
                } else {
                  final embedded =
                      deserializeVentilationNotificationRecord(objectReader);
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
    case 14:
      {
        if (IsarCore.readNull(reader, 14)) {
          return VentilationUserAction.none;
        } else {
          return _ventilationEventUserAction[IsarCore.readByte(reader, 14)] ??
              VentilationUserAction.none;
        }
      }
    case 15:
      {
        final value = IsarCore.readLong(reader, 15);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 16:
      {
        final value = IsarCore.readLong(reader, 16);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 17:
      {
        if (IsarCore.readNull(reader, 17)) {
          return VentilationLevel.none;
        } else {
          return _ventilationEventReminderLevel[
                  IsarCore.readByte(reader, 17)] ??
              VentilationLevel.none;
        }
      }
    case 18:
      {
        final value = IsarCore.readLong(reader, 18);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 19:
      {
        final value = IsarCore.readLong(reader, 19);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 20:
      return IsarCore.readBool(reader, 20);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _VentilationEventUpdate {
  bool call({
    required String id,
    String? deviceId,
    String? deviceName,
    DateTime? startedAt,
    DateTime? endedAt,
    VentilationEventStatus? status,
    int? startValue,
    int? peakValue,
    DateTime? peakAt,
    int? lastValue,
    DateTime? lastReadingAt,
    VentilationLevel? highestLevelNotified,
    VentilationUserAction? userAction,
    DateTime? userActionAt,
    DateTime? reminderDueAt,
    VentilationLevel? reminderLevel,
    DateTime? recoveredAt,
    int? recoveryValue,
    bool? recoveryNotified,
  });
}

class _VentilationEventUpdateImpl implements _VentilationEventUpdate {
  const _VentilationEventUpdateImpl(this.collection);

  final IsarCollection<String, VentilationEvent> collection;

  @override
  bool call({
    required String id,
    Object? deviceId = ignore,
    Object? deviceName = ignore,
    Object? startedAt = ignore,
    Object? endedAt = ignore,
    Object? status = ignore,
    Object? startValue = ignore,
    Object? peakValue = ignore,
    Object? peakAt = ignore,
    Object? lastValue = ignore,
    Object? lastReadingAt = ignore,
    Object? highestLevelNotified = ignore,
    Object? userAction = ignore,
    Object? userActionAt = ignore,
    Object? reminderDueAt = ignore,
    Object? reminderLevel = ignore,
    Object? recoveredAt = ignore,
    Object? recoveryValue = ignore,
    Object? recoveryNotified = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (deviceId != ignore) 2: deviceId as String?,
          if (deviceName != ignore) 3: deviceName as String?,
          if (startedAt != ignore) 4: startedAt as DateTime?,
          if (endedAt != ignore) 5: endedAt as DateTime?,
          if (status != ignore) 6: status as VentilationEventStatus?,
          if (startValue != ignore) 7: startValue as int?,
          if (peakValue != ignore) 8: peakValue as int?,
          if (peakAt != ignore) 9: peakAt as DateTime?,
          if (lastValue != ignore) 10: lastValue as int?,
          if (lastReadingAt != ignore) 11: lastReadingAt as DateTime?,
          if (highestLevelNotified != ignore)
            12: highestLevelNotified as VentilationLevel?,
          if (userAction != ignore) 14: userAction as VentilationUserAction?,
          if (userActionAt != ignore) 15: userActionAt as DateTime?,
          if (reminderDueAt != ignore) 16: reminderDueAt as DateTime?,
          if (reminderLevel != ignore) 17: reminderLevel as VentilationLevel?,
          if (recoveredAt != ignore) 18: recoveredAt as DateTime?,
          if (recoveryValue != ignore) 19: recoveryValue as int?,
          if (recoveryNotified != ignore) 20: recoveryNotified as bool?,
        }) >
        0;
  }
}

sealed class _VentilationEventUpdateAll {
  int call({
    required List<String> id,
    String? deviceId,
    String? deviceName,
    DateTime? startedAt,
    DateTime? endedAt,
    VentilationEventStatus? status,
    int? startValue,
    int? peakValue,
    DateTime? peakAt,
    int? lastValue,
    DateTime? lastReadingAt,
    VentilationLevel? highestLevelNotified,
    VentilationUserAction? userAction,
    DateTime? userActionAt,
    DateTime? reminderDueAt,
    VentilationLevel? reminderLevel,
    DateTime? recoveredAt,
    int? recoveryValue,
    bool? recoveryNotified,
  });
}

class _VentilationEventUpdateAllImpl implements _VentilationEventUpdateAll {
  const _VentilationEventUpdateAllImpl(this.collection);

  final IsarCollection<String, VentilationEvent> collection;

  @override
  int call({
    required List<String> id,
    Object? deviceId = ignore,
    Object? deviceName = ignore,
    Object? startedAt = ignore,
    Object? endedAt = ignore,
    Object? status = ignore,
    Object? startValue = ignore,
    Object? peakValue = ignore,
    Object? peakAt = ignore,
    Object? lastValue = ignore,
    Object? lastReadingAt = ignore,
    Object? highestLevelNotified = ignore,
    Object? userAction = ignore,
    Object? userActionAt = ignore,
    Object? reminderDueAt = ignore,
    Object? reminderLevel = ignore,
    Object? recoveredAt = ignore,
    Object? recoveryValue = ignore,
    Object? recoveryNotified = ignore,
  }) {
    return collection.updateProperties(id, {
      if (deviceId != ignore) 2: deviceId as String?,
      if (deviceName != ignore) 3: deviceName as String?,
      if (startedAt != ignore) 4: startedAt as DateTime?,
      if (endedAt != ignore) 5: endedAt as DateTime?,
      if (status != ignore) 6: status as VentilationEventStatus?,
      if (startValue != ignore) 7: startValue as int?,
      if (peakValue != ignore) 8: peakValue as int?,
      if (peakAt != ignore) 9: peakAt as DateTime?,
      if (lastValue != ignore) 10: lastValue as int?,
      if (lastReadingAt != ignore) 11: lastReadingAt as DateTime?,
      if (highestLevelNotified != ignore)
        12: highestLevelNotified as VentilationLevel?,
      if (userAction != ignore) 14: userAction as VentilationUserAction?,
      if (userActionAt != ignore) 15: userActionAt as DateTime?,
      if (reminderDueAt != ignore) 16: reminderDueAt as DateTime?,
      if (reminderLevel != ignore) 17: reminderLevel as VentilationLevel?,
      if (recoveredAt != ignore) 18: recoveredAt as DateTime?,
      if (recoveryValue != ignore) 19: recoveryValue as int?,
      if (recoveryNotified != ignore) 20: recoveryNotified as bool?,
    });
  }
}

extension VentilationEventUpdate on IsarCollection<String, VentilationEvent> {
  _VentilationEventUpdate get update => _VentilationEventUpdateImpl(this);

  _VentilationEventUpdateAll get updateAll =>
      _VentilationEventUpdateAllImpl(this);
}

sealed class _VentilationEventQueryUpdate {
  int call({
    String? deviceId,
    String? deviceName,
    DateTime? startedAt,
    DateTime? endedAt,
    VentilationEventStatus? status,
    int? startValue,
    int? peakValue,
    DateTime? peakAt,
    int? lastValue,
    DateTime? lastReadingAt,
    VentilationLevel? highestLevelNotified,
    VentilationUserAction? userAction,
    DateTime? userActionAt,
    DateTime? reminderDueAt,
    VentilationLevel? reminderLevel,
    DateTime? recoveredAt,
    int? recoveryValue,
    bool? recoveryNotified,
  });
}

class _VentilationEventQueryUpdateImpl implements _VentilationEventQueryUpdate {
  const _VentilationEventQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<VentilationEvent> query;
  final int? limit;

  @override
  int call({
    Object? deviceId = ignore,
    Object? deviceName = ignore,
    Object? startedAt = ignore,
    Object? endedAt = ignore,
    Object? status = ignore,
    Object? startValue = ignore,
    Object? peakValue = ignore,
    Object? peakAt = ignore,
    Object? lastValue = ignore,
    Object? lastReadingAt = ignore,
    Object? highestLevelNotified = ignore,
    Object? userAction = ignore,
    Object? userActionAt = ignore,
    Object? reminderDueAt = ignore,
    Object? reminderLevel = ignore,
    Object? recoveredAt = ignore,
    Object? recoveryValue = ignore,
    Object? recoveryNotified = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (deviceId != ignore) 2: deviceId as String?,
      if (deviceName != ignore) 3: deviceName as String?,
      if (startedAt != ignore) 4: startedAt as DateTime?,
      if (endedAt != ignore) 5: endedAt as DateTime?,
      if (status != ignore) 6: status as VentilationEventStatus?,
      if (startValue != ignore) 7: startValue as int?,
      if (peakValue != ignore) 8: peakValue as int?,
      if (peakAt != ignore) 9: peakAt as DateTime?,
      if (lastValue != ignore) 10: lastValue as int?,
      if (lastReadingAt != ignore) 11: lastReadingAt as DateTime?,
      if (highestLevelNotified != ignore)
        12: highestLevelNotified as VentilationLevel?,
      if (userAction != ignore) 14: userAction as VentilationUserAction?,
      if (userActionAt != ignore) 15: userActionAt as DateTime?,
      if (reminderDueAt != ignore) 16: reminderDueAt as DateTime?,
      if (reminderLevel != ignore) 17: reminderLevel as VentilationLevel?,
      if (recoveredAt != ignore) 18: recoveredAt as DateTime?,
      if (recoveryValue != ignore) 19: recoveryValue as int?,
      if (recoveryNotified != ignore) 20: recoveryNotified as bool?,
    });
  }
}

extension VentilationEventQueryUpdate on IsarQuery<VentilationEvent> {
  _VentilationEventQueryUpdate get updateFirst =>
      _VentilationEventQueryUpdateImpl(this, limit: 1);

  _VentilationEventQueryUpdate get updateAll =>
      _VentilationEventQueryUpdateImpl(this);
}

class _VentilationEventQueryBuilderUpdateImpl
    implements _VentilationEventQueryUpdate {
  const _VentilationEventQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<VentilationEvent, VentilationEvent, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? deviceId = ignore,
    Object? deviceName = ignore,
    Object? startedAt = ignore,
    Object? endedAt = ignore,
    Object? status = ignore,
    Object? startValue = ignore,
    Object? peakValue = ignore,
    Object? peakAt = ignore,
    Object? lastValue = ignore,
    Object? lastReadingAt = ignore,
    Object? highestLevelNotified = ignore,
    Object? userAction = ignore,
    Object? userActionAt = ignore,
    Object? reminderDueAt = ignore,
    Object? reminderLevel = ignore,
    Object? recoveredAt = ignore,
    Object? recoveryValue = ignore,
    Object? recoveryNotified = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (deviceId != ignore) 2: deviceId as String?,
        if (deviceName != ignore) 3: deviceName as String?,
        if (startedAt != ignore) 4: startedAt as DateTime?,
        if (endedAt != ignore) 5: endedAt as DateTime?,
        if (status != ignore) 6: status as VentilationEventStatus?,
        if (startValue != ignore) 7: startValue as int?,
        if (peakValue != ignore) 8: peakValue as int?,
        if (peakAt != ignore) 9: peakAt as DateTime?,
        if (lastValue != ignore) 10: lastValue as int?,
        if (lastReadingAt != ignore) 11: lastReadingAt as DateTime?,
        if (highestLevelNotified != ignore)
          12: highestLevelNotified as VentilationLevel?,
        if (userAction != ignore) 14: userAction as VentilationUserAction?,
        if (userActionAt != ignore) 15: userActionAt as DateTime?,
        if (reminderDueAt != ignore) 16: reminderDueAt as DateTime?,
        if (reminderLevel != ignore) 17: reminderLevel as VentilationLevel?,
        if (recoveredAt != ignore) 18: recoveredAt as DateTime?,
        if (recoveryValue != ignore) 19: recoveryValue as int?,
        if (recoveryNotified != ignore) 20: recoveryNotified as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension VentilationEventQueryBuilderUpdate
    on QueryBuilder<VentilationEvent, VentilationEvent, QOperations> {
  _VentilationEventQueryUpdate get updateFirst =>
      _VentilationEventQueryBuilderUpdateImpl(this, limit: 1);

  _VentilationEventQueryUpdate get updateAll =>
      _VentilationEventQueryBuilderUpdateImpl(this);
}

const _ventilationEventStatus = {
  0: VentilationEventStatus.active,
  1: VentilationEventStatus.recovered,
  2: VentilationEventStatus.expired,
};
const _ventilationEventHighestLevelNotified = {
  0: VentilationLevel.none,
  1: VentilationLevel.stuffy,
  2: VentilationLevel.better,
  3: VentilationLevel.poor,
};
const _ventilationEventUserAction = {
  0: VentilationUserAction.none,
  1: VentilationUserAction.openedWindowOrDoor,
  2: VentilationUserAction.increasedVentilation,
  3: VentilationUserAction.movedElsewhere,
  4: VentilationUserAction.reducedOccupancy,
  5: VentilationUserAction.somethingElse,
};
const _ventilationEventReminderLevel = {
  0: VentilationLevel.none,
  1: VentilationLevel.stuffy,
  2: VentilationLevel.better,
  3: VentilationLevel.poor,
};

extension VentilationEventQueryFilter
    on QueryBuilder<VentilationEvent, VentilationEvent, QFilterCondition> {
  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      idEqualTo(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      idLessThanOrEqualTo(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      idStartsWith(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      idEndsWith(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceIdGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceIdGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceIdLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceIdLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceIdBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceNameGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceNameGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceNameLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceNameLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceNameBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      deviceNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      startedAtEqualTo(
    DateTime value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      startedAtGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      startedAtGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      startedAtLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      startedAtLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      startedAtBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      endedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      endedAtIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      endedAtEqualTo(
    DateTime? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      endedAtGreaterThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      endedAtGreaterThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      endedAtLessThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      endedAtLessThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      endedAtBetween(
    DateTime? lower,
    DateTime? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      statusEqualTo(
    VentilationEventStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      statusGreaterThan(
    VentilationEventStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      statusGreaterThanOrEqualTo(
    VentilationEventStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      statusLessThan(
    VentilationEventStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      statusLessThanOrEqualTo(
    VentilationEventStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      statusBetween(
    VentilationEventStatus lower,
    VentilationEventStatus upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      startValueEqualTo(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      startValueGreaterThan(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      startValueGreaterThanOrEqualTo(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      startValueLessThan(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      startValueLessThanOrEqualTo(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      startValueBetween(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      peakValueEqualTo(
    int value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      peakValueGreaterThan(
    int value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      peakValueGreaterThanOrEqualTo(
    int value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      peakValueLessThan(
    int value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      peakValueLessThanOrEqualTo(
    int value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      peakValueBetween(
    int lower,
    int upper,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      peakAtEqualTo(
    DateTime value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      peakAtGreaterThan(
    DateTime value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      peakAtGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      peakAtLessThan(
    DateTime value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      peakAtLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      peakAtBetween(
    DateTime lower,
    DateTime upper,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      lastValueEqualTo(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      lastValueGreaterThan(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      lastValueGreaterThanOrEqualTo(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      lastValueLessThan(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      lastValueLessThanOrEqualTo(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      lastValueBetween(
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      lastReadingAtEqualTo(
    DateTime value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      lastReadingAtGreaterThan(
    DateTime value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      lastReadingAtGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      lastReadingAtLessThan(
    DateTime value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      lastReadingAtLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      lastReadingAtBetween(
    DateTime lower,
    DateTime upper,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      highestLevelNotifiedEqualTo(
    VentilationLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 12,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      highestLevelNotifiedGreaterThan(
    VentilationLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 12,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      highestLevelNotifiedGreaterThanOrEqualTo(
    VentilationLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 12,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      highestLevelNotifiedLessThan(
    VentilationLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 12,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      highestLevelNotifiedLessThanOrEqualTo(
    VentilationLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 12,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      highestLevelNotifiedBetween(
    VentilationLevel lower,
    VentilationLevel upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 12,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      notificationsIsEmpty() {
    return not().notificationsIsNotEmpty();
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      notificationsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 13, value: null),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      userActionEqualTo(
    VentilationUserAction value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 14,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      userActionGreaterThan(
    VentilationUserAction value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 14,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      userActionGreaterThanOrEqualTo(
    VentilationUserAction value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 14,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      userActionLessThan(
    VentilationUserAction value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 14,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      userActionLessThanOrEqualTo(
    VentilationUserAction value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 14,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      userActionBetween(
    VentilationUserAction lower,
    VentilationUserAction upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 14,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      userActionAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 15));
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      userActionAtIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 15));
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      userActionAtEqualTo(
    DateTime? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      userActionAtGreaterThan(
    DateTime? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      userActionAtGreaterThanOrEqualTo(
    DateTime? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      userActionAtLessThan(
    DateTime? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      userActionAtLessThanOrEqualTo(
    DateTime? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      userActionAtBetween(
    DateTime? lower,
    DateTime? upper,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      reminderDueAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 16));
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      reminderDueAtIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 16));
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      reminderDueAtEqualTo(
    DateTime? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      reminderDueAtGreaterThan(
    DateTime? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      reminderDueAtGreaterThanOrEqualTo(
    DateTime? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      reminderDueAtLessThan(
    DateTime? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      reminderDueAtLessThanOrEqualTo(
    DateTime? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      reminderDueAtBetween(
    DateTime? lower,
    DateTime? upper,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      reminderLevelEqualTo(
    VentilationLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 17,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      reminderLevelGreaterThan(
    VentilationLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 17,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      reminderLevelGreaterThanOrEqualTo(
    VentilationLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 17,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      reminderLevelLessThan(
    VentilationLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 17,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      reminderLevelLessThanOrEqualTo(
    VentilationLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 17,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      reminderLevelBetween(
    VentilationLevel lower,
    VentilationLevel upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 17,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveredAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 18));
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveredAtIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 18));
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveredAtEqualTo(
    DateTime? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveredAtGreaterThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 18,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveredAtGreaterThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 18,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveredAtLessThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 18,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveredAtLessThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 18,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveredAtBetween(
    DateTime? lower,
    DateTime? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 18,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveryValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 19));
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveryValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 19));
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveryValueEqualTo(
    int? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveryValueGreaterThan(
    int? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveryValueGreaterThanOrEqualTo(
    int? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveryValueLessThan(
    int? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveryValueLessThanOrEqualTo(
    int? value,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveryValueBetween(
    int? lower,
    int? upper,
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

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterFilterCondition>
      recoveryNotifiedEqualTo(
    bool value,
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
}

extension VentilationEventQueryObject
    on QueryBuilder<VentilationEvent, VentilationEvent, QFilterCondition> {}

extension VentilationEventQuerySortBy
    on QueryBuilder<VentilationEvent, VentilationEvent, QSortBy> {
  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy> sortById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy> sortByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByDeviceIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByDeviceName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByDeviceNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByEndedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByStartValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByStartValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByPeakValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByPeakValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByPeakAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByPeakAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByLastValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByLastValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByLastReadingAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByLastReadingAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByHighestLevelNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByHighestLevelNotifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByUserAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByUserActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByUserActionAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByUserActionAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByReminderDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByReminderDueAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByReminderLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByReminderLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByRecoveredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByRecoveredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByRecoveryValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByRecoveryValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByRecoveryNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(20);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      sortByRecoveryNotifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(20, sort: Sort.desc);
    });
  }
}

extension VentilationEventQuerySortThenBy
    on QueryBuilder<VentilationEvent, VentilationEvent, QSortThenBy> {
  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy> thenById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy> thenByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByDeviceIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByDeviceName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByDeviceNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByEndedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByStartValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByStartValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByPeakValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByPeakValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByPeakAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByPeakAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByLastValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByLastValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByLastReadingAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByLastReadingAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByHighestLevelNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByHighestLevelNotifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByUserAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByUserActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByUserActionAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByUserActionAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByReminderDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByReminderDueAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByReminderLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByReminderLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByRecoveredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByRecoveredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByRecoveryValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByRecoveryValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19, sort: Sort.desc);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByRecoveryNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(20);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterSortBy>
      thenByRecoveryNotifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(20, sort: Sort.desc);
    });
  }
}

extension VentilationEventQueryWhereDistinct
    on QueryBuilder<VentilationEvent, VentilationEvent, QDistinct> {
  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByDeviceName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByStartValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByPeakValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByPeakAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByLastValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByLastReadingAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByHighestLevelNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(12);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByUserAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(14);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByUserActionAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(15);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByReminderDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(16);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByReminderLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(17);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByRecoveredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(18);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByRecoveryValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(19);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEvent, QAfterDistinct>
      distinctByRecoveryNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(20);
    });
  }
}

extension VentilationEventQueryProperty1
    on QueryBuilder<VentilationEvent, VentilationEvent, QProperty> {
  QueryBuilder<VentilationEvent, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<VentilationEvent, String, QAfterProperty> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<VentilationEvent, String, QAfterProperty> deviceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<VentilationEvent, DateTime, QAfterProperty> startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<VentilationEvent, DateTime?, QAfterProperty> endedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<VentilationEvent, VentilationEventStatus, QAfterProperty>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<VentilationEvent, int, QAfterProperty> startValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<VentilationEvent, int, QAfterProperty> peakValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<VentilationEvent, DateTime, QAfterProperty> peakAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<VentilationEvent, int, QAfterProperty> lastValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<VentilationEvent, DateTime, QAfterProperty>
      lastReadingAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<VentilationEvent, VentilationLevel, QAfterProperty>
      highestLevelNotifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<VentilationEvent, List<VentilationNotificationRecord>,
      QAfterProperty> notificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<VentilationEvent, VentilationUserAction, QAfterProperty>
      userActionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<VentilationEvent, DateTime?, QAfterProperty>
      userActionAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<VentilationEvent, DateTime?, QAfterProperty>
      reminderDueAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<VentilationEvent, VentilationLevel, QAfterProperty>
      reminderLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }

  QueryBuilder<VentilationEvent, DateTime?, QAfterProperty>
      recoveredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(18);
    });
  }

  QueryBuilder<VentilationEvent, int?, QAfterProperty> recoveryValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(19);
    });
  }

  QueryBuilder<VentilationEvent, bool, QAfterProperty>
      recoveryNotifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(20);
    });
  }
}

extension VentilationEventQueryProperty2<R>
    on QueryBuilder<VentilationEvent, R, QAfterProperty> {
  QueryBuilder<VentilationEvent, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<VentilationEvent, (R, String), QAfterProperty>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<VentilationEvent, (R, String), QAfterProperty>
      deviceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<VentilationEvent, (R, DateTime), QAfterProperty>
      startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<VentilationEvent, (R, DateTime?), QAfterProperty>
      endedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<VentilationEvent, (R, VentilationEventStatus), QAfterProperty>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<VentilationEvent, (R, int), QAfterProperty>
      startValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<VentilationEvent, (R, int), QAfterProperty> peakValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<VentilationEvent, (R, DateTime), QAfterProperty>
      peakAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<VentilationEvent, (R, int), QAfterProperty> lastValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<VentilationEvent, (R, DateTime), QAfterProperty>
      lastReadingAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<VentilationEvent, (R, VentilationLevel), QAfterProperty>
      highestLevelNotifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<VentilationEvent, (R, List<VentilationNotificationRecord>),
      QAfterProperty> notificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<VentilationEvent, (R, VentilationUserAction), QAfterProperty>
      userActionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<VentilationEvent, (R, DateTime?), QAfterProperty>
      userActionAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<VentilationEvent, (R, DateTime?), QAfterProperty>
      reminderDueAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<VentilationEvent, (R, VentilationLevel), QAfterProperty>
      reminderLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }

  QueryBuilder<VentilationEvent, (R, DateTime?), QAfterProperty>
      recoveredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(18);
    });
  }

  QueryBuilder<VentilationEvent, (R, int?), QAfterProperty>
      recoveryValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(19);
    });
  }

  QueryBuilder<VentilationEvent, (R, bool), QAfterProperty>
      recoveryNotifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(20);
    });
  }
}

extension VentilationEventQueryProperty3<R1, R2>
    on QueryBuilder<VentilationEvent, (R1, R2), QAfterProperty> {
  QueryBuilder<VentilationEvent, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, String), QOperations>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, String), QOperations>
      deviceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, DateTime), QOperations>
      startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, DateTime?), QOperations>
      endedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, VentilationEventStatus), QOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, int), QOperations>
      startValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, int), QOperations>
      peakValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, DateTime), QOperations>
      peakAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, int), QOperations>
      lastValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, DateTime), QOperations>
      lastReadingAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, VentilationLevel), QOperations>
      highestLevelNotifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, List<VentilationNotificationRecord>),
      QOperations> notificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, VentilationUserAction), QOperations>
      userActionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, DateTime?), QOperations>
      userActionAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, DateTime?), QOperations>
      reminderDueAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, VentilationLevel), QOperations>
      reminderLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, DateTime?), QOperations>
      recoveredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(18);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, int?), QOperations>
      recoveryValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(19);
    });
  }

  QueryBuilder<VentilationEvent, (R1, R2, bool), QOperations>
      recoveryNotifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(20);
    });
  }
}

// **************************************************************************
// _IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

final VentilationNotificationRecordSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'VentilationNotificationRecord',
    embedded: true,
    properties: [
      IsarPropertySchema(
        name: 'level',
        type: IsarType.byte,
        enumMap: {"none": 0, "stuffy": 1, "better": 2, "poor": 3},
      ),
      IsarPropertySchema(
        name: 'kind',
        type: IsarType.byte,
        enumMap: {"alert": 0, "reminder": 1, "recovery": 2},
      ),
      IsarPropertySchema(
        name: 'co2',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'sentAt',
        type: IsarType.dateTime,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<void, VentilationNotificationRecord>(
    serialize: serializeVentilationNotificationRecord,
    deserialize: deserializeVentilationNotificationRecord,
  ),
);

@isarProtected
int serializeVentilationNotificationRecord(
    IsarWriter writer, VentilationNotificationRecord object) {
  IsarCore.writeByte(writer, 1, object.level.index);
  IsarCore.writeByte(writer, 2, object.kind.index);
  IsarCore.writeLong(writer, 3, object.co2);
  IsarCore.writeLong(writer, 4,
      object.sentAt?.toUtc().microsecondsSinceEpoch ?? -9223372036854775808);
  return 0;
}

@isarProtected
VentilationNotificationRecord deserializeVentilationNotificationRecord(
    IsarReader reader) {
  final VentilationLevel _level;
  {
    if (IsarCore.readNull(reader, 1)) {
      _level = VentilationLevel.none;
    } else {
      _level =
          _ventilationNotificationRecordLevel[IsarCore.readByte(reader, 1)] ??
              VentilationLevel.none;
    }
  }
  final VentilationNotificationKind _kind;
  {
    if (IsarCore.readNull(reader, 2)) {
      _kind = VentilationNotificationKind.alert;
    } else {
      _kind =
          _ventilationNotificationRecordKind[IsarCore.readByte(reader, 2)] ??
              VentilationNotificationKind.alert;
    }
  }
  final int _co2;
  {
    final value = IsarCore.readLong(reader, 3);
    if (value == -9223372036854775808) {
      _co2 = 0;
    } else {
      _co2 = value;
    }
  }
  final DateTime? _sentAt;
  {
    final value = IsarCore.readLong(reader, 4);
    if (value == -9223372036854775808) {
      _sentAt = null;
    } else {
      _sentAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final object = VentilationNotificationRecord(
    level: _level,
    kind: _kind,
    co2: _co2,
    sentAt: _sentAt,
  );
  return object;
}

const _ventilationNotificationRecordLevel = {
  0: VentilationLevel.none,
  1: VentilationLevel.stuffy,
  2: VentilationLevel.better,
  3: VentilationLevel.poor,
};
const _ventilationNotificationRecordKind = {
  0: VentilationNotificationKind.alert,
  1: VentilationNotificationKind.reminder,
  2: VentilationNotificationKind.recovery,
};

extension VentilationNotificationRecordQueryFilter on QueryBuilder<
    VentilationNotificationRecord,
    VentilationNotificationRecord,
    QFilterCondition> {
  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> levelEqualTo(
    VentilationLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> levelGreaterThan(
    VentilationLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> levelGreaterThanOrEqualTo(
    VentilationLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> levelLessThan(
    VentilationLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> levelLessThanOrEqualTo(
    VentilationLevel value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> levelBetween(
    VentilationLevel lower,
    VentilationLevel upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> kindEqualTo(
    VentilationNotificationKind value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> kindGreaterThan(
    VentilationNotificationKind value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> kindGreaterThanOrEqualTo(
    VentilationNotificationKind value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> kindLessThan(
    VentilationNotificationKind value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> kindLessThanOrEqualTo(
    VentilationNotificationKind value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> kindBetween(
    VentilationNotificationKind lower,
    VentilationNotificationKind upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> co2EqualTo(
    int value,
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

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> co2GreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> co2GreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> co2LessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> co2LessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> co2Between(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> sentAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> sentAtIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> sentAtEqualTo(
    DateTime? value,
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

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> sentAtGreaterThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> sentAtGreaterThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> sentAtLessThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> sentAtLessThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<VentilationNotificationRecord, VentilationNotificationRecord,
      QAfterFilterCondition> sentAtBetween(
    DateTime? lower,
    DateTime? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }
}

extension VentilationNotificationRecordQueryObject on QueryBuilder<
    VentilationNotificationRecord,
    VentilationNotificationRecord,
    QFilterCondition> {}
