// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_note.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetLocalNoteCollection on Isar {
  IsarCollection<int, LocalNote> get localNotes => this.collection();
}

const LocalNoteSchema = IsarCollectionSchema(
  schema:
      '{"name":"LocalNote","idName":"isarId","properties":[{"name":"cloudDocumentId","type":"String"},{"name":"title","type":"String"},{"name":"content","type":"String"},{"name":"tags","type":"LongList"},{"name":"color","type":"Long"},{"name":"isSyncedWithCloud","type":"Bool"},{"name":"created","type":"DateTime"},{"name":"modified","type":"DateTime"}]}',
  converter: IsarObjectConverter<int, LocalNote>(
    serialize: serializeLocalNote,
    deserialize: deserializeLocalNote,
    deserializeProperty: deserializeLocalNoteProp,
  ),
  embeddedSchemas: [],
  //hash: 4819846255785577207,
);

@isarProtected
int serializeLocalNote(IsarWriter writer, LocalNote object) {
  {
    final value = object.cloudDocumentId;
    if (value == null) {
      IsarCore.writeNull(writer, 1);
    } else {
      IsarCore.writeString(writer, 1, value);
    }
  }
  IsarCore.writeString(writer, 2, object.title);
  IsarCore.writeString(writer, 3, object.content);
  {
    final list = object.tags;
    final listWriter = IsarCore.beginList(writer, 4, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeLong(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  IsarCore.writeLong(writer, 5, object.color ?? -9223372036854775808);
  IsarCore.writeBool(writer, 6, object.isSyncedWithCloud);
  IsarCore.writeLong(writer, 7, object.created.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(writer, 8, object.modified.toUtc().microsecondsSinceEpoch);
  return object.isarId;
}

@isarProtected
LocalNote deserializeLocalNote(IsarReader reader) {
  final int _isarId;
  _isarId = IsarCore.readId(reader);
  final String? _cloudDocumentId;
  _cloudDocumentId = IsarCore.readString(reader, 1);
  final String _title;
  _title = IsarCore.readString(reader, 2) ?? '';
  final String _content;
  _content = IsarCore.readString(reader, 3) ?? '';
  final List<int> _tags;
  {
    final length = IsarCore.readList(reader, 4, IsarCore.readerPtrPtr);
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
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      _color = null;
    } else {
      _color = value;
    }
  }
  final bool _isSyncedWithCloud;
  _isSyncedWithCloud = IsarCore.readBool(reader, 6);
  final DateTime _created;
  {
    final value = IsarCore.readLong(reader, 7);
    if (value == -9223372036854775808) {
      _created = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _created = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
    }
  }
  final DateTime _modified;
  {
    final value = IsarCore.readLong(reader, 8);
    if (value == -9223372036854775808) {
      _modified = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _modified = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
    }
  }
  final object = LocalNote(
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

@isarProtected
dynamic deserializeLocalNoteProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1);
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      {
        final length = IsarCore.readList(reader, 4, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <int>[];
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
    case 5:
      {
        final value = IsarCore.readLong(reader, 5);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 6:
      return IsarCore.readBool(reader, 6);
    case 7:
      {
        final value = IsarCore.readLong(reader, 7);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
        }
      }
    case 8:
      {
        final value = IsarCore.readLong(reader, 8);
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

sealed class _LocalNoteUpdate {
  bool call({
    required int isarId,
    String? cloudDocumentId,
    String? title,
    String? content,
    int? color,
    bool? isSyncedWithCloud,
    DateTime? created,
    DateTime? modified,
  });
}

class _LocalNoteUpdateImpl implements _LocalNoteUpdate {
  const _LocalNoteUpdateImpl(this.collection);

  final IsarCollection<int, LocalNote> collection;

  @override
  bool call({
    required int isarId,
    Object? cloudDocumentId = ignore,
    Object? title = ignore,
    Object? content = ignore,
    Object? color = ignore,
    Object? isSyncedWithCloud = ignore,
    Object? created = ignore,
    Object? modified = ignore,
  }) {
    return collection.updateProperties([
          isarId
        ], {
          if (cloudDocumentId != ignore) 1: cloudDocumentId as String?,
          if (title != ignore) 2: title as String?,
          if (content != ignore) 3: content as String?,
          if (color != ignore) 5: color as int?,
          if (isSyncedWithCloud != ignore) 6: isSyncedWithCloud as bool?,
          if (created != ignore) 7: created as DateTime?,
          if (modified != ignore) 8: modified as DateTime?,
        }) >
        0;
  }
}

sealed class _LocalNoteUpdateAll {
  int call({
    required List<int> isarId,
    String? cloudDocumentId,
    String? title,
    String? content,
    int? color,
    bool? isSyncedWithCloud,
    DateTime? created,
    DateTime? modified,
  });
}

class _LocalNoteUpdateAllImpl implements _LocalNoteUpdateAll {
  const _LocalNoteUpdateAllImpl(this.collection);

  final IsarCollection<int, LocalNote> collection;

  @override
  int call({
    required List<int> isarId,
    Object? cloudDocumentId = ignore,
    Object? title = ignore,
    Object? content = ignore,
    Object? color = ignore,
    Object? isSyncedWithCloud = ignore,
    Object? created = ignore,
    Object? modified = ignore,
  }) {
    return collection.updateProperties(isarId, {
      if (cloudDocumentId != ignore) 1: cloudDocumentId as String?,
      if (title != ignore) 2: title as String?,
      if (content != ignore) 3: content as String?,
      if (color != ignore) 5: color as int?,
      if (isSyncedWithCloud != ignore) 6: isSyncedWithCloud as bool?,
      if (created != ignore) 7: created as DateTime?,
      if (modified != ignore) 8: modified as DateTime?,
    });
  }
}

extension LocalNoteUpdate on IsarCollection<int, LocalNote> {
  _LocalNoteUpdate get update => _LocalNoteUpdateImpl(this);

  _LocalNoteUpdateAll get updateAll => _LocalNoteUpdateAllImpl(this);
}

sealed class _LocalNoteQueryUpdate {
  int call({
    String? cloudDocumentId,
    String? title,
    String? content,
    int? color,
    bool? isSyncedWithCloud,
    DateTime? created,
    DateTime? modified,
  });
}

class _LocalNoteQueryUpdateImpl implements _LocalNoteQueryUpdate {
  const _LocalNoteQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<LocalNote> query;
  final int? limit;

  @override
  int call({
    Object? cloudDocumentId = ignore,
    Object? title = ignore,
    Object? content = ignore,
    Object? color = ignore,
    Object? isSyncedWithCloud = ignore,
    Object? created = ignore,
    Object? modified = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (cloudDocumentId != ignore) 1: cloudDocumentId as String?,
      if (title != ignore) 2: title as String?,
      if (content != ignore) 3: content as String?,
      if (color != ignore) 5: color as int?,
      if (isSyncedWithCloud != ignore) 6: isSyncedWithCloud as bool?,
      if (created != ignore) 7: created as DateTime?,
      if (modified != ignore) 8: modified as DateTime?,
    });
  }
}

extension LocalNoteQueryUpdate on IsarQuery<LocalNote> {
  _LocalNoteQueryUpdate get updateFirst =>
      _LocalNoteQueryUpdateImpl(this, limit: 1);

  _LocalNoteQueryUpdate get updateAll => _LocalNoteQueryUpdateImpl(this);
}

extension LocalNoteQueryFilter
    on QueryBuilder<LocalNote, LocalNote, QFilterCondition> {
  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> isarIdEqualTo(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> isarIdGreaterThan(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      cloudDocumentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      cloudDocumentIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> titleEqualTo(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> titleGreaterThan(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      titleGreaterThanOrEqualTo(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      titleLessThanOrEqualTo(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> titleStartsWith(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> titleContains(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> titleMatches(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> contentEqualTo(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> contentGreaterThan(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      contentGreaterThanOrEqualTo(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> contentLessThan(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      contentLessThanOrEqualTo(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> contentBetween(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> contentStartsWith(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> contentEndsWith(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> contentContains(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> contentMatches(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> tagsElementEqualTo(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      tagsElementGreaterThan(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      tagsElementGreaterThanOrEqualTo(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> tagsElementLessThan(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      tagsElementLessThanOrEqualTo(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> tagsElementBetween(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> tagsIsEmpty() {
    return not().tagsIsNotEmpty();
  }

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 4, value: null),
      );
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> colorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> colorIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> colorEqualTo(
    int? value,
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> colorGreaterThan(
    int? value,
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      colorGreaterThanOrEqualTo(
    int? value,
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> colorLessThan(
    int? value,
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      colorLessThanOrEqualTo(
    int? value,
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> colorBetween(
    int? lower,
    int? upper,
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      isSyncedWithCloudEqualTo(
    bool value,
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> createdEqualTo(
    DateTime value,
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> createdGreaterThan(
    DateTime value,
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      createdGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> createdLessThan(
    DateTime value,
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      createdLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> createdBetween(
    DateTime lower,
    DateTime upper,
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> modifiedEqualTo(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> modifiedGreaterThan(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      modifiedGreaterThanOrEqualTo(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> modifiedLessThan(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition>
      modifiedLessThanOrEqualTo(
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

  QueryBuilder<LocalNote, LocalNote, QAfterFilterCondition> modifiedBetween(
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
}

extension LocalNoteQueryObject
    on QueryBuilder<LocalNote, LocalNote, QFilterCondition> {}

extension LocalNoteQuerySortBy on QueryBuilder<LocalNote, LocalNote, QSortBy> {
  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> sortByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> sortByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> sortByCloudDocumentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> sortByCloudDocumentIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> sortByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> sortByTitleDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> sortByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> sortByContentDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> sortByColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> sortByColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> sortByIsSyncedWithCloud() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy>
      sortByIsSyncedWithCloudDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> sortByCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> sortByCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> sortByModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> sortByModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }
}

extension LocalNoteQuerySortThenBy
    on QueryBuilder<LocalNote, LocalNote, QSortThenBy> {
  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> thenByCloudDocumentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> thenByCloudDocumentIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> thenByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> thenByTitleDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> thenByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> thenByContentDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> thenByColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> thenByColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> thenByIsSyncedWithCloud() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy>
      thenByIsSyncedWithCloudDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> thenByCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> thenByCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> thenByModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterSortBy> thenByModifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }
}

extension LocalNoteQueryWhereDistinct
    on QueryBuilder<LocalNote, LocalNote, QDistinct> {
  QueryBuilder<LocalNote, LocalNote, QAfterDistinct> distinctByCloudDocumentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterDistinct> distinctByColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterDistinct>
      distinctByIsSyncedWithCloud() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterDistinct> distinctByCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<LocalNote, LocalNote, QAfterDistinct> distinctByModified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }
}

extension LocalNoteQueryProperty1
    on QueryBuilder<LocalNote, LocalNote, QProperty> {
  QueryBuilder<LocalNote, int, QAfterProperty> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<LocalNote, String?, QAfterProperty> cloudDocumentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<LocalNote, String, QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<LocalNote, String, QAfterProperty> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<LocalNote, List<int>, QAfterProperty> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<LocalNote, int?, QAfterProperty> colorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<LocalNote, bool, QAfterProperty> isSyncedWithCloudProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<LocalNote, DateTime, QAfterProperty> createdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<LocalNote, DateTime, QAfterProperty> modifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

extension LocalNoteQueryProperty2<R>
    on QueryBuilder<LocalNote, R, QAfterProperty> {
  QueryBuilder<LocalNote, (R, int), QAfterProperty> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<LocalNote, (R, String?), QAfterProperty>
      cloudDocumentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<LocalNote, (R, String), QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<LocalNote, (R, String), QAfterProperty> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<LocalNote, (R, List<int>), QAfterProperty> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<LocalNote, (R, int?), QAfterProperty> colorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<LocalNote, (R, bool), QAfterProperty>
      isSyncedWithCloudProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<LocalNote, (R, DateTime), QAfterProperty> createdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<LocalNote, (R, DateTime), QAfterProperty> modifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

extension LocalNoteQueryProperty3<R1, R2>
    on QueryBuilder<LocalNote, (R1, R2), QAfterProperty> {
  QueryBuilder<LocalNote, (R1, R2, int), QOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<LocalNote, (R1, R2, String?), QOperations>
      cloudDocumentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<LocalNote, (R1, R2, String), QOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<LocalNote, (R1, R2, String), QOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<LocalNote, (R1, R2, List<int>), QOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<LocalNote, (R1, R2, int?), QOperations> colorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<LocalNote, (R1, R2, bool), QOperations>
      isSyncedWithCloudProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<LocalNote, (R1, R2, DateTime), QOperations> createdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<LocalNote, (R1, R2, DateTime), QOperations> modifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}
