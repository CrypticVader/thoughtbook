import 'package:flutter/foundation.dart';

enum SortMode { dateModified, dataCreated }

enum SortOrder { ascending, descending }

@immutable
class SortProps {
  final SortMode mode;
  final SortOrder order;

  const SortProps({
    required this.mode,
    required this.order,
  });
}
