import 'package:flutter/foundation.dart';

@immutable
abstract class NoteState {
  const NoteState();
}

class NoteStateSelected extends NoteState {
  const NoteStateSelected();
}

class NoteStateDeselected extends NoteState {
  const NoteStateDeselected();
}

class NoteStateOpened extends NoteState {
  final bool isEmpty;

  const NoteStateOpened({required this.isEmpty});
}
