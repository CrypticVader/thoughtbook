enum SortMode { dateModified, dataCreated }

enum SortOrder { ascending, descending }

class SortType {
  final SortMode mode;
  final SortOrder order;

  const SortType({
    required this.mode,
    required this.order,
  });
}
