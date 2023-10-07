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

const NoteTagChangeSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'NoteTagChange',
    idName: 'isarId',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'type',
        type: IsarType.byte,
        enumMap: {"create": 0, "update": 1, "delete": 2, "deleteAll": 3},
      ),
      IsarPropertySchema(
        name: 'timestamp',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'noteTag',
        type: IsarType.object,
        target: 'ChangedNoteTag',
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'timestamp',
        properties: [
          "timestamp",
        ],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, NoteTagChange>(
    serialize: serializeNoteTagChange,
    deserialize: deserializeNoteTagChange,
    deserializeProperty: deserializeNoteTagChangeProp,
  ),
  embeddedSchemas: [ChangedNoteTagSchema],
);

@isarProtected
int serializeNoteTagChange(IsarWriter writer, NoteTagChange object) {
  IsarCore.writeByte(writer, 1, object.type.index);
  IsarCore.writeLong(writer, 2, object.timestamp.toUtc().microsecondsSinceEpoch);
  {
    final value = object.noteTag;
    final objectWriter = IsarCore.beginObject(writer, 3);
    serializeChangedNoteTag(objectWriter, value);
    IsarCore.endObject(writer, objectWriter);
  }
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
      _type = _noteTagChangeType[IsarCore.readByte(reader, 1)] ?? SyncableChangeType.create;
    }
  }
  final DateTime _timestamp;
  {
    final value = IsarCore.readLong(reader, 2);
    if (value == -9223372036854775808) {
      _timestamp = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _timestamp = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
    }
  }
  final ChangedNoteTag _noteTag;
  {
    final objectReader = IsarCore.readObject(reader, 3);
    if (objectReader.isNull) {
      _noteTag = ChangedNoteTag(
        isarId: -9223372036854775808,
        name: '',
        cloudDocumentId: null,
        created: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal(),
        modified: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal(),
      );
    } else {
      final embedded = deserializeChangedNoteTag(objectReader);
      IsarCore.freeReader(objectReader);
      _noteTag = embedded;
    }
  }
  final object = NoteTagChange(
    isarId: _isarId,
    type: _type,
    timestamp: _timestamp,
    noteTag: _noteTag,
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
          return _noteTagChangeType[IsarCore.readByte(reader, 1)] ?? SyncableChangeType.create;
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
      {
        final objectReader = IsarCore.readObject(reader, 3);
        if (objectReader.isNull) {
          return ChangedNoteTag(
            isarId: -9223372036854775808,
            name: '',
            cloudDocumentId: null,
            created: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal(),
            modified: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal(),
          );
        } else {
          final embedded = deserializeChangedNoteTag(objectReader);
          IsarCore.freeReader(objectReader);
          return embedded;
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _NoteTagChangeUpdate {
  bool call({
    required int isarId,
    SyncableChangeType? type,
    DateTime? timestamp,
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
  }) {
    return collection.updateProperties([
          isarId
        ], {
          if (type != ignore) 1: type as SyncableChangeType?,
          if (timestamp != ignore) 2: timestamp as DateTime?,
        }) >
        0;
  }
}

sealed class _NoteTagChangeUpdateAll {
  int call({
    required List<int> isarId,
    SyncableChangeType? type,
    DateTime? timestamp,
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
  }) {
    return collection.updateProperties(isarId, {
      if (type != ignore) 1: type as SyncableChangeType?,
      if (timestamp != ignore) 2: timestamp as DateTime?,
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
  }) {
    return query.updateProperties(limit: limit, {
      if (type != ignore) 1: type as SyncableChangeType?,
      if (timestamp != ignore) 2: timestamp as DateTime?,
    });
  }
}

extension NoteTagChangeQueryUpdate on IsarQuery<NoteTagChange> {
  _NoteTagChangeQueryUpdate get updateFirst => _NoteTagChangeQueryUpdateImpl(this, limit: 1);

  _NoteTagChangeQueryUpdate get updateAll => _NoteTagChangeQueryUpdateImpl(this);
}

class _NoteTagChangeQueryBuilderUpdateImpl implements _NoteTagChangeQueryUpdate {
  const _NoteTagChangeQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<NoteTagChange, NoteTagChange, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? type = ignore,
    Object? timestamp = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (type != ignore) 1: type as SyncableChangeType?,
        if (timestamp != ignore) 2: timestamp as DateTime?,
      });
    } finally {
      q.close();
    }
  }
}

extension NoteTagChangeQueryBuilderUpdate
    on QueryBuilder<NoteTagChange, NoteTagChange, QOperations> {
  _NoteTagChangeQueryUpdate get updateFirst => _NoteTagChangeQueryBuilderUpdateImpl(this, limit: 1);

  _NoteTagChangeQueryUpdate get updateAll => _NoteTagChangeQueryBuilderUpdateImpl(this);
}

const _noteTagChangeType = {
  0: SyncableChangeType.create,
  1: SyncableChangeType.update,
  2: SyncableChangeType.delete,
  3: SyncableChangeType.deleteAll,
};

extension NoteTagChangeQueryFilter on QueryBuilder<NoteTagChange, NoteTagChange, QFilterCondition> {
  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> isarIdEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> isarIdGreaterThan(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> isarIdGreaterThanOrEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> isarIdLessThanOrEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> typeGreaterThan(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> typeGreaterThanOrEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> typeLessThan(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> typeLessThanOrEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> timestampEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> timestampGreaterThan(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> timestampGreaterThanOrEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> timestampLessThan(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> timestampLessThanOrEqualTo(
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> timestampBetween(
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
}

extension NoteTagChangeQueryObject on QueryBuilder<NoteTagChange, NoteTagChange, QFilterCondition> {
  QueryBuilder<NoteTagChange, NoteTagChange, QAfterFilterCondition> noteTag(
      FilterQuery<ChangedNoteTag> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, 3);
    });
  }
}

extension NoteTagChangeQuerySortBy on QueryBuilder<NoteTagChange, NoteTagChange, QSortBy> {
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }
}

extension NoteTagChangeQuerySortThenBy on QueryBuilder<NoteTagChange, NoteTagChange, QSortThenBy> {
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

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }
}

extension NoteTagChangeQueryWhereDistinct on QueryBuilder<NoteTagChange, NoteTagChange, QDistinct> {
  QueryBuilder<NoteTagChange, NoteTagChange, QAfterDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }

  QueryBuilder<NoteTagChange, NoteTagChange, QAfterDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }
}

extension NoteTagChangeQueryProperty1 on QueryBuilder<NoteTagChange, NoteTagChange, QProperty> {
  QueryBuilder<NoteTagChange, int, QAfterProperty> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NoteTagChange, SyncableChangeType, QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NoteTagChange, DateTime, QAfterProperty> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NoteTagChange, ChangedNoteTag, QAfterProperty> noteTagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }
}

extension NoteTagChangeQueryProperty2<R> on QueryBuilder<NoteTagChange, R, QAfterProperty> {
  QueryBuilder<NoteTagChange, (R, int), QAfterProperty> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NoteTagChange, (R, SyncableChangeType), QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NoteTagChange, (R, DateTime), QAfterProperty> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NoteTagChange, (R, ChangedNoteTag), QAfterProperty> noteTagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
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

  QueryBuilder<NoteTagChange, (R1, R2, SyncableChangeType), QOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NoteTagChange, (R1, R2, DateTime), QOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NoteTagChange, (R1, R2, ChangedNoteTag), QOperations> noteTagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }
}

// **************************************************************************
// _IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

const ChangedNoteTagSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'ChangedNoteTag',
    embedded: true,
    properties: [
      IsarPropertySchema(
        name: 'isarId',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'cloudDocumentId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'name',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'modified',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'created',
        type: IsarType.dateTime,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<void, ChangedNoteTag>(
    serialize: serializeChangedNoteTag,
    deserialize: deserializeChangedNoteTag,
  ),
);

@isarProtected
int serializeChangedNoteTag(IsarWriter writer, ChangedNoteTag object) {
  IsarCore.writeLong(writer, 1, object.isarId);
  {
    final value = object.cloudDocumentId;
    if (value == null) {
      IsarCore.writeNull(writer, 2);
    } else {
      IsarCore.writeString(writer, 2, value);
    }
  }
  IsarCore.writeString(writer, 3, object.name);
  IsarCore.writeLong(writer, 4, object.modified.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(writer, 5, object.created.toUtc().microsecondsSinceEpoch);
  return 0;
}

@isarProtected
ChangedNoteTag deserializeChangedNoteTag(IsarReader reader) {
  final int _isarId;
  _isarId = IsarCore.readLong(reader, 1);
  final String? _cloudDocumentId;
  _cloudDocumentId = IsarCore.readString(reader, 2);
  final String _name;
  _name = IsarCore.readString(reader, 3) ?? '';
  final DateTime _modified;
  {
    final value = IsarCore.readLong(reader, 4);
    if (value == -9223372036854775808) {
      _modified = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _modified = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
    }
  }
  final DateTime _created;
  {
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      _created = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _created = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
    }
  }
  final object = ChangedNoteTag(
    isarId: _isarId,
    cloudDocumentId: _cloudDocumentId,
    name: _name,
    modified: _modified,
    created: _created,
  );
  return object;
}

extension ChangedNoteTagQueryFilter
    on QueryBuilder<ChangedNoteTag, ChangedNoteTag, QFilterCondition> {
  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> isarIdEqualTo(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> isarIdGreaterThan(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> isarIdGreaterThanOrEqualTo(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> isarIdLessThanOrEqualTo(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> cloudDocumentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> cloudDocumentIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> cloudDocumentIdEqualTo(
    String? value, {
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> cloudDocumentIdGreaterThan(
    String? value, {
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition>
      cloudDocumentIdGreaterThanOrEqualTo(
    String? value, {
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> cloudDocumentIdLessThan(
    String? value, {
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition>
      cloudDocumentIdLessThanOrEqualTo(
    String? value, {
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> cloudDocumentIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> cloudDocumentIdStartsWith(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> cloudDocumentIdEndsWith(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> cloudDocumentIdContains(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> cloudDocumentIdMatches(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> cloudDocumentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> cloudDocumentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> nameGreaterThanOrEqualTo(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> nameLessThanOrEqualTo(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> nameMatches(String pattern,
      {bool caseSensitive = true}) {
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> modifiedEqualTo(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> modifiedGreaterThan(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> modifiedGreaterThanOrEqualTo(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> modifiedLessThan(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> modifiedLessThanOrEqualTo(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> modifiedBetween(
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> createdEqualTo(
    DateTime value,
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> createdGreaterThan(
    DateTime value,
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> createdGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> createdLessThan(
    DateTime value,
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> createdLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<ChangedNoteTag, ChangedNoteTag, QAfterFilterCondition> createdBetween(
    DateTime lower,
    DateTime upper,
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
}

extension ChangedNoteTagQueryObject
    on QueryBuilder<ChangedNoteTag, ChangedNoteTag, QFilterCondition> {}
