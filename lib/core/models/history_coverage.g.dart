// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_coverage.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetHistoryCoverageCollection on Isar {
  IsarCollection<String, HistoryCoverage> get historyCoverages =>
      this.collection();
}

final HistoryCoverageSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'HistoryCoverage',
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
        name: 'startSecond',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'endSecond',
        type: IsarType.long,
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
  converter: IsarObjectConverter<String, HistoryCoverage>(
    serialize: serializeHistoryCoverage,
    deserialize: deserializeHistoryCoverage,
    deserializeProperty: deserializeHistoryCoverageProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeHistoryCoverage(IsarWriter writer, HistoryCoverage object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.deviceId);
  IsarCore.writeLong(writer, 3, object.startSecond);
  IsarCore.writeLong(writer, 4, object.endSecond);
  return Isar.fastHash(object.id);
}

@isarProtected
HistoryCoverage deserializeHistoryCoverage(IsarReader reader) {
  final String _deviceId;
  _deviceId = IsarCore.readString(reader, 2) ?? '';
  final int _startSecond;
  _startSecond = IsarCore.readLong(reader, 3);
  final int _endSecond;
  _endSecond = IsarCore.readLong(reader, 4);
  final object = HistoryCoverage(
    deviceId: _deviceId,
    startSecond: _startSecond,
    endSecond: _endSecond,
  );
  return object;
}

@isarProtected
dynamic deserializeHistoryCoverageProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readLong(reader, 3);
    case 4:
      return IsarCore.readLong(reader, 4);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _HistoryCoverageUpdate {
  bool call({
    required String id,
    String? deviceId,
    int? startSecond,
    int? endSecond,
  });
}

class _HistoryCoverageUpdateImpl implements _HistoryCoverageUpdate {
  const _HistoryCoverageUpdateImpl(this.collection);

  final IsarCollection<String, HistoryCoverage> collection;

  @override
  bool call({
    required String id,
    Object? deviceId = ignore,
    Object? startSecond = ignore,
    Object? endSecond = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (deviceId != ignore) 2: deviceId as String?,
          if (startSecond != ignore) 3: startSecond as int?,
          if (endSecond != ignore) 4: endSecond as int?,
        }) >
        0;
  }
}

sealed class _HistoryCoverageUpdateAll {
  int call({
    required List<String> id,
    String? deviceId,
    int? startSecond,
    int? endSecond,
  });
}

class _HistoryCoverageUpdateAllImpl implements _HistoryCoverageUpdateAll {
  const _HistoryCoverageUpdateAllImpl(this.collection);

  final IsarCollection<String, HistoryCoverage> collection;

  @override
  int call({
    required List<String> id,
    Object? deviceId = ignore,
    Object? startSecond = ignore,
    Object? endSecond = ignore,
  }) {
    return collection.updateProperties(id, {
      if (deviceId != ignore) 2: deviceId as String?,
      if (startSecond != ignore) 3: startSecond as int?,
      if (endSecond != ignore) 4: endSecond as int?,
    });
  }
}

extension HistoryCoverageUpdate on IsarCollection<String, HistoryCoverage> {
  _HistoryCoverageUpdate get update => _HistoryCoverageUpdateImpl(this);

  _HistoryCoverageUpdateAll get updateAll =>
      _HistoryCoverageUpdateAllImpl(this);
}

sealed class _HistoryCoverageQueryUpdate {
  int call({
    String? deviceId,
    int? startSecond,
    int? endSecond,
  });
}

class _HistoryCoverageQueryUpdateImpl implements _HistoryCoverageQueryUpdate {
  const _HistoryCoverageQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<HistoryCoverage> query;
  final int? limit;

  @override
  int call({
    Object? deviceId = ignore,
    Object? startSecond = ignore,
    Object? endSecond = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (deviceId != ignore) 2: deviceId as String?,
      if (startSecond != ignore) 3: startSecond as int?,
      if (endSecond != ignore) 4: endSecond as int?,
    });
  }
}

extension HistoryCoverageQueryUpdate on IsarQuery<HistoryCoverage> {
  _HistoryCoverageQueryUpdate get updateFirst =>
      _HistoryCoverageQueryUpdateImpl(this, limit: 1);

  _HistoryCoverageQueryUpdate get updateAll =>
      _HistoryCoverageQueryUpdateImpl(this);
}

class _HistoryCoverageQueryBuilderUpdateImpl
    implements _HistoryCoverageQueryUpdate {
  const _HistoryCoverageQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<HistoryCoverage, HistoryCoverage, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? deviceId = ignore,
    Object? startSecond = ignore,
    Object? endSecond = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (deviceId != ignore) 2: deviceId as String?,
        if (startSecond != ignore) 3: startSecond as int?,
        if (endSecond != ignore) 4: endSecond as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension HistoryCoverageQueryBuilderUpdate
    on QueryBuilder<HistoryCoverage, HistoryCoverage, QOperations> {
  _HistoryCoverageQueryUpdate get updateFirst =>
      _HistoryCoverageQueryBuilderUpdateImpl(this, limit: 1);

  _HistoryCoverageQueryUpdate get updateAll =>
      _HistoryCoverageQueryBuilderUpdateImpl(this);
}

extension HistoryCoverageQueryFilter
    on QueryBuilder<HistoryCoverage, HistoryCoverage, QFilterCondition> {
  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
      startSecondEqualTo(
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
      startSecondGreaterThan(
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
      startSecondGreaterThanOrEqualTo(
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
      startSecondLessThan(
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
      startSecondLessThanOrEqualTo(
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
      startSecondBetween(
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
      endSecondEqualTo(
    int value,
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
      endSecondGreaterThan(
    int value,
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
      endSecondGreaterThanOrEqualTo(
    int value,
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
      endSecondLessThan(
    int value,
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
      endSecondLessThanOrEqualTo(
    int value,
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

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterFilterCondition>
      endSecondBetween(
    int lower,
    int upper,
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

extension HistoryCoverageQueryObject
    on QueryBuilder<HistoryCoverage, HistoryCoverage, QFilterCondition> {}

extension HistoryCoverageQuerySortBy
    on QueryBuilder<HistoryCoverage, HistoryCoverage, QSortBy> {
  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterSortBy> sortById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterSortBy> sortByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterSortBy>
      sortByDeviceIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterSortBy>
      sortByStartSecond() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterSortBy>
      sortByStartSecondDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterSortBy>
      sortByEndSecond() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterSortBy>
      sortByEndSecondDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }
}

extension HistoryCoverageQuerySortThenBy
    on QueryBuilder<HistoryCoverage, HistoryCoverage, QSortThenBy> {
  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterSortBy> thenById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterSortBy> thenByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterSortBy>
      thenByDeviceIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterSortBy>
      thenByStartSecond() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterSortBy>
      thenByStartSecondDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterSortBy>
      thenByEndSecond() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterSortBy>
      thenByEndSecondDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }
}

extension HistoryCoverageQueryWhereDistinct
    on QueryBuilder<HistoryCoverage, HistoryCoverage, QDistinct> {
  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterDistinct>
      distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterDistinct>
      distinctByStartSecond() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<HistoryCoverage, HistoryCoverage, QAfterDistinct>
      distinctByEndSecond() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }
}

extension HistoryCoverageQueryProperty1
    on QueryBuilder<HistoryCoverage, HistoryCoverage, QProperty> {
  QueryBuilder<HistoryCoverage, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<HistoryCoverage, String, QAfterProperty> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<HistoryCoverage, int, QAfterProperty> startSecondProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<HistoryCoverage, int, QAfterProperty> endSecondProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension HistoryCoverageQueryProperty2<R>
    on QueryBuilder<HistoryCoverage, R, QAfterProperty> {
  QueryBuilder<HistoryCoverage, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<HistoryCoverage, (R, String), QAfterProperty>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<HistoryCoverage, (R, int), QAfterProperty>
      startSecondProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<HistoryCoverage, (R, int), QAfterProperty> endSecondProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension HistoryCoverageQueryProperty3<R1, R2>
    on QueryBuilder<HistoryCoverage, (R1, R2), QAfterProperty> {
  QueryBuilder<HistoryCoverage, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<HistoryCoverage, (R1, R2, String), QOperations>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<HistoryCoverage, (R1, R2, int), QOperations>
      startSecondProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<HistoryCoverage, (R1, R2, int), QOperations>
      endSecondProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}
