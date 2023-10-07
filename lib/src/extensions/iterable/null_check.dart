extension IterableNullCheck on Iterable? {
  bool get isNotNullAndNotEmpty => this?.isNotEmpty ?? false;

  bool get isNullOrEmpty => this?.isEmpty ?? true;
}
