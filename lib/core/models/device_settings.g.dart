// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_settings.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDeviceSettingsCollection on Isar {
  IsarCollection<String, DeviceSettings> get deviceSettings =>
      this.collection();
}

const DeviceSettingsSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DeviceSettings',
    idName: 'deviceId',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'alarmEnabled',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'vibrationEnabled',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'powerMode',
        type: IsarType.byte,
        enumMap: {"low": 0, "medium": 1, "high": 2},
      ),
      IsarPropertySchema(
        name: 'continuosScreenEnabled',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'thresholds',
        type: IsarType.json,
      ),
      IsarPropertySchema(
        name: 'version',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'deviceId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'highCo2AlarmEnabled',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'autoSyncTime',
        type: IsarType.bool,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, DeviceSettings>(
    serialize: serializeDeviceSettings,
    deserialize: deserializeDeviceSettings,
    deserializeProperty: deserializeDeviceSettingsProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeDeviceSettings(IsarWriter writer, DeviceSettings object) {
  IsarCore.writeBool(writer, 1, object.alarmEnabled);
  IsarCore.writeBool(writer, 2, object.vibrationEnabled);
  IsarCore.writeByte(writer, 3, object.powerMode.index);
  IsarCore.writeBool(writer, 4, object.continuosScreenEnabled);
  IsarCore.writeString(writer, 5, isarJsonEncode(object.thresholds));
  IsarCore.writeString(writer, 6, object.version);
  IsarCore.writeString(writer, 7, object.deviceId);
  IsarCore.writeBool(writer, 8, object.highCo2AlarmEnabled);
  IsarCore.writeBool(writer, 9, object.autoSyncTime);
  return Isar.fastHash(object.deviceId);
}

@isarProtected
DeviceSettings deserializeDeviceSettings(IsarReader reader) {
  final bool _alarmEnabled;
  _alarmEnabled = IsarCore.readBool(reader, 1);
  final bool _vibrationEnabled;
  _vibrationEnabled = IsarCore.readBool(reader, 2);
  final PowerMode _powerMode;
  {
    if (IsarCore.readNull(reader, 3)) {
      _powerMode = PowerMode.low;
    } else {
      _powerMode = _deviceSettingsPowerMode[IsarCore.readByte(reader, 3)] ??
          PowerMode.low;
    }
  }
  final bool _continuosScreenEnabled;
  _continuosScreenEnabled = IsarCore.readBool(reader, 4);
  final Map<String, dynamic> _thresholds;
  {
    final json = isarJsonDecode(IsarCore.readString(reader, 5) ?? 'null');
    if (json is Map<String, dynamic>) {
      _thresholds = json;
    } else {
      _thresholds = const <String, dynamic>{};
    }
  }
  final String _version;
  _version = IsarCore.readString(reader, 6) ?? '';
  final String _deviceId;
  _deviceId = IsarCore.readString(reader, 7) ?? '';
  final bool _highCo2AlarmEnabled;
  _highCo2AlarmEnabled = IsarCore.readBool(reader, 8);
  final bool _autoSyncTime;
  {
    if (IsarCore.readNull(reader, 9)) {
      _autoSyncTime = true;
    } else {
      _autoSyncTime = IsarCore.readBool(reader, 9);
    }
  }
  final object = DeviceSettings(
    alarmEnabled: _alarmEnabled,
    vibrationEnabled: _vibrationEnabled,
    powerMode: _powerMode,
    continuosScreenEnabled: _continuosScreenEnabled,
    thresholds: _thresholds,
    version: _version,
    deviceId: _deviceId,
    highCo2AlarmEnabled: _highCo2AlarmEnabled,
    autoSyncTime: _autoSyncTime,
  );
  return object;
}

@isarProtected
dynamic deserializeDeviceSettingsProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readBool(reader, 1);
    case 2:
      return IsarCore.readBool(reader, 2);
    case 3:
      {
        if (IsarCore.readNull(reader, 3)) {
          return PowerMode.low;
        } else {
          return _deviceSettingsPowerMode[IsarCore.readByte(reader, 3)] ??
              PowerMode.low;
        }
      }
    case 4:
      return IsarCore.readBool(reader, 4);
    case 5:
      {
        final json = isarJsonDecode(IsarCore.readString(reader, 5) ?? 'null');
        if (json is Map<String, dynamic>) {
          return json;
        } else {
          return const <String, dynamic>{};
        }
      }
    case 6:
      return IsarCore.readString(reader, 6) ?? '';
    case 7:
      return IsarCore.readString(reader, 7) ?? '';
    case 8:
      return IsarCore.readBool(reader, 8);
    case 9:
      {
        if (IsarCore.readNull(reader, 9)) {
          return true;
        } else {
          return IsarCore.readBool(reader, 9);
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _DeviceSettingsUpdate {
  bool call({
    required String deviceId,
    bool? alarmEnabled,
    bool? vibrationEnabled,
    PowerMode? powerMode,
    bool? continuosScreenEnabled,
    String? version,
    bool? highCo2AlarmEnabled,
    bool? autoSyncTime,
  });
}

class _DeviceSettingsUpdateImpl implements _DeviceSettingsUpdate {
  const _DeviceSettingsUpdateImpl(this.collection);

  final IsarCollection<String, DeviceSettings> collection;

  @override
  bool call({
    required String deviceId,
    Object? alarmEnabled = ignore,
    Object? vibrationEnabled = ignore,
    Object? powerMode = ignore,
    Object? continuosScreenEnabled = ignore,
    Object? version = ignore,
    Object? highCo2AlarmEnabled = ignore,
    Object? autoSyncTime = ignore,
  }) {
    return collection.updateProperties([
          deviceId
        ], {
          if (alarmEnabled != ignore) 1: alarmEnabled as bool?,
          if (vibrationEnabled != ignore) 2: vibrationEnabled as bool?,
          if (powerMode != ignore) 3: powerMode as PowerMode?,
          if (continuosScreenEnabled != ignore)
            4: continuosScreenEnabled as bool?,
          if (version != ignore) 6: version as String?,
          if (highCo2AlarmEnabled != ignore) 8: highCo2AlarmEnabled as bool?,
          if (autoSyncTime != ignore) 9: autoSyncTime as bool?,
        }) >
        0;
  }
}

sealed class _DeviceSettingsUpdateAll {
  int call({
    required List<String> deviceId,
    bool? alarmEnabled,
    bool? vibrationEnabled,
    PowerMode? powerMode,
    bool? continuosScreenEnabled,
    String? version,
    bool? highCo2AlarmEnabled,
    bool? autoSyncTime,
  });
}

class _DeviceSettingsUpdateAllImpl implements _DeviceSettingsUpdateAll {
  const _DeviceSettingsUpdateAllImpl(this.collection);

  final IsarCollection<String, DeviceSettings> collection;

  @override
  int call({
    required List<String> deviceId,
    Object? alarmEnabled = ignore,
    Object? vibrationEnabled = ignore,
    Object? powerMode = ignore,
    Object? continuosScreenEnabled = ignore,
    Object? version = ignore,
    Object? highCo2AlarmEnabled = ignore,
    Object? autoSyncTime = ignore,
  }) {
    return collection.updateProperties(deviceId, {
      if (alarmEnabled != ignore) 1: alarmEnabled as bool?,
      if (vibrationEnabled != ignore) 2: vibrationEnabled as bool?,
      if (powerMode != ignore) 3: powerMode as PowerMode?,
      if (continuosScreenEnabled != ignore) 4: continuosScreenEnabled as bool?,
      if (version != ignore) 6: version as String?,
      if (highCo2AlarmEnabled != ignore) 8: highCo2AlarmEnabled as bool?,
      if (autoSyncTime != ignore) 9: autoSyncTime as bool?,
    });
  }
}

extension DeviceSettingsUpdate on IsarCollection<String, DeviceSettings> {
  _DeviceSettingsUpdate get update => _DeviceSettingsUpdateImpl(this);

  _DeviceSettingsUpdateAll get updateAll => _DeviceSettingsUpdateAllImpl(this);
}

sealed class _DeviceSettingsQueryUpdate {
  int call({
    bool? alarmEnabled,
    bool? vibrationEnabled,
    PowerMode? powerMode,
    bool? continuosScreenEnabled,
    String? version,
    bool? highCo2AlarmEnabled,
    bool? autoSyncTime,
  });
}

class _DeviceSettingsQueryUpdateImpl implements _DeviceSettingsQueryUpdate {
  const _DeviceSettingsQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<DeviceSettings> query;
  final int? limit;

  @override
  int call({
    Object? alarmEnabled = ignore,
    Object? vibrationEnabled = ignore,
    Object? powerMode = ignore,
    Object? continuosScreenEnabled = ignore,
    Object? version = ignore,
    Object? highCo2AlarmEnabled = ignore,
    Object? autoSyncTime = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (alarmEnabled != ignore) 1: alarmEnabled as bool?,
      if (vibrationEnabled != ignore) 2: vibrationEnabled as bool?,
      if (powerMode != ignore) 3: powerMode as PowerMode?,
      if (continuosScreenEnabled != ignore) 4: continuosScreenEnabled as bool?,
      if (version != ignore) 6: version as String?,
      if (highCo2AlarmEnabled != ignore) 8: highCo2AlarmEnabled as bool?,
      if (autoSyncTime != ignore) 9: autoSyncTime as bool?,
    });
  }
}

extension DeviceSettingsQueryUpdate on IsarQuery<DeviceSettings> {
  _DeviceSettingsQueryUpdate get updateFirst =>
      _DeviceSettingsQueryUpdateImpl(this, limit: 1);

  _DeviceSettingsQueryUpdate get updateAll =>
      _DeviceSettingsQueryUpdateImpl(this);
}

class _DeviceSettingsQueryBuilderUpdateImpl
    implements _DeviceSettingsQueryUpdate {
  const _DeviceSettingsQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<DeviceSettings, DeviceSettings, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? alarmEnabled = ignore,
    Object? vibrationEnabled = ignore,
    Object? powerMode = ignore,
    Object? continuosScreenEnabled = ignore,
    Object? version = ignore,
    Object? highCo2AlarmEnabled = ignore,
    Object? autoSyncTime = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (alarmEnabled != ignore) 1: alarmEnabled as bool?,
        if (vibrationEnabled != ignore) 2: vibrationEnabled as bool?,
        if (powerMode != ignore) 3: powerMode as PowerMode?,
        if (continuosScreenEnabled != ignore)
          4: continuosScreenEnabled as bool?,
        if (version != ignore) 6: version as String?,
        if (highCo2AlarmEnabled != ignore) 8: highCo2AlarmEnabled as bool?,
        if (autoSyncTime != ignore) 9: autoSyncTime as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension DeviceSettingsQueryBuilderUpdate
    on QueryBuilder<DeviceSettings, DeviceSettings, QOperations> {
  _DeviceSettingsQueryUpdate get updateFirst =>
      _DeviceSettingsQueryBuilderUpdateImpl(this, limit: 1);

  _DeviceSettingsQueryUpdate get updateAll =>
      _DeviceSettingsQueryBuilderUpdateImpl(this);
}

const _deviceSettingsPowerMode = {
  0: PowerMode.low,
  1: PowerMode.medium,
  2: PowerMode.high,
};

extension DeviceSettingsQueryFilter
    on QueryBuilder<DeviceSettings, DeviceSettings, QFilterCondition> {
  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      alarmEnabledEqualTo(
    bool value,
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

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      vibrationEnabledEqualTo(
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

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      powerModeEqualTo(
    PowerMode value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      powerModeGreaterThan(
    PowerMode value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      powerModeGreaterThanOrEqualTo(
    PowerMode value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      powerModeLessThan(
    PowerMode value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      powerModeLessThanOrEqualTo(
    PowerMode value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      powerModeBetween(
    PowerMode lower,
    PowerMode upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      continuosScreenEnabledEqualTo(
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

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      versionEqualTo(
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

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      versionGreaterThan(
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

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      versionGreaterThanOrEqualTo(
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

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      versionLessThan(
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

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      versionLessThanOrEqualTo(
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

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      versionBetween(
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

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      versionStartsWith(
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

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      versionEndsWith(
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

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      versionContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      versionMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      versionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      versionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      deviceIdGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      deviceIdGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      deviceIdLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      deviceIdLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      deviceIdBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 7,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      highCo2AlarmEnabledEqualTo(
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

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterFilterCondition>
      autoSyncTimeEqualTo(
    bool value,
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
}

extension DeviceSettingsQueryObject
    on QueryBuilder<DeviceSettings, DeviceSettings, QFilterCondition> {}

extension DeviceSettingsQuerySortBy
    on QueryBuilder<DeviceSettings, DeviceSettings, QSortBy> {
  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      sortByAlarmEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      sortByAlarmEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      sortByVibrationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      sortByVibrationEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy> sortByPowerMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      sortByPowerModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      sortByContinuosScreenEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      sortByContinuosScreenEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      sortByThresholds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      sortByThresholdsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy> sortByVersion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy> sortByVersionDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy> sortByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        7,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy> sortByDeviceIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        7,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      sortByHighCo2AlarmEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      sortByHighCo2AlarmEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      sortByAutoSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      sortByAutoSyncTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }
}

extension DeviceSettingsQuerySortThenBy
    on QueryBuilder<DeviceSettings, DeviceSettings, QSortThenBy> {
  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      thenByAlarmEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      thenByAlarmEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      thenByVibrationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      thenByVibrationEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy> thenByPowerMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      thenByPowerModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      thenByContinuosScreenEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      thenByContinuosScreenEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      thenByThresholds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      thenByThresholdsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy> thenByVersion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy> thenByVersionDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy> thenByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy> thenByDeviceIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      thenByHighCo2AlarmEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      thenByHighCo2AlarmEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      thenByAutoSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterSortBy>
      thenByAutoSyncTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }
}

extension DeviceSettingsQueryWhereDistinct
    on QueryBuilder<DeviceSettings, DeviceSettings, QDistinct> {
  QueryBuilder<DeviceSettings, DeviceSettings, QAfterDistinct>
      distinctByAlarmEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterDistinct>
      distinctByVibrationEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterDistinct>
      distinctByPowerMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterDistinct>
      distinctByContinuosScreenEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterDistinct>
      distinctByThresholds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterDistinct>
      distinctByVersion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterDistinct>
      distinctByHighCo2AlarmEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<DeviceSettings, DeviceSettings, QAfterDistinct>
      distinctByAutoSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }
}

extension DeviceSettingsQueryProperty1
    on QueryBuilder<DeviceSettings, DeviceSettings, QProperty> {
  QueryBuilder<DeviceSettings, bool, QAfterProperty> alarmEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DeviceSettings, bool, QAfterProperty>
      vibrationEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DeviceSettings, PowerMode, QAfterProperty> powerModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DeviceSettings, bool, QAfterProperty>
      continuosScreenEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DeviceSettings, Map<String, dynamic>, QAfterProperty>
      thresholdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DeviceSettings, String, QAfterProperty> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DeviceSettings, String, QAfterProperty> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DeviceSettings, bool, QAfterProperty>
      highCo2AlarmEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DeviceSettings, bool, QAfterProperty> autoSyncTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }
}

extension DeviceSettingsQueryProperty2<R>
    on QueryBuilder<DeviceSettings, R, QAfterProperty> {
  QueryBuilder<DeviceSettings, (R, bool), QAfterProperty>
      alarmEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DeviceSettings, (R, bool), QAfterProperty>
      vibrationEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DeviceSettings, (R, PowerMode), QAfterProperty>
      powerModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DeviceSettings, (R, bool), QAfterProperty>
      continuosScreenEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DeviceSettings, (R, Map<String, dynamic>), QAfterProperty>
      thresholdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DeviceSettings, (R, String), QAfterProperty> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DeviceSettings, (R, String), QAfterProperty> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DeviceSettings, (R, bool), QAfterProperty>
      highCo2AlarmEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DeviceSettings, (R, bool), QAfterProperty>
      autoSyncTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }
}

extension DeviceSettingsQueryProperty3<R1, R2>
    on QueryBuilder<DeviceSettings, (R1, R2), QAfterProperty> {
  QueryBuilder<DeviceSettings, (R1, R2, bool), QOperations>
      alarmEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DeviceSettings, (R1, R2, bool), QOperations>
      vibrationEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DeviceSettings, (R1, R2, PowerMode), QOperations>
      powerModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DeviceSettings, (R1, R2, bool), QOperations>
      continuosScreenEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DeviceSettings, (R1, R2, Map<String, dynamic>), QOperations>
      thresholdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DeviceSettings, (R1, R2, String), QOperations>
      versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DeviceSettings, (R1, R2, String), QOperations>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DeviceSettings, (R1, R2, bool), QOperations>
      highCo2AlarmEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DeviceSettings, (R1, R2, bool), QOperations>
      autoSyncTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }
}
