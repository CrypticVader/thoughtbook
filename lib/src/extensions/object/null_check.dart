extension ObjectNullCheck on Object? {
  bool get isNull => (this == null) ? true : false;

  bool get isNotNull => (this == null) ? false : true;
}
