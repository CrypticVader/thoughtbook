// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_tag.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNoteTagCollection on Isar {
  IsarCollection<NoteTag> get noteTags => this.collection();
}

const NoteTagSchema = CollectionSchema(
  name: r'NoteTag',
  id: -2249254562771179960,
  properties: {
    r'cloudDocumentId': PropertySchema(
      id: 0,
      name: r'cloudDocumentId',
      type: IsarType.string,
    ),
    r'hashCode': PropertySchema(
      id: 1,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _noteTagEstimateSize,
  serialize: _noteTagSerialize,
  deserialize: _noteTagDeserialize,
  deserializeProp: _noteTagDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _noteTagGetId,
  getLinks: _noteTagGetLinks,
  attach: _noteTagAttach,
  version: '3.1.0+1',
);

int _noteTagEstimateSize(
  NoteTag object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.cloudDocumentId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _noteTagSerialize(
  NoteTag object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cloudDocumentId);
  writer.writeLong(offsets[1], object.hashCode);
  writer.writeString(offsets[2], object.name);
}

NoteTag _noteTagDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NoteTag(
    cloudDocumentId: reader.readStringOrNull(offsets[0]),
    name: reader.readString(offsets[2]),
  );
  object.id = id;
  return object;
}

P _noteTagDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _noteTagGetId(NoteTag object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _noteTagGetLinks(NoteTag object) {
  return [];
}

void _noteTagAttach(IsarCollection<dynamic> col, Id id, NoteTag object) {
  object.id = id;
}

extension NoteTagByIndex on IsarCollection<NoteTag> {
  Future<NoteTag?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  NoteTag? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<NoteTag?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<NoteTag?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(NoteTag object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(NoteTag object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<NoteTag> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<NoteTag> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension NoteTagQueryWhereSort on QueryBuilder<NoteTag, NoteTag, QWhere> {
  QueryBuilder<NoteTag, NoteTag, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NoteTagQueryWhere on QueryBuilder<NoteTag, NoteTag, QWhereClause> {
  QueryBuilder<NoteTag, NoteTag, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterWhereClause> nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension NoteTagQueryFilter
    on QueryBuilder<NoteTag, NoteTag, QFilterCondition> {
  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition>
      cloudDocumentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cloudDocumentId',
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition>
      cloudDocumentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cloudDocumentId',
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> cloudDocumentIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cloudDocumentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition>
      cloudDocumentIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cloudDocumentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> cloudDocumentIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cloudDocumentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> cloudDocumentIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cloudDocumentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition>
      cloudDocumentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cloudDocumentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> cloudDocumentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cloudDocumentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> cloudDocumentIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cloudDocumentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> cloudDocumentIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cloudDocumentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition>
      cloudDocumentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cloudDocumentId',
        value: '',
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition>
      cloudDocumentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cloudDocumentId',
        value: '',
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> hashCodeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension NoteTagQueryObject
    on QueryBuilder<NoteTag, NoteTag, QFilterCondition> {}

extension NoteTagQueryLinks
    on QueryBuilder<NoteTag, NoteTag, QFilterCondition> {}

extension NoteTagQuerySortBy on QueryBuilder<NoteTag, NoteTag, QSortBy> {
  QueryBuilder<NoteTag, NoteTag, QAfterSortBy> sortByCloudDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudDocumentId', Sort.asc);
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterSortBy> sortByCloudDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudDocumentId', Sort.desc);
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterSortBy> sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterSortBy> sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension NoteTagQuerySortThenBy
    on QueryBuilder<NoteTag, NoteTag, QSortThenBy> {
  QueryBuilder<NoteTag, NoteTag, QAfterSortBy> thenByCloudDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudDocumentId', Sort.asc);
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterSortBy> thenByCloudDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudDocumentId', Sort.desc);
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterSortBy> thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterSortBy> thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<NoteTag, NoteTag, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension NoteTagQueryWhereDistinct
    on QueryBuilder<NoteTag, NoteTag, QDistinct> {
  QueryBuilder<NoteTag, NoteTag, QDistinct> distinctByCloudDocumentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudDocumentId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteTag, NoteTag, QDistinct> distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<NoteTag, NoteTag, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension NoteTagQueryProperty
    on QueryBuilder<NoteTag, NoteTag, QQueryProperty> {
  QueryBuilder<NoteTag, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NoteTag, String?, QQueryOperations> cloudDocumentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudDocumentId');
    });
  }

  QueryBuilder<NoteTag, int, QQueryOperations> hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<NoteTag, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}
