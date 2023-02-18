import 'package:flutter/foundation.dart';

import '../../cloud/cloud_note.dart';

@immutable
abstract class NoteEvent {
  const NoteEvent();
}

class NoteEventSelect extends NoteEvent {
  const NoteEventSelect();
}

class NoteEventDeselect extends NoteEvent {
  const NoteEventDeselect();
}

class NoteEventOpen extends NoteEvent {
  final CloudNote note;

  const NoteEventOpen({required this.note});
}
