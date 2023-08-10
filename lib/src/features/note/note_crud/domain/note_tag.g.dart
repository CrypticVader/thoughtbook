// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_tag.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetLocalNoteTagCollection on Isar {
  IsarCollection<int, LocalNoteTag> get localNoteTags => this.collection();
}

const LocalNoteTagSchema = IsarCollectionSchema(
  schema:
      '{"name":"LocalNoteTag","idName":"isarId","properties":[{"name":"cloudDocumentId","type":"String"},{"name":"name","type":"String"},{"name":"modified","type":"DateTime"},{"name":"created","type":"DateTime"}]}',
  converter: IsarObjectConverter<int, LocalNoteTag>(
    serialize: serializeLocalNoteTag,
    deserialize: deserializeLocalNoteTag,
    deserializeProperty: deserializeLocalNoteTagProp,
  ),
  embeddedSchemas: [],
  //hash: -2388113918666744575,
);

@isarProtected
int serializeLocalNoteTag(IsarWriter writer, LocalNoteTag object) {
  {
    final value = object.cloudDocumentId;
    if (value == null) {
      IsarCore.writeNull(writer, 1);
    } else {
      IsarCore.writeString(writer, 1, value);
    }
  }
  IsarCore.writeString(writer, 2, object.name);
  IsarCore.writeLong(writer, 3, object.modified.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(writer, 4, object.created.toUtc().microsecondsSinceEpoch);
  return object.isarId;
}

@isarProtected
LocalNoteTag deserializeLocalNoteTag(IsarReader reader) {
  final int _isarId;
  _isarId = IsarCore.readId(reader);
  final String? _cloudDocumentId;
  _cloudDocumentId = IsarCore.readString(reader, 1);
  final String _name;
  _name = IsarCore.readString(reader, 2) ?? '';
  final DateTime _modified;
  {
    final value = IsarCore.readLong(reader, 3);
    if (value == -9223372036854775808) {
      _modified = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _modified = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
    }
  }
  final DateTime _created;
  {
    final value = IsarCore.readLong(reader, 4);
    if (value == -9223372036854775808) {
      _created = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _created = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
    }
  }
  final object = LocalNoteTag(
    isarId: _isarId,
    cloudDocumentId: _cloudDocumentId,
    name: _name,
    modified: _modified,
    created: _created,
  );
  return object;
}

@isarProtected
dynamic deserializeLocalNoteTagProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1);
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      {
        final value = IsarCore.readLong(reader, 3);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
        }
      }
    case 4:
      {
        final value = IsarCore.readLong(reader, 4);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _LocalNoteTagUpdate {
  bool call({
    required int isarId,
    String? cloudDocumentId,
    String? name,
    DateTime? modified,
    DateTime? created,
  });
}

class _LocalNoteTagUpdateImpl implements _LocalNoteTagUpdate {
  const _LocalNoteTagUpdateImpl(this.collection);

  final IsarCollection<int, LocalNoteTag> collection;

  @override
  bool call({
    required int isarId,
    Object? cloudDocumentId = ignore,
    Object? name = ignore,
    Object? modified = ignore,
    Object? created = ignore,
  }) {
    return collection.updateProperties([
          isarId
        ], {
          if (cloudDocumentId != ignore) 1: cloudDocumentId as String?,
          if (name != ignore) 2: name as String?,
          if (modified != ignore) 3: modified as DateTime?,
          if (created != ignore) 4: created as DateTime?,
        }) >
        0;
  }
}

sealed class _LocalNoteTagUpdateAll {
  int call({
    required List<int> isarId,
    String? cloudDocumentId,
    String? name,
    DateTime? modified,
    DateTime? created,
  });
}

class _LocalNoteTagUpdateAllImpl implements _LocalNoteTagUpdateAll {
  const _LocalNoteTagUpdateAllImpl(this.collection);

  final IsarCollection<int, LocalNoteTag> collection;

  @override
  int call({
    required List<int> isarId,
    Object? cloudDocumentId = ignore,
    Object? name = ignore,
    Object? modified = ignore,
    Object? created = ignore,
  }) {
    return collection.updateProperties(isarId, {
      if (cloudDocumentId != ignore) 1: cloudDocumentId as String?,
      if (name != ignore) 2: name as String?,
      if (modified != ignore) 3: modified as DateTime?,
      if (created != ignore) 4: created as DateTime?,
    });
  }
}

extension LocalNoteTagUpdate on IsarCollection<int, LocalNoteTag> {
  _LocalNoteTagUpdate get update => _LocalNoteTagUpdateImpl(this);

  _LocalNoteTagUpdateAll get updateAll => _LocalNoteTagUpdateAllImpl(this);
}

sealed class _LocalNoteTagQueryUpdate {
  int call({
    String? cloudDocumentId,
    String? name,
    DateTime? modified,
    DateTime? created,
  });
}

class _LocalNoteTagQueryUpdateImpl implements _LocalNoteTagQueryUpdate {
  const _LocalNoteTagQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<LocalNoteTag> query;
  final int? limit;

  @override
  int call({
    Object? cloudDocumentId = ignore,
    Object? name = ignore,
    Object? modified = ignore,
    Object? created = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (cloudDocumentId != ignore) 1: cloudDocumentId as String?,
      if (name != ignore) 2: name as String?,
      if (modified != ignore) 3: modified as DateTime?,
      if (created != ignore) 4: created as DateTime?,
    });
  }
}

extension LocalNoteTagQueryUpdate on IsarQuery<LocalNoteTag> {
  _LocalNoteTagQueryUpdate get updateFirst =>
      _LocalNoteTagQueryUpdateImpl(this, limit: 1);

  _LocalNoteTagQueryUpdate get updateAll => _LocalNoteTagQueryUpdateImpl(this);
}

extension LocalNoteTagQueryFilter
    on QueryBuilder<LocalNoteTag, LocalNoteTag, QFilterCondition> {
  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition> isarIdEqualTo(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      isarIdGreaterThan(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      isarIdGreaterThanOrEqualTo(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      isarIdLessThan(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      isarIdLessThanOrEqualTo(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      cloudDocumentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      cloudDocumentIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      cloudDocumentIdEqualTo(
    String? value, {
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      cloudDocumentIdGreaterThan(
    String? value, {
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      cloudDocumentIdGreaterThanOrEqualTo(
    String? value, {
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      cloudDocumentIdLessThan(
    String? value, {
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      cloudDocumentIdLessThanOrEqualTo(
    String? value, {
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      cloudDocumentIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      cloudDocumentIdStartsWith(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      cloudDocumentIdEndsWith(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      cloudDocumentIdContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      cloudDocumentIdMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      cloudDocumentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      cloudDocumentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      nameGreaterThan(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      nameGreaterThanOrEqualTo(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      nameLessThanOrEqualTo(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      nameStartsWith(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      modifiedEqualTo(
    DateTime value,
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      modifiedGreaterThan(
    DateTime value,
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      modifiedGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      modifiedLessThan(
    DateTime value,
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      modifiedLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      modifiedBetween(
    DateTime lower,
    DateTime upper,
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      createdEqualTo(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      createdGreaterThan(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      createdGreaterThanOrEqualTo(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      createdLessThan(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      createdLessThanOrEqualTo(
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

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterFilterCondition>
      createdBetween(
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
}

extension LocalNoteTagQueryObject
    on QueryBuilder<LocalNoteTag, LocalNoteTag, QFilterCondition> {}

extension LocalNoteTagQuerySortBy
    on QueryBuilder<LocalNoteTag, LocalNoteTag, QSortBy> {
  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> sortByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> sortByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> sortByCloudDocumentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy>
      sortByCloudDocumentIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> sortByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> sortByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> sortByModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> sortByModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> sortByCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> sortByCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }
}

extension LocalNoteTagQuerySortThenBy
    on QueryBuilder<LocalNoteTag, LocalNoteTag, QSortThenBy> {
  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> thenByCloudDocumentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy>
      thenByCloudDocumentIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> thenByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> thenByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> thenByModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> thenByModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> thenByCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterSortBy> thenByCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }
}

extension LocalNoteTagQueryWhereDistinct
    on QueryBuilder<LocalNoteTag, LocalNoteTag, QDistinct> {
  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterDistinct>
      distinctByCloudDocumentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterDistinct>
      distinctByModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<LocalNoteTag, LocalNoteTag, QAfterDistinct> distinctByCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }
}

extension LocalNoteTagQueryProperty1
    on QueryBuilder<LocalNoteTag, LocalNoteTag, QProperty> {
  QueryBuilder<LocalNoteTag, int, QAfterProperty> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<LocalNoteTag, String?, QAfterProperty>
      cloudDocumentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<LocalNoteTag, String, QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<LocalNoteTag, DateTime, QAfterProperty> modifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<LocalNoteTag, DateTime, QAfterProperty> createdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension LocalNoteTagQueryProperty2<R>
    on QueryBuilder<LocalNoteTag, R, QAfterProperty> {
  QueryBuilder<LocalNoteTag, (R, int), QAfterProperty> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<LocalNoteTag, (R, String?), QAfterProperty>
      cloudDocumentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<LocalNoteTag, (R, String), QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<LocalNoteTag, (R, DateTime), QAfterProperty> modifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<LocalNoteTag, (R, DateTime), QAfterProperty> createdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}

extension LocalNoteTagQueryProperty3<R1, R2>
    on QueryBuilder<LocalNoteTag, (R1, R2), QAfterProperty> {
  QueryBuilder<LocalNoteTag, (R1, R2, int), QOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<LocalNoteTag, (R1, R2, String?), QOperations>
      cloudDocumentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<LocalNoteTag, (R1, R2, String), QOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<LocalNoteTag, (R1, R2, DateTime), QOperations>
      modifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<LocalNoteTag, (R1, R2, DateTime), QOperations>
      createdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }
}
