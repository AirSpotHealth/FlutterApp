// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'factory_test_result.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetFactoryTestResultCollection on Isar {
  IsarCollection<int, FactoryTestResult> get factoryTestResults =>
      this.collection();
}

const FactoryTestResultSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'FactoryTestResult',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'deviceId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'completedAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'status',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'testedBy',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'comment',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'sensorVariant',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'deviceType',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'automaticTestsJson',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'manualTestsJson',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'totalTests',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'passedTests',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'displayDeviceId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'allTestsPassed',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'passRate',
        type: IsarType.double,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, FactoryTestResult>(
    serialize: serializeFactoryTestResult,
    deserialize: deserializeFactoryTestResult,
    deserializeProperty: deserializeFactoryTestResultProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeFactoryTestResult(IsarWriter writer, FactoryTestResult object) {
  IsarCore.writeString(writer, 1, object.deviceId);
  IsarCore.writeLong(
      writer, 2, object.completedAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeString(writer, 3, object.status);
  IsarCore.writeString(writer, 4, object.testedBy);
  {
    final value = object.comment;
    if (value == null) {
      IsarCore.writeNull(writer, 5);
    } else {
      IsarCore.writeString(writer, 5, value);
    }
  }
  IsarCore.writeLong(writer, 6, object.sensorVariant);
  IsarCore.writeString(writer, 7, object.deviceType);
  IsarCore.writeString(writer, 8, object.automaticTestsJson);
  IsarCore.writeString(writer, 9, object.manualTestsJson);
  IsarCore.writeLong(writer, 10, object.totalTests);
  IsarCore.writeLong(writer, 11, object.passedTests);
  IsarCore.writeString(writer, 12, object.displayDeviceId);
  IsarCore.writeBool(writer, 13, object.allTestsPassed);
  IsarCore.writeDouble(writer, 14, object.passRate);
  return object.id;
}

@isarProtected
FactoryTestResult deserializeFactoryTestResult(IsarReader reader) {
  final int _id;
  _id = IsarCore.readId(reader);
  final String _deviceId;
  _deviceId = IsarCore.readString(reader, 1) ?? '';
  final DateTime _completedAt;
  {
    final value = IsarCore.readLong(reader, 2);
    if (value == -9223372036854775808) {
      _completedAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _completedAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final String _status;
  _status = IsarCore.readString(reader, 3) ?? '';
  final String _testedBy;
  _testedBy = IsarCore.readString(reader, 4) ?? '';
  final String? _comment;
  _comment = IsarCore.readString(reader, 5);
  final int _sensorVariant;
  _sensorVariant = IsarCore.readLong(reader, 6);
  final String _deviceType;
  _deviceType = IsarCore.readString(reader, 7) ?? '';
  final String _automaticTestsJson;
  _automaticTestsJson = IsarCore.readString(reader, 8) ?? '';
  final String _manualTestsJson;
  _manualTestsJson = IsarCore.readString(reader, 9) ?? '';
  final int _totalTests;
  _totalTests = IsarCore.readLong(reader, 10);
  final int _passedTests;
  _passedTests = IsarCore.readLong(reader, 11);
  final object = FactoryTestResult(
    id: _id,
    deviceId: _deviceId,
    completedAt: _completedAt,
    status: _status,
    testedBy: _testedBy,
    comment: _comment,
    sensorVariant: _sensorVariant,
    deviceType: _deviceType,
    automaticTestsJson: _automaticTestsJson,
    manualTestsJson: _manualTestsJson,
    totalTests: _totalTests,
    passedTests: _passedTests,
  );
  return object;
}

@isarProtected
dynamic deserializeFactoryTestResultProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
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
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      return IsarCore.readString(reader, 4) ?? '';
    case 5:
      return IsarCore.readString(reader, 5);
    case 6:
      return IsarCore.readLong(reader, 6);
    case 7:
      return IsarCore.readString(reader, 7) ?? '';
    case 8:
      return IsarCore.readString(reader, 8) ?? '';
    case 9:
      return IsarCore.readString(reader, 9) ?? '';
    case 10:
      return IsarCore.readLong(reader, 10);
    case 11:
      return IsarCore.readLong(reader, 11);
    case 12:
      return IsarCore.readString(reader, 12) ?? '';
    case 13:
      return IsarCore.readBool(reader, 13);
    case 14:
      return IsarCore.readDouble(reader, 14);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _FactoryTestResultUpdate {
  bool call({
    required int id,
    String? deviceId,
    DateTime? completedAt,
    String? status,
    String? testedBy,
    String? comment,
    int? sensorVariant,
    String? deviceType,
    String? automaticTestsJson,
    String? manualTestsJson,
    int? totalTests,
    int? passedTests,
    String? displayDeviceId,
    bool? allTestsPassed,
    double? passRate,
  });
}

class _FactoryTestResultUpdateImpl implements _FactoryTestResultUpdate {
  const _FactoryTestResultUpdateImpl(this.collection);

  final IsarCollection<int, FactoryTestResult> collection;

  @override
  bool call({
    required int id,
    Object? deviceId = ignore,
    Object? completedAt = ignore,
    Object? status = ignore,
    Object? testedBy = ignore,
    Object? comment = ignore,
    Object? sensorVariant = ignore,
    Object? deviceType = ignore,
    Object? automaticTestsJson = ignore,
    Object? manualTestsJson = ignore,
    Object? totalTests = ignore,
    Object? passedTests = ignore,
    Object? displayDeviceId = ignore,
    Object? allTestsPassed = ignore,
    Object? passRate = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (deviceId != ignore) 1: deviceId as String?,
          if (completedAt != ignore) 2: completedAt as DateTime?,
          if (status != ignore) 3: status as String?,
          if (testedBy != ignore) 4: testedBy as String?,
          if (comment != ignore) 5: comment as String?,
          if (sensorVariant != ignore) 6: sensorVariant as int?,
          if (deviceType != ignore) 7: deviceType as String?,
          if (automaticTestsJson != ignore) 8: automaticTestsJson as String?,
          if (manualTestsJson != ignore) 9: manualTestsJson as String?,
          if (totalTests != ignore) 10: totalTests as int?,
          if (passedTests != ignore) 11: passedTests as int?,
          if (displayDeviceId != ignore) 12: displayDeviceId as String?,
          if (allTestsPassed != ignore) 13: allTestsPassed as bool?,
          if (passRate != ignore) 14: passRate as double?,
        }) >
        0;
  }
}

sealed class _FactoryTestResultUpdateAll {
  int call({
    required List<int> id,
    String? deviceId,
    DateTime? completedAt,
    String? status,
    String? testedBy,
    String? comment,
    int? sensorVariant,
    String? deviceType,
    String? automaticTestsJson,
    String? manualTestsJson,
    int? totalTests,
    int? passedTests,
    String? displayDeviceId,
    bool? allTestsPassed,
    double? passRate,
  });
}

class _FactoryTestResultUpdateAllImpl implements _FactoryTestResultUpdateAll {
  const _FactoryTestResultUpdateAllImpl(this.collection);

  final IsarCollection<int, FactoryTestResult> collection;

  @override
  int call({
    required List<int> id,
    Object? deviceId = ignore,
    Object? completedAt = ignore,
    Object? status = ignore,
    Object? testedBy = ignore,
    Object? comment = ignore,
    Object? sensorVariant = ignore,
    Object? deviceType = ignore,
    Object? automaticTestsJson = ignore,
    Object? manualTestsJson = ignore,
    Object? totalTests = ignore,
    Object? passedTests = ignore,
    Object? displayDeviceId = ignore,
    Object? allTestsPassed = ignore,
    Object? passRate = ignore,
  }) {
    return collection.updateProperties(id, {
      if (deviceId != ignore) 1: deviceId as String?,
      if (completedAt != ignore) 2: completedAt as DateTime?,
      if (status != ignore) 3: status as String?,
      if (testedBy != ignore) 4: testedBy as String?,
      if (comment != ignore) 5: comment as String?,
      if (sensorVariant != ignore) 6: sensorVariant as int?,
      if (deviceType != ignore) 7: deviceType as String?,
      if (automaticTestsJson != ignore) 8: automaticTestsJson as String?,
      if (manualTestsJson != ignore) 9: manualTestsJson as String?,
      if (totalTests != ignore) 10: totalTests as int?,
      if (passedTests != ignore) 11: passedTests as int?,
      if (displayDeviceId != ignore) 12: displayDeviceId as String?,
      if (allTestsPassed != ignore) 13: allTestsPassed as bool?,
      if (passRate != ignore) 14: passRate as double?,
    });
  }
}

extension FactoryTestResultUpdate on IsarCollection<int, FactoryTestResult> {
  _FactoryTestResultUpdate get update => _FactoryTestResultUpdateImpl(this);

  _FactoryTestResultUpdateAll get updateAll =>
      _FactoryTestResultUpdateAllImpl(this);
}

sealed class _FactoryTestResultQueryUpdate {
  int call({
    String? deviceId,
    DateTime? completedAt,
    String? status,
    String? testedBy,
    String? comment,
    int? sensorVariant,
    String? deviceType,
    String? automaticTestsJson,
    String? manualTestsJson,
    int? totalTests,
    int? passedTests,
    String? displayDeviceId,
    bool? allTestsPassed,
    double? passRate,
  });
}

class _FactoryTestResultQueryUpdateImpl
    implements _FactoryTestResultQueryUpdate {
  const _FactoryTestResultQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<FactoryTestResult> query;
  final int? limit;

  @override
  int call({
    Object? deviceId = ignore,
    Object? completedAt = ignore,
    Object? status = ignore,
    Object? testedBy = ignore,
    Object? comment = ignore,
    Object? sensorVariant = ignore,
    Object? deviceType = ignore,
    Object? automaticTestsJson = ignore,
    Object? manualTestsJson = ignore,
    Object? totalTests = ignore,
    Object? passedTests = ignore,
    Object? displayDeviceId = ignore,
    Object? allTestsPassed = ignore,
    Object? passRate = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (deviceId != ignore) 1: deviceId as String?,
      if (completedAt != ignore) 2: completedAt as DateTime?,
      if (status != ignore) 3: status as String?,
      if (testedBy != ignore) 4: testedBy as String?,
      if (comment != ignore) 5: comment as String?,
      if (sensorVariant != ignore) 6: sensorVariant as int?,
      if (deviceType != ignore) 7: deviceType as String?,
      if (automaticTestsJson != ignore) 8: automaticTestsJson as String?,
      if (manualTestsJson != ignore) 9: manualTestsJson as String?,
      if (totalTests != ignore) 10: totalTests as int?,
      if (passedTests != ignore) 11: passedTests as int?,
      if (displayDeviceId != ignore) 12: displayDeviceId as String?,
      if (allTestsPassed != ignore) 13: allTestsPassed as bool?,
      if (passRate != ignore) 14: passRate as double?,
    });
  }
}

extension FactoryTestResultQueryUpdate on IsarQuery<FactoryTestResult> {
  _FactoryTestResultQueryUpdate get updateFirst =>
      _FactoryTestResultQueryUpdateImpl(this, limit: 1);

  _FactoryTestResultQueryUpdate get updateAll =>
      _FactoryTestResultQueryUpdateImpl(this);
}

class _FactoryTestResultQueryBuilderUpdateImpl
    implements _FactoryTestResultQueryUpdate {
  const _FactoryTestResultQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<FactoryTestResult, FactoryTestResult, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? deviceId = ignore,
    Object? completedAt = ignore,
    Object? status = ignore,
    Object? testedBy = ignore,
    Object? comment = ignore,
    Object? sensorVariant = ignore,
    Object? deviceType = ignore,
    Object? automaticTestsJson = ignore,
    Object? manualTestsJson = ignore,
    Object? totalTests = ignore,
    Object? passedTests = ignore,
    Object? displayDeviceId = ignore,
    Object? allTestsPassed = ignore,
    Object? passRate = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (deviceId != ignore) 1: deviceId as String?,
        if (completedAt != ignore) 2: completedAt as DateTime?,
        if (status != ignore) 3: status as String?,
        if (testedBy != ignore) 4: testedBy as String?,
        if (comment != ignore) 5: comment as String?,
        if (sensorVariant != ignore) 6: sensorVariant as int?,
        if (deviceType != ignore) 7: deviceType as String?,
        if (automaticTestsJson != ignore) 8: automaticTestsJson as String?,
        if (manualTestsJson != ignore) 9: manualTestsJson as String?,
        if (totalTests != ignore) 10: totalTests as int?,
        if (passedTests != ignore) 11: passedTests as int?,
        if (displayDeviceId != ignore) 12: displayDeviceId as String?,
        if (allTestsPassed != ignore) 13: allTestsPassed as bool?,
        if (passRate != ignore) 14: passRate as double?,
      });
    } finally {
      q.close();
    }
  }
}

extension FactoryTestResultQueryBuilderUpdate
    on QueryBuilder<FactoryTestResult, FactoryTestResult, QOperations> {
  _FactoryTestResultQueryUpdate get updateFirst =>
      _FactoryTestResultQueryBuilderUpdateImpl(this, limit: 1);

  _FactoryTestResultQueryUpdate get updateAll =>
      _FactoryTestResultQueryBuilderUpdateImpl(this);
}

extension FactoryTestResultQueryFilter
    on QueryBuilder<FactoryTestResult, FactoryTestResult, QFilterCondition> {
  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 0,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      deviceIdEqualTo(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      deviceIdLessThan(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      deviceIdBetween(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      deviceIdEndsWith(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      completedAtEqualTo(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      completedAtGreaterThan(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      completedAtGreaterThanOrEqualTo(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      completedAtLessThan(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      completedAtLessThanOrEqualTo(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      completedAtBetween(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      statusEqualTo(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      statusGreaterThan(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      statusGreaterThanOrEqualTo(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      statusLessThan(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      statusLessThanOrEqualTo(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      statusBetween(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      statusStartsWith(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      statusEndsWith(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      testedByEqualTo(
    String value, {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      testedByGreaterThan(
    String value, {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      testedByGreaterThanOrEqualTo(
    String value, {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      testedByLessThan(
    String value, {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      testedByLessThanOrEqualTo(
    String value, {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      testedByBetween(
    String lower,
    String upper, {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      testedByStartsWith(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      testedByEndsWith(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      testedByContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      testedByMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      testedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      testedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      commentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      commentIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      commentEqualTo(
    String? value, {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      commentGreaterThan(
    String? value, {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      commentGreaterThanOrEqualTo(
    String? value, {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      commentLessThan(
    String? value, {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      commentLessThanOrEqualTo(
    String? value, {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      commentBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      commentStartsWith(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      commentEndsWith(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      commentContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      commentMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      commentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      commentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      sensorVariantEqualTo(
    int value,
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      sensorVariantGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      sensorVariantGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      sensorVariantLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      sensorVariantLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      sensorVariantBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      deviceTypeEqualTo(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      deviceTypeGreaterThan(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      deviceTypeGreaterThanOrEqualTo(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      deviceTypeLessThan(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      deviceTypeLessThanOrEqualTo(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      deviceTypeBetween(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      deviceTypeStartsWith(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      deviceTypeEndsWith(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      deviceTypeContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      deviceTypeMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      deviceTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      deviceTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      automaticTestsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      automaticTestsJsonGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      automaticTestsJsonGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      automaticTestsJsonLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      automaticTestsJsonLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      automaticTestsJsonBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 8,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      automaticTestsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      automaticTestsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      automaticTestsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      automaticTestsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 8,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      automaticTestsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      automaticTestsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      manualTestsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      manualTestsJsonGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      manualTestsJsonGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      manualTestsJsonLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      manualTestsJsonLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      manualTestsJsonBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      manualTestsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      manualTestsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      manualTestsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      manualTestsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 9,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      manualTestsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 9,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      manualTestsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 9,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      totalTestsEqualTo(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      totalTestsGreaterThan(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      totalTestsGreaterThanOrEqualTo(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      totalTestsLessThan(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      totalTestsLessThanOrEqualTo(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      totalTestsBetween(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      passedTestsEqualTo(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      passedTestsGreaterThan(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      passedTestsGreaterThanOrEqualTo(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      passedTestsLessThan(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      passedTestsLessThanOrEqualTo(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      passedTestsBetween(
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      displayDeviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      displayDeviceIdGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      displayDeviceIdGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      displayDeviceIdLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      displayDeviceIdLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      displayDeviceIdBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 12,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      displayDeviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      displayDeviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      displayDeviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      displayDeviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 12,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      displayDeviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 12,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      displayDeviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 12,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      allTestsPassedEqualTo(
    bool value,
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

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      passRateEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 14,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      passRateGreaterThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 14,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      passRateGreaterThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 14,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      passRateLessThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 14,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      passRateLessThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 14,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterFilterCondition>
      passRateBetween(
    double lower,
    double upper, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 14,
          lower: lower,
          upper: upper,
          epsilon: epsilon,
        ),
      );
    });
  }
}

extension FactoryTestResultQueryObject
    on QueryBuilder<FactoryTestResult, FactoryTestResult, QFilterCondition> {}

extension FactoryTestResultQuerySortBy
    on QueryBuilder<FactoryTestResult, FactoryTestResult, QSortBy> {
  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByDeviceIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy> sortByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByStatusDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByTestedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByTestedByDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByComment({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByCommentDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortBySensorVariant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortBySensorVariantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByDeviceType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        7,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByDeviceTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        7,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByAutomaticTestsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        8,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByAutomaticTestsJsonDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        8,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByManualTestsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        9,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByManualTestsJsonDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        9,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByTotalTests() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByTotalTestsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByPassedTests() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByPassedTestsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByDisplayDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        12,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByDisplayDeviceIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        12,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByAllTestsPassed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByAllTestsPassedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByPassRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      sortByPassRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }
}

extension FactoryTestResultQuerySortThenBy
    on QueryBuilder<FactoryTestResult, FactoryTestResult, QSortThenBy> {
  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByDeviceIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy> thenByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByStatusDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByTestedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByTestedByDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByComment({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByCommentDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenBySensorVariant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenBySensorVariantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByDeviceType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByDeviceTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByAutomaticTestsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByAutomaticTestsJsonDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByManualTestsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByManualTestsJsonDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByTotalTests() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByTotalTestsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByPassedTests() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByPassedTestsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByDisplayDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByDisplayDeviceIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByAllTestsPassed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByAllTestsPassedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByPassRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterSortBy>
      thenByPassRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }
}

extension FactoryTestResultQueryWhereDistinct
    on QueryBuilder<FactoryTestResult, FactoryTestResult, QDistinct> {
  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterDistinct>
      distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterDistinct>
      distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterDistinct>
      distinctByTestedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterDistinct>
      distinctByComment({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterDistinct>
      distinctBySensorVariant() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterDistinct>
      distinctByDeviceType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterDistinct>
      distinctByAutomaticTestsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterDistinct>
      distinctByManualTestsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterDistinct>
      distinctByTotalTests() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterDistinct>
      distinctByPassedTests() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterDistinct>
      distinctByDisplayDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(12, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterDistinct>
      distinctByAllTestsPassed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(13);
    });
  }

  QueryBuilder<FactoryTestResult, FactoryTestResult, QAfterDistinct>
      distinctByPassRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(14);
    });
  }
}

extension FactoryTestResultQueryProperty1
    on QueryBuilder<FactoryTestResult, FactoryTestResult, QProperty> {
  QueryBuilder<FactoryTestResult, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<FactoryTestResult, String, QAfterProperty> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FactoryTestResult, DateTime, QAfterProperty>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FactoryTestResult, String, QAfterProperty> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FactoryTestResult, String, QAfterProperty> testedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<FactoryTestResult, String?, QAfterProperty> commentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<FactoryTestResult, int, QAfterProperty> sensorVariantProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<FactoryTestResult, String, QAfterProperty> deviceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<FactoryTestResult, String, QAfterProperty>
      automaticTestsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<FactoryTestResult, String, QAfterProperty>
      manualTestsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<FactoryTestResult, int, QAfterProperty> totalTestsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<FactoryTestResult, int, QAfterProperty> passedTestsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<FactoryTestResult, String, QAfterProperty>
      displayDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<FactoryTestResult, bool, QAfterProperty>
      allTestsPassedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<FactoryTestResult, double, QAfterProperty> passRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }
}

extension FactoryTestResultQueryProperty2<R>
    on QueryBuilder<FactoryTestResult, R, QAfterProperty> {
  QueryBuilder<FactoryTestResult, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<FactoryTestResult, (R, String), QAfterProperty>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FactoryTestResult, (R, DateTime), QAfterProperty>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FactoryTestResult, (R, String), QAfterProperty>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FactoryTestResult, (R, String), QAfterProperty>
      testedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<FactoryTestResult, (R, String?), QAfterProperty>
      commentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<FactoryTestResult, (R, int), QAfterProperty>
      sensorVariantProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<FactoryTestResult, (R, String), QAfterProperty>
      deviceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<FactoryTestResult, (R, String), QAfterProperty>
      automaticTestsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<FactoryTestResult, (R, String), QAfterProperty>
      manualTestsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<FactoryTestResult, (R, int), QAfterProperty>
      totalTestsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<FactoryTestResult, (R, int), QAfterProperty>
      passedTestsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<FactoryTestResult, (R, String), QAfterProperty>
      displayDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<FactoryTestResult, (R, bool), QAfterProperty>
      allTestsPassedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<FactoryTestResult, (R, double), QAfterProperty>
      passRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }
}

extension FactoryTestResultQueryProperty3<R1, R2>
    on QueryBuilder<FactoryTestResult, (R1, R2), QAfterProperty> {
  QueryBuilder<FactoryTestResult, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<FactoryTestResult, (R1, R2, String), QOperations>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FactoryTestResult, (R1, R2, DateTime), QOperations>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FactoryTestResult, (R1, R2, String), QOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FactoryTestResult, (R1, R2, String), QOperations>
      testedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<FactoryTestResult, (R1, R2, String?), QOperations>
      commentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<FactoryTestResult, (R1, R2, int), QOperations>
      sensorVariantProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<FactoryTestResult, (R1, R2, String), QOperations>
      deviceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<FactoryTestResult, (R1, R2, String), QOperations>
      automaticTestsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<FactoryTestResult, (R1, R2, String), QOperations>
      manualTestsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<FactoryTestResult, (R1, R2, int), QOperations>
      totalTestsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<FactoryTestResult, (R1, R2, int), QOperations>
      passedTestsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<FactoryTestResult, (R1, R2, String), QOperations>
      displayDeviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<FactoryTestResult, (R1, R2, bool), QOperations>
      allTestsPassedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<FactoryTestResult, (R1, R2, double), QOperations>
      passRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }
}
