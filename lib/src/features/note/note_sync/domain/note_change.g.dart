// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_change.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetNoteChangeCollection on Isar {
  IsarCollection<int, NoteChange> get noteChanges => this.collection();
}

const NoteChangeSchema = IsarCollectionSchema(
  schema:
      '{"name":"NoteChange","idName":"isarId","properties":[{"name":"type","type":"Byte","enumMap":{"create":0,"update":1,"delete":2,"deleteAll":3}},{"name":"changedNote","type":"Object","target":"ChangedNote"},{"name":"timestamp","type":"DateTime"}]}',
  converter: IsarObjectConverter<int, NoteChange>(
    serialize: serializeNoteChange,
    deserialize: deserializeNoteChange,
    deserializeProperty: deserializeNoteChangeProp,
  ),
  embeddedSchemas: [ChangedNoteSchema],
  //hash: (-7942045061431579046 * 31 + changedNoteSchemaHash),
);

@isarProtected
int serializeNoteChange(IsarWriter writer, NoteChange object) {
  IsarCore.writeByte(writer, 1, object.type.index);
  {
    final value = object.changedNote;
    final objectWriter = IsarCore.beginObject(writer, 2);
    serializeChangedNote(objectWriter, value);
    IsarCore.endObject(writer, objectWriter);
  }
  IsarCore.writeLong(
      writer, 3, object.timestamp.toUtc().microsecondsSinceEpoch);
  return object.isarId;
}

@isarProtected
NoteChange deserializeNoteChange(IsarReader reader) {
  final int _isarId;
  _isarId = IsarCore.readId(reader);
  final SyncableChangeType _type;
  {
    if (IsarCore.readNull(reader, 1)) {
      _type = SyncableChangeType.create;
    } else {
      _type = _noteChangeType[IsarCore.readByte(reader, 1)] ??
          SyncableChangeType.create;
    }
  }
  final ChangedNote _changedNote;
  {
    final objectReader = IsarCore.readObject(reader, 2);
    if (objectReader.isNull) {
      _changedNote = ChangedNote(
        isarId: -9223372036854775808,
        cloudDocumentId: null,
        title: '',
        content: '',
        tags: const <int>[],
        color: null,
        created: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal(),
        modified: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal(),
        isSyncedWithCloud: false,
      );
    } else {
      final embedded = deserializeChangedNote(objectReader);
      IsarCore.freeReader(objectReader);
      _changedNote = embedded;
    }
  }
  final DateTime _timestamp;
  {
    final value = IsarCore.readLong(reader, 3);
    if (value == -9223372036854775808) {
      _timestamp =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _timestamp = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
    }
  }
  final object = NoteChange(
    isarId: _isarId,
    type: _type,
    changedNote: _changedNote,
    timestamp: _timestamp,
  );
  return object;
}

@isarProtected
dynamic deserializeNoteChangeProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      {
        if (IsarCore.readNull(reader, 1)) {
          return SyncableChangeType.create;
        } else {
          return _noteChangeType[IsarCore.readByte(reader, 1)] ??
              SyncableChangeType.create;
        }
      }
    case 2:
      {
        final objectReader = IsarCore.readObject(reader, 2);
        if (objectReader.isNull) {
          return ChangedNote(
            isarId: -9223372036854775808,
            cloudDocumentId: null,
            title: '',
            content: '',
            tags: const <int>[],
            color: null,
            created:
                DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal(),
            modified:
                DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal(),
            isSyncedWithCloud: false,
          );
        } else {
          final embedded = deserializeChangedNote(objectReader);
          IsarCore.freeReader(objectReader);
          return embedded;
        }
      }
    case 3:
      {
        final value = IsarCore.readLong(reader, 3);
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

sealed class _NoteChangeUpdate {
  bool call({
    required int isarId,
    SyncableChangeType? type,
    DateTime? timestamp,
  });
}

class _NoteChangeUpdateImpl implements _NoteChangeUpdate {
  const _NoteChangeUpdateImpl(this.collection);

  final IsarCollection<int, NoteChange> collection;

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
          if (timestamp != ignore) 3: timestamp as DateTime?,
        }) >
        0;
  }
}

sealed class _NoteChangeUpdateAll {
  int call({
    required List<int> isarId,
    SyncableChangeType? type,
    DateTime? timestamp,
  });
}

class _NoteChangeUpdateAllImpl implements _NoteChangeUpdateAll {
  const _NoteChangeUpdateAllImpl(this.collection);

  final IsarCollection<int, NoteChange> collection;

  @override
  int call({
    required List<int> isarId,
    Object? type = ignore,
    Object? timestamp = ignore,
  }) {
    return collection.updateProperties(isarId, {
      if (type != ignore) 1: type as SyncableChangeType?,
      if (timestamp != ignore) 3: timestamp as DateTime?,
    });
  }
}

extension NoteChangeUpdate on IsarCollection<int, NoteChange> {
  _NoteChangeUpdate get update => _NoteChangeUpdateImpl(this);

  _NoteChangeUpdateAll get updateAll => _NoteChangeUpdateAllImpl(this);
}

sealed class _NoteChangeQueryUpdate {
  int call({
    SyncableChangeType? type,
    DateTime? timestamp,
  });
}

class _NoteChangeQueryUpdateImpl implements _NoteChangeQueryUpdate {
  const _NoteChangeQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<NoteChange> query;
  final int? limit;

  @override
  int call({
    Object? type = ignore,
    Object? timestamp = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (type != ignore) 1: type as SyncableChangeType?,
      if (timestamp != ignore) 3: timestamp as DateTime?,
    });
  }
}

extension NoteChangeQueryUpdate on IsarQuery<NoteChange> {
  _NoteChangeQueryUpdate get updateFirst =>
      _NoteChangeQueryUpdateImpl(this, limit: 1);

  _NoteChangeQueryUpdate get updateAll => _NoteChangeQueryUpdateImpl(this);
}

const _noteChangeType = {
  0: SyncableChangeType.create,
  1: SyncableChangeType.update,
  2: SyncableChangeType.delete,
  3: SyncableChangeType.deleteAll,
};

extension NoteChangeQueryFilter
    on QueryBuilder<NoteChange, NoteChange, QFilterCondition> {
  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> isarIdEqualTo(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> isarIdGreaterThan(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> typeEqualTo(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> typeGreaterThan(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> typeLessThan(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> typeBetween(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> timestampEqualTo(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
      timestampGreaterThan(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
      timestampGreaterThanOrEqualTo(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> timestampLessThan(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
      timestampLessThanOrEqualTo(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> timestampBetween(
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
}

extension NoteChangeQueryObject
    on QueryBuilder<NoteChange, NoteChange, QFilterCondition> {
  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> changedNote(
      FilterQuery<ChangedNote> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, 2);
    });
  }
}

extension NoteChangeQuerySortBy
    on QueryBuilder<NoteChange, NoteChange, QSortBy> {
  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> sortByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> sortByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }
}

extension NoteChangeQuerySortThenBy
    on QueryBuilder<NoteChange, NoteChange, QSortThenBy> {
  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }
}

extension NoteChangeQueryWhereDistinct
    on QueryBuilder<NoteChange, NoteChange, QDistinct> {
  QueryBuilder<NoteChange, NoteChange, QAfterDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }
}

extension NoteChangeQueryProperty1
    on QueryBuilder<NoteChange, NoteChange, QProperty> {
  QueryBuilder<NoteChange, int, QAfterProperty> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NoteChange, SyncableChangeType, QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NoteChange, ChangedNote, QAfterProperty> changedNoteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NoteChange, DateTime, QAfterProperty> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }
}

extension NoteChangeQueryProperty2<R>
    on QueryBuilder<NoteChange, R, QAfterProperty> {
  QueryBuilder<NoteChange, (R, int), QAfterProperty> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NoteChange, (R, SyncableChangeType), QAfterProperty>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NoteChange, (R, ChangedNote), QAfterProperty>
      changedNoteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NoteChange, (R, DateTime), QAfterProperty> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }
}

extension NoteChangeQueryProperty3<R1, R2>
    on QueryBuilder<NoteChange, (R1, R2), QAfterProperty> {
  QueryBuilder<NoteChange, (R1, R2, int), QOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NoteChange, (R1, R2, SyncableChangeType), QOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NoteChange, (R1, R2, ChangedNote), QOperations>
      changedNoteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NoteChange, (R1, R2, DateTime), QOperations>
      timestampProperty() {
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

//const changedNoteSchemaHash = -3969550157125032108;
const ChangedNoteSchema = IsarSchema(
  schema:
      '{"name":"ChangedNote","idName":null,"embedded":true,"properties":[{"name":"isarId","type":"Long"},{"name":"cloudDocumentId","type":"String"},{"name":"title","type":"String"},{"name":"content","type":"String"},{"name":"tags","type":"LongList"},{"name":"color","type":"Long"},{"name":"isSyncedWithCloud","type":"Bool"},{"name":"created","type":"DateTime"},{"name":"modified","type":"DateTime"}]}',
  converter: IsarObjectConverter<void, ChangedNote>(
    serialize: serializeChangedNote,
    deserialize: deserializeChangedNote,
  ),
);

@isarProtected
int serializeChangedNote(IsarWriter writer, ChangedNote object) {
  IsarCore.writeLong(writer, 1, object.isarId);
  {
    final value = object.cloudDocumentId;
    if (value == null) {
      IsarCore.writeNull(writer, 2);
    } else {
      IsarCore.writeString(writer, 2, value);
    }
  }
  IsarCore.writeString(writer, 3, object.title);
  IsarCore.writeString(writer, 4, object.content);
  {
    final list = object.tags;
    final listWriter = IsarCore.beginList(writer, 5, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeLong(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  IsarCore.writeLong(writer, 6, object.color ?? -9223372036854775808);
  IsarCore.writeBool(writer, 7, object.isSyncedWithCloud);
  IsarCore.writeLong(writer, 8, object.created.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(writer, 9, object.modified.toUtc().microsecondsSinceEpoch);
  return 0;
}

@isarProtected
ChangedNote deserializeChangedNote(IsarReader reader) {
  final int _isarId;
  _isarId = IsarCore.readLong(reader, 1);
  final String? _cloudDocumentId;
  _cloudDocumentId = IsarCore.readString(reader, 2);
  final String _title;
  _title = IsarCore.readString(reader, 3) ?? '';
  final String _content;
  _content = IsarCore.readString(reader, 4) ?? '';
  final List<int> _tags;
  {
    final length = IsarCore.readList(reader, 5, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        _tags = const <int>[];
      } else {
        final list =
            List<int>.filled(length, -9223372036854775808, growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readLong(reader, i);
        }
        IsarCore.freeReader(reader);
        _tags = list;
      }
    }
  }
  final int? _color;
  {
    final value = IsarCore.readLong(reader, 6);
    if (value == -9223372036854775808) {
      _color = null;
    } else {
      _color = value;
    }
  }
  final bool _isSyncedWithCloud;
  _isSyncedWithCloud = IsarCore.readBool(reader, 7);
  final DateTime _created;
  {
    final value = IsarCore.readLong(reader, 8);
    if (value == -9223372036854775808) {
      _created = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _created = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
    }
  }
  final DateTime _modified;
  {
    final value = IsarCore.readLong(reader, 9);
    if (value == -9223372036854775808) {
      _modified = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _modified = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
    }
  }
  final object = ChangedNote(
    isarId: _isarId,
    cloudDocumentId: _cloudDocumentId,
    title: _title,
    content: _content,
    tags: _tags,
    color: _color,
    isSyncedWithCloud: _isSyncedWithCloud,
    created: _created,
    modified: _modified,
  );
  return object;
}

extension ChangedNoteQueryFilter
    on QueryBuilder<ChangedNote, ChangedNote, QFilterCondition> {
  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> isarIdEqualTo(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      isarIdGreaterThan(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      isarIdGreaterThanOrEqualTo(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      isarIdLessThanOrEqualTo(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      cloudDocumentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      cloudDocumentIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      cloudDocumentIdEqualTo(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      cloudDocumentIdGreaterThan(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      cloudDocumentIdLessThan(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      cloudDocumentIdBetween(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      cloudDocumentIdStartsWith(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      cloudDocumentIdEndsWith(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      cloudDocumentIdContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      cloudDocumentIdMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      cloudDocumentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      cloudDocumentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> titleEqualTo(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      titleGreaterThan(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      titleGreaterThanOrEqualTo(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      titleLessThanOrEqualTo(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> titleStartsWith(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> titleContains(
      String value,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> titleMatches(
      String pattern,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> contentEqualTo(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      contentGreaterThan(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      contentGreaterThanOrEqualTo(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> contentLessThan(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      contentLessThanOrEqualTo(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> contentBetween(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      contentStartsWith(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> contentEndsWith(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> contentContains(
      String value,
      {bool caseSensitive = true}) {
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> contentMatches(
      String pattern,
      {bool caseSensitive = true}) {
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      tagsElementEqualTo(
    int value,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      tagsElementGreaterThan(
    int value,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      tagsElementGreaterThanOrEqualTo(
    int value,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      tagsElementLessThan(
    int value,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      tagsElementLessThanOrEqualTo(
    int value,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      tagsElementBetween(
    int lower,
    int upper,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> tagsIsEmpty() {
    return not().tagsIsNotEmpty();
  }

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 5, value: null),
      );
    });
  }

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> colorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      colorIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> colorEqualTo(
    int? value,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      colorGreaterThan(
    int? value,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      colorGreaterThanOrEqualTo(
    int? value,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> colorLessThan(
    int? value,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      colorLessThanOrEqualTo(
    int? value,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> colorBetween(
    int? lower,
    int? upper,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      isSyncedWithCloudEqualTo(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> createdEqualTo(
    DateTime value,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      createdGreaterThan(
    DateTime value,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      createdGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> createdLessThan(
    DateTime value,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      createdLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> createdBetween(
    DateTime lower,
    DateTime upper,
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> modifiedEqualTo(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      modifiedGreaterThan(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      modifiedGreaterThanOrEqualTo(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      modifiedLessThan(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition>
      modifiedLessThanOrEqualTo(
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

  QueryBuilder<ChangedNote, ChangedNote, QAfterFilterCondition> modifiedBetween(
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
}

extension ChangedNoteQueryObject
    on QueryBuilder<ChangedNote, ChangedNote, QFilterCondition> {}
