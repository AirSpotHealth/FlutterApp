// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_data.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDeviceDataCollection on Isar {
  IsarCollection<String, DeviceData> get deviceDatas => this.collection();
}

const DeviceDataSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DeviceData',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'deviceId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'dateTime',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'value',
        type: IsarType.json,
      ),
      IsarPropertySchema(
        name: 'type',
        type: IsarType.byte,
        enumMap: {
          "co2": 0,
          "batteryLow": 1,
          "calibration": 2,
          "sensorError": 3,
          "reset": 4,
          "sensorFactoryReset": 5,
          "calibrationCorrection": 6,
          "sensorAutoCalibration": 7,
          "integrityError": 8,
          "calibrationTarget": 9,
          "timeSync": 10,
          "liveCo2": 11,
          "empty": 12
        },
      ),
      IsarPropertySchema(
        name: 'id',
        type: IsarType.string,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'dateTime',
        properties: [
          "dateTime",
        ],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<String, DeviceData>(
    serialize: serializeDeviceData,
    deserialize: deserializeDeviceData,
    deserializeProperty: deserializeDeviceDataProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeDeviceData(IsarWriter writer, DeviceData object) {
  IsarCore.writeString(writer, 1, object.deviceId);
  IsarCore.writeLong(writer, 2, object.dateTime.toUtc().microsecondsSinceEpoch);
  IsarCore.writeString(writer, 3, isarJsonEncode(object.value));
  IsarCore.writeByte(writer, 4, object.type.index);
  IsarCore.writeString(writer, 5, object.id);
  return Isar.fastHash(object.id);
}

@isarProtected
DeviceData deserializeDeviceData(IsarReader reader) {
  final String _deviceId;
  _deviceId = IsarCore.readString(reader, 1) ?? '';
  final DateTime _dateTime;
  {
    final value = IsarCore.readLong(reader, 2);
    if (value == -9223372036854775808) {
      _dateTime = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _dateTime =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final dynamic _value;
  _value = isarJsonDecode(IsarCore.readString(reader, 3) ?? 'null') ?? null;
  final DeviceDataType _type;
  {
    if (IsarCore.readNull(reader, 4)) {
      _type = DeviceDataType.co2;
    } else {
      _type =
          _deviceDataType[IsarCore.readByte(reader, 4)] ?? DeviceDataType.co2;
    }
  }
  final object = DeviceData(
    deviceId: _deviceId,
    dateTime: _dateTime,
    value: _value,
    type: _type,
  );
  return object;
}

@isarProtected
dynamic deserializeDeviceDataProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      {
        final value = IsarCore.readLong(reader, 2);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 3:
      return isarJsonDecode(IsarCore.readString(reader, 3) ?? 'null') ?? null;
    case 4:
      {
        if (IsarCore.readNull(reader, 4)) {
          return DeviceDataType.co2;
        } else {
          return _deviceDataType[IsarCore.readByte(reader, 4)] ??
              DeviceDataType.co2;
        }
      }
    case 5:
      return IsarCore.readString(reader, 5) ?? '';
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _DeviceDataUpdate {
  bool call({
    required String id,
    String? deviceId,
    DateTime? dateTime,
    DeviceDataType? type,
  });
}

class _DeviceDataUpdateImpl implements _DeviceDataUpdate {
  const _DeviceDataUpdateImpl(this.collection);

  final IsarCollection<String, DeviceData> collection;

  @override
  bool call({
    required String id,
    Object? deviceId = ignore,
    Object? dateTime = ignore,
    Object? type = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (deviceId != ignore) 1: deviceId as String?,
          if (dateTime != ignore) 2: dateTime as DateTime?,
          if (type != ignore) 4: type as DeviceDataType?,
        }) >
        0;
  }
}

sealed class _DeviceDataUpdateAll {
  int call({
    required List<String> id,
    String? deviceId,
    DateTime? dateTime,
    DeviceDataType? type,
  });
}

class _DeviceDataUpdateAllImpl implements _DeviceDataUpdateAll {
  const _DeviceDataUpdateAllImpl(this.collection);

  final IsarCollection<String, DeviceData> collection;

  @override
  int call({
    required List<String> id,
    Object? deviceId = ignore,
    Object? dateTime = ignore,
    Object? type = ignore,
  }) {
    return collection.updateProperties(id, {
      if (deviceId != ignore) 1: deviceId as String?,
      if (dateTime != ignore) 2: dateTime as DateTime?,
      if (type != ignore) 4: type as DeviceDataType?,
    });
  }
}

extension DeviceDataUpdate on IsarCollection<String, DeviceData> {
  _DeviceDataUpdate get update => _DeviceDataUpdateImpl(this);

  _DeviceDataUpdateAll get updateAll => _DeviceDataUpdateAllImpl(this);
}

sealed class _DeviceDataQueryUpdate {
  int call({
    String? deviceId,
    DateTime? dateTime,
    DeviceDataType? type,
  });
}

class _DeviceDataQueryUpdateImpl implements _DeviceDataQueryUpdate {
  const _DeviceDataQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<DeviceData> query;
  final int? limit;

  @override
  int call({
    Object? deviceId = ignore,
    Object? dateTime = ignore,
    Object? type = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (deviceId != ignore) 1: deviceId as String?,
      if (dateTime != ignore) 2: dateTime as DateTime?,
      if (type != ignore) 4: type as DeviceDataType?,
    });
  }
}

extension DeviceDataQueryUpdate on IsarQuery<DeviceData> {
  _DeviceDataQueryUpdate get updateFirst =>
      _DeviceDataQueryUpdateImpl(this, limit: 1);

  _DeviceDataQueryUpdate get updateAll => _DeviceDataQueryUpdateImpl(this);
}

class _DeviceDataQueryBuilderUpdateImpl implements _DeviceDataQueryUpdate {
  const _DeviceDataQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<DeviceData, DeviceData, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? deviceId = ignore,
    Object? dateTime = ignore,
    Object? type = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (deviceId != ignore) 1: deviceId as String?,
        if (dateTime != ignore) 2: dateTime as DateTime?,
        if (type != ignore) 4: type as DeviceDataType?,
      });
    } finally {
      q.close();
    }
  }
}

extension DeviceDataQueryBuilderUpdate
    on QueryBuilder<DeviceData, DeviceData, QOperations> {
  _DeviceDataQueryUpdate get updateFirst =>
      _DeviceDataQueryBuilderUpdateImpl(this, limit: 1);

  _DeviceDataQueryUpdate get updateAll =>
      _DeviceDataQueryBuilderUpdateImpl(this);
}

const _deviceDataType = {
  0: DeviceDataType.co2,
  1: DeviceDataType.batteryLow,
  2: DeviceDataType.calibration,
  3: DeviceDataType.sensorError,
  4: DeviceDataType.reset,
  5: DeviceDataType.sensorFactoryReset,
  6: DeviceDataType.calibrationCorrection,
  7: DeviceDataType.sensorAutoCalibration,
  8: DeviceDataType.integrityError,
  9: DeviceDataType.calibrationTarget,
  10: DeviceDataType.timeSync,
  11: DeviceDataType.liveCo2,
  12: DeviceDataType.empty,
};

extension DeviceDataQueryFilter
    on QueryBuilder<DeviceData, DeviceData, QFilterCondition> {
  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> deviceIdEqualTo(
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

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition>
      deviceIdGreaterThan(
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

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition>
      deviceIdGreaterThanOrEqualTo(
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

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> deviceIdLessThan(
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

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition>
      deviceIdLessThanOrEqualTo(
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

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> deviceIdBetween(
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

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition>
      deviceIdStartsWith(
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

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> deviceIdEndsWith(
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

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> deviceIdContains(
      String value,
      {bool caseSensitive = true}) {
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

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> deviceIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
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

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> dateTimeEqualTo(
    DateTime value,
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

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition>
      dateTimeGreaterThan(
    DateTime value,
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

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition>
      dateTimeGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> dateTimeLessThan(
    DateTime value,
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

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition>
      dateTimeLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> dateTimeBetween(
    DateTime lower,
    DateTime upper,
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

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> typeEqualTo(
    DeviceDataType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> typeGreaterThan(
    DeviceDataType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition>
      typeGreaterThanOrEqualTo(
    DeviceDataType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> typeLessThan(
    DeviceDataType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition>
      typeLessThanOrEqualTo(
    DeviceDataType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> typeBetween(
    DeviceDataType lower,
    DeviceDataType upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> idLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition>
      idLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> idContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 5,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }
}

extension DeviceDataQueryObject
    on QueryBuilder<DeviceData, DeviceData, QFilterCondition> {}

extension DeviceDataQuerySortBy
    on QueryBuilder<DeviceData, DeviceData, QSortBy> {
  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> sortByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> sortByDeviceIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> sortByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> sortByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> sortByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> sortByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> sortById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension DeviceDataQuerySortThenBy
    on QueryBuilder<DeviceData, DeviceData, QSortThenBy> {
  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> thenByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> thenByDeviceIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> thenByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> thenByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> thenByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> thenByValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> thenById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension DeviceDataQueryWhereDistinct
    on QueryBuilder<DeviceData, DeviceData, QDistinct> {
  QueryBuilder<DeviceData, DeviceData, QAfterDistinct> distinctByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterDistinct> distinctByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterDistinct> distinctByValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<DeviceData, DeviceData, QAfterDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }
}

extension DeviceDataQueryProperty1
    on QueryBuilder<DeviceData, DeviceData, QProperty> {
  QueryBuilder<DeviceData, String, QAfterProperty> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DeviceData, DateTime, QAfterProperty> dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DeviceData, dynamic, QAfterProperty> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DeviceData, DeviceDataType, QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DeviceData, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

extension DeviceDataQueryProperty2<R>
    on QueryBuilder<DeviceData, R, QAfterProperty> {
  QueryBuilder<DeviceData, (R, String), QAfterProperty> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DeviceData, (R, DateTime), QAfterProperty> dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DeviceData, (R, dynamic), QAfterProperty> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DeviceData, (R, DeviceDataType), QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DeviceData, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

extension DeviceDataQueryProperty3<R1, R2>
    on QueryBuilder<DeviceData, (R1, R2), QAfterProperty> {
  QueryBuilder<DeviceData, (R1, R2, String), QOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DeviceData, (R1, R2, DateTime), QOperations> dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DeviceData, (R1, R2, dynamic), QOperations> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DeviceData, (R1, R2, DeviceDataType), QOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DeviceData, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}
