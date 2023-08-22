import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';

class PresentableNoteData {
  final LocalNote note;
  final List<LocalNoteTag> noteTags;

  const PresentableNoteData({
    required this.note,
    required this.noteTags,
  });
}
