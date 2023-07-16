import 'package:thoughtbook/src/features/note/note_sync/repository/note_syncable/note_syncable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_tag_syncable/note_tag_syncable.dart';

class Synchronizer {
  static NoteSyncable get note => NoteSyncable();

  static NoteTagSyncable get noteTag => NoteTagSyncable();
}
