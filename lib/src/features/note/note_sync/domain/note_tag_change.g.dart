// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_tag_change.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetNoteTagChangeCollection on Isar {
  IsarCollection<int, NoteTagChange> get noteTagChanges => this.collection();
}

const NoteTagChangeSchema = IsarCollectionSchema(
  schema:
      '{"name":"NoteTagChange","idName":"isarId","properties":[{"name":"type","type":"Byte","enumMap":{"create":0,"update":1,"delete":2,"deleteAll":3}},{"name":"timestamp","type":"DateTime"},{"name":"noteTagIsarId","type":"Long"},{"name":"cloudDocumentId","type":"String"},{"name":"name","type":"String"}]}',
  converter: IsarObjectConverter<int, NoteTagChange>(
    serialize: serializeNoteTagChange,
    deserialize: deserializeNoteTagChange,
    deserializeProperty: deserializeNoteTagChangeProp,
  ),
  embeddedSchemas: [],
  //hash: 5818572411166899962,
);

@isarProtected
int serializeNoteTagChange(IsarWriter writer, NoteTagChange object) {
  IsarCore.writeByte(writer, 1, object.type.index);
  IsarCore.writeLong(
      writer, 2, object.timestamp.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(writer, 3, object.noteTagIsarId);
  {
    final value = object.cloudDocumentId;
    if (value == null) {
      IsarCore.writeNull(writer, 4);
    } else {
      IsarCore.writeString(writer, 4, value);
    }
  }
  IsarCore.writeString(writer, 5, object.name);
  return object.isarId;
}

@isarProtected
NoteTagChange deserializeNoteTagChange(IsarReader reader) {
  final int _isarId;
  _isarId = IsarCore.readId(reader);
  final SyncableChangeType _type;
  {
    if (IsarCore.readNull(reader, 1)) {
      _type = SyncableChangeType.create;
    } else {
      _type = _noteTagChangeType[IsarCore.readByte(reader, 1)] ??
          SyncableChangeType.create;
    }
  }
  final DateTime _timestamp;
  {
    final value = IsarCore.readLong(reader, 2);
    if (value == -9223372036854775808) {
      _timestamp =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _timestamp = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
    }
  }
  final int _noteTagIsarId;
  _noteTagIsarId = IsarCore.readLong(reader, 3);
  final String? _cloudDocumentId;
  _cloudDocumentId = IsarCore.readString(reader, 4);
  final String _name;
  _name = IsarCore.readString(reader, 5) ?? '';
  final object = NoteTagChange(
    isarId: _isarId,
    type: _type,
    timestamp: _timestamp,
    noteTagIsarId: _noteTagIsarId,
    cloudDocumentId: _cloudDocumentId,
    name: _name,
  );
  return object;
}

@isarProtected
dynamic deserializeNoteTagChangeProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      {
        if (IsarCore.readNull(reader, 1)) {
          return SyncableChangeType.create;
        } else {
          return _noteTagChangeType[IsarCore.readByte(reader, 1)] ??
              SyncableChangeType.create;
        }
      }
    case 2:
      {
        final value = IsarCore.readLong(reader, 2);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
        }
      }
    case 3:
      return IsarCore.readLong(reader, 3);
    case 4:
      return IsarCore.readString(reader, 4);
    case 5:
      return IsarCore.readString(reader, 5) ?? '';
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _NoteTagChangeUpdate {
  bool call({
    required int isarId,
    SyncableChangeType? type,
    DateTime? timestamp,
    int? noteTagIsarId,
    String? cloudDocumentId,
    String? name,
  });
}

class _NoteTagChangeUpdateImpl implements _NoteTagChangeUpdate {
  const _NoteTagChangeUpdateImpl(this.collection);

  final IsarCollection<int, NoteTagChange> collection;

  @override
  bool call({
    required int isarId,
    Object? type = ignore,
    Object? timestamp = ignore,
    Object? noteTagIsarId = ignore,
    Object? cloudDocumentId = ignore,
    Object? name = ignore,
  }) {
    return collection.updateProperties([
          isarId
        ], {
          if (type != ignore) 1: type as SyncableChangeType?,
          if (timestamp != ignore) 2: timestamp as DateTime?,
          if (noteTagIsarId != ignore) 3: noteTagIsarId as int?,
          if (cloudDocumentId != ignore) 4: cloudDocumentId as String?,
          if (name != ignore) 5: name as String?,
        }) >
        0;
  }
}

sealed class _NoteTagChangeUpdateAll {
  int call({
    required List<int> isarId,
    SyncableChangeType? type,
    DateTime? timestamp,
    int? noteTagIsarId,
    String? cloudDocumentId,
    String? name,
  });
}

class _NoteTagChangeUpdateAllImpl implements _NoteTagChangeUpdateAll {
  const _NoteTagChangeUpdateAllImpl(this.collection);

  final IsarCollection<int, NoteTagChange> collection;

  @override
  int call({
    required List<int> isarId,
    Object? type = ignore,
    Object? timestamp = ignore,
    Object? noteTagIsarId = ignore,
    Object? cloudDocumentId = ignore,
    Object? name = ignore,
  }) {
    return collection.updateProperties(isarId, {
      if (type != ignore) 1: type as SyncableChangeType?,
      if (timestamp != ignore) 2: timestamp as DateTime?,
      if (noteTagIsarId != ignore) 3: noteTagIsarId as int?,
      if (cloudDocumentId != ignore) 4: cloudDocumentId as String?,
      if (name != ignore) 5: name as String?,
    });
  }
}

extension NoteTagChangeUpdate on IsarCollection<int, NoteTagChange> {
  _NoteTagChangeUpdate get update => _NoteTagChangeUpdateImpl(this);

  _NoteTagChangeUpdateAll get updateAll => _NoteTagChangeUpdateAllImpl(this);
}

sealed class _NoteTagChangeQueryUpdate {
  int call({
    SyncableChangeType? type,
    DateTime? timestamp,
    int? noteTagIsarId,
    String? cloudDocumentId,
    String? name,
  });
}

class _NoteTagChangeQueryUpdateImpl implements _NoteTagChangeQueryUpdate {
  const _NoteTagChangeQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<NoteTagChange> query;
  final int? limit;

  @override
  int call({
    Object? type = ignore,
    Object? timestamp = ignore,
    Object? noteTagIsarId = ignore,
    Object? cloudDocumentId = ignore,
    Object? name = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (type != ignore) 1: type as SyncableChangeType?,
      if (timestamp != ignore) 2: timestamp as DateTime?,
      if (noteTagIsarId != ignore) 3: noteTagIsarId as int?,
      if (cloudDocumentId != ignore) 4: cloudDocumentId as String?,
      if (name != ignore) 5: name as String?,
    });
  }
}

extension NoteTagChangeQueryUpdate on IsarQuery<NoteTagChange> {
  _NoteTagChangeQueryUpdate get updateFirst =>
      _NoteTagChangeQueryUpdateImpl(this, limit: 1);

  _NoteTagChangeQueryUpdate get updateAll =>
      _NoteTagChangeQueryUpdateImpl(this);
}

const _noteTagChangeType = {
  0: SyncableChangeType.create,
  1: SyncableChangeType.update,
  2: SyncableChangeType.delete,
  3: SyncableChangeType.deleteAll,
};

extension NoteTagChangeQueryFilter
    on QueryBuilder<NoteTagChange, NoteTagChange, QFilterCondition> {
  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      isarIdEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      isarIdBetween(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> typeEqualTo(
    SyncableChangeType value,
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      typeGreaterThan(
    SyncableChangeType value,
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      typeGreaterThanOrEqualTo(
    SyncableChangeType value,
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      typeLessThan(
    SyncableChangeType value,
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      typeLessThanOrEqualTo(
    SyncableChangeType value,
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> typeBetween(
    SyncableChangeType lower,
    SyncableChangeType upper,
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      timestampEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      timestampGreaterThan(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      timestampGreaterThanOrEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      timestampLessThan(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      timestampLessThanOrEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      timestampBetween(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      noteTagIsarIdEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      noteTagIsarIdGreaterThan(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      noteTagIsarIdGreaterThanOrEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      noteTagIsarIdLessThan(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      noteTagIsarIdLessThanOrEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      noteTagIsarIdBetween(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      cloudDocumentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      cloudDocumentIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      cloudDocumentIdEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      cloudDocumentIdGreaterThan(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      cloudDocumentIdGreaterThanOrEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      cloudDocumentIdLessThan(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      cloudDocumentIdLessThanOrEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      cloudDocumentIdBetween(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      cloudDocumentIdStartsWith(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      cloudDocumentIdEndsWith(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      cloudDocumentIdContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      cloudDocumentIdMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      cloudDocumentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      cloudDocumentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      nameGreaterThan(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      nameGreaterThanOrEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      nameLessThan(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      nameLessThanOrEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      nameStartsWith(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      nameEndsWith(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition>
      nameIsNotEmpty() {
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

extension NoteTagChangeQueryObject
    on QueryBuilder<NoteTagChange, NoteTagChange, QFilterCondition> {}

extension NoteTagChangeQuerySortBy
    on QueryBuilder<NoteTagChange, NoteTagChange, QSortBy> {
  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy> sortByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy> sortByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy>
      sortByNoteTagIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy>
      sortByNoteTagIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy>
      sortByCloudDocumentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy>
      sortByCloudDocumentIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy> sortByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy> sortByNameDesc(
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

extension NoteTagChangeQuerySortThenBy
    on QueryBuilder<NoteTagChange, NoteTagChange, QSortThenBy> {
  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy>
      thenByNoteTagIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy>
      thenByNoteTagIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy>
      thenByCloudDocumentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy>
      thenByCloudDocumentIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy> thenByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy> thenByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension NoteTagChangeQueryWhereDistinct
    on QueryBuilder<NoteTagChange, NoteTagChange, QDistinct> {
  QueryBuilder<NoteTagChange, NoteTagChange, QAfterDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterDistinct>
      distinctByNoteTagIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterDistinct>
      distinctByCloudDocumentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }
}

extension NoteTagChangeQueryProperty1
    on QueryBuilder<NoteTagChange, NoteTagChange, QProperty> {
  QueryBuilder<NoteTagChange, int, QAfterProperty> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NoteTagChange, SyncableChangeType, QAfterProperty>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NoteTagChange, DateTime, QAfterProperty> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NoteTagChange, int, QAfterProperty> noteTagIsarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NoteTagChange, String?, QAfterProperty>
      cloudDocumentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NoteTagChange, String, QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

extension NoteTagChangeQueryProperty2<R>
    on QueryBuilder<NoteTagChange, R, QAfterProperty> {
  QueryBuilder<NoteTagChange, (R, int), QAfterProperty> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NoteTagChange, (R, SyncableChangeType), QAfterProperty>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NoteTagChange, (R, DateTime), QAfterProperty>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NoteTagChange, (R, int), QAfterProperty>
      noteTagIsarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NoteTagChange, (R, String?), QAfterProperty>
      cloudDocumentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NoteTagChange, (R, String), QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

extension NoteTagChangeQueryProperty3<R1, R2>
    on QueryBuilder<NoteTagChange, (R1, R2), QAfterProperty> {
  QueryBuilder<NoteTagChange, (R1, R2, int), QOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NoteTagChange, (R1, R2, SyncableChangeType), QOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NoteTagChange, (R1, R2, DateTime), QOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NoteTagChange, (R1, R2, int), QOperations>
      noteTagIsarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NoteTagChange, (R1, R2, String?), QOperations>
      cloudDocumentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NoteTagChange, (R1, R2, String), QOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}
