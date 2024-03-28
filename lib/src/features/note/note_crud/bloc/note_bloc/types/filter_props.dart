import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class FilterProps with EquatableMixin {
  Set<int> filterTagIds;
  bool requireEntireTagFilter;

  DateTimeRange? modifiedRange;

  DateTimeRange? createdRange;

  Set<int> filterColors;

  FilterProps({
    required this.filterTagIds,
    required this.requireEntireTagFilter,
    this.modifiedRange,
    this.createdRange,
    required this.filterColors,
  });

  factory FilterProps.noFilters() => FilterProps(
        filterTagIds: {},
        requireEntireTagFilter: true,
        filterColors: {},
      );

  @override
  List<Object?> get props => [
        filterTagIds,
        requireEntireTagFilter,
        modifiedRange,
        createdRange,
        filterColors,
      ];
}

final noColorFilter = {-1};
final noTagFilter = {-1};
