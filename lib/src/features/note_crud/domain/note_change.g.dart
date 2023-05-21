// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_change.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNoteChangeCollection on Isar {
  IsarCollection<NoteChange> get noteChanges => this.collection();
}

const NoteChangeSchema = CollectionSchema(
  name: r'NoteChange',
  id: 3256683856481765987,
  properties: {
    r'cloudDocumentId': PropertySchema(
      id: 0,
      name: r'cloudDocumentId',
      type: IsarType.string,
    ),
    r'isarId': PropertySchema(
      id: 1,
      name: r'isarId',
      type: IsarType.long,
    ),
    r'timestamp': PropertySchema(
      id: 2,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'type': PropertySchema(
      id: 3,
      name: r'type',
      type: IsarType.byte,
      enumMap: _NoteChangetypeEnumValueMap,
    )
  },
  estimateSize: _noteChangeEstimateSize,
  serialize: _noteChangeSerialize,
  deserialize: _noteChangeDeserialize,
  deserializeProp: _noteChangeDeserializeProp,
  idName: r'id',
  indexes: {
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _noteChangeGetId,
  getLinks: _noteChangeGetLinks,
  attach: _noteChangeAttach,
  version: '3.1.0+1',
);

int _noteChangeEstimateSize(
  NoteChange object,
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
  return bytesCount;
}

void _noteChangeSerialize(
  NoteChange object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cloudDocumentId);
  writer.writeLong(offsets[1], object.isarId);
  writer.writeDateTime(offsets[2], object.timestamp);
  writer.writeByte(offsets[3], object.type.index);
}

NoteChange _noteChangeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NoteChange(
    cloudDocumentId: reader.readStringOrNull(offsets[0]),
    isarId: reader.readLongOrNull(offsets[1]),
    timestamp: reader.readDateTime(offsets[2]),
    type: _NoteChangetypeValueEnumMap[reader.readByteOrNull(offsets[3])] ??
        NoteChangeType.create,
  );
  object.id = id;
  return object;
}

P _noteChangeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (_NoteChangetypeValueEnumMap[reader.readByteOrNull(offset)] ??
          NoteChangeType.create) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _NoteChangetypeEnumValueMap = {
  'create': 0,
  'update': 1,
  'delete': 2,
};
const _NoteChangetypeValueEnumMap = {
  0: NoteChangeType.create,
  1: NoteChangeType.update,
  2: NoteChangeType.delete,
};

Id _noteChangeGetId(NoteChange object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _noteChangeGetLinks(NoteChange object) {
  return [];
}

void _noteChangeAttach(IsarCollection<dynamic> col, Id id, NoteChange object) {
  object.id = id;
}

extension NoteChangeQueryWhereSort
    on QueryBuilder<NoteChange, NoteChange, QWhere> {
  QueryBuilder<NoteChange, NoteChange, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension NoteChangeQueryWhere
    on QueryBuilder<NoteChange, NoteChange, QWhereClause> {
  QueryBuilder<NoteChange, NoteChange, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<NoteChange, NoteChange, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterWhereClause> idBetween(
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

  QueryBuilder<NoteChange, NoteChange, QAfterWhereClause> timestampEqualTo(
      DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterWhereClause> timestampNotEqualTo(
      DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterWhereClause> timestampGreaterThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [timestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterWhereClause> timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [],
        upper: [timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterWhereClause> timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [lowerTimestamp],
        includeLower: includeLower,
        upper: [upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NoteChangeQueryFilter
    on QueryBuilder<NoteChange, NoteChange, QFilterCondition> {
  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
      cloudDocumentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cloudDocumentId',
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
      cloudDocumentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cloudDocumentId',
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
      cloudDocumentIdEqualTo(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
      cloudDocumentIdLessThan(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
      cloudDocumentIdBetween(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
      cloudDocumentIdEndsWith(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
      cloudDocumentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cloudDocumentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
      cloudDocumentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cloudDocumentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
      cloudDocumentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cloudDocumentId',
        value: '',
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
      cloudDocumentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cloudDocumentId',
        value: '',
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> idBetween(
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

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> isarIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isarId',
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
      isarIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isarId',
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> isarIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> isarIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> isarIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> isarIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> timestampEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> typeEqualTo(
      NoteChangeType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> typeGreaterThan(
    NoteChangeType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> typeLessThan(
    NoteChangeType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterFilterCondition> typeBetween(
    NoteChangeType lower,
    NoteChangeType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NoteChangeQueryObject
    on QueryBuilder<NoteChange, NoteChange, QFilterCondition> {}

extension NoteChangeQueryLinks
    on QueryBuilder<NoteChange, NoteChange, QFilterCondition> {}

extension NoteChangeQuerySortBy
    on QueryBuilder<NoteChange, NoteChange, QSortBy> {
  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> sortByCloudDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudDocumentId', Sort.asc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy>
      sortByCloudDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudDocumentId', Sort.desc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> sortByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> sortByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension NoteChangeQuerySortThenBy
    on QueryBuilder<NoteChange, NoteChange, QSortThenBy> {
  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> thenByCloudDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudDocumentId', Sort.asc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy>
      thenByCloudDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cloudDocumentId', Sort.desc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension NoteChangeQueryWhereDistinct
    on QueryBuilder<NoteChange, NoteChange, QDistinct> {
  QueryBuilder<NoteChange, NoteChange, QDistinct> distinctByCloudDocumentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudDocumentId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteChange, NoteChange, QDistinct> distinctByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isarId');
    });
  }

  QueryBuilder<NoteChange, NoteChange, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<NoteChange, NoteChange, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension NoteChangeQueryProperty
    on QueryBuilder<NoteChange, NoteChange, QQueryProperty> {
  QueryBuilder<NoteChange, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NoteChange, String?, QQueryOperations>
      cloudDocumentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudDocumentId');
    });
  }

  QueryBuilder<NoteChange, int?, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<NoteChange, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<NoteChange, NoteChangeType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
