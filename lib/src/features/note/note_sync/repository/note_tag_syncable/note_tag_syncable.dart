import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_note_tag_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_note_tag_storable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable.dart';

class NoteTagSyncable
    implements Syncable<LocalNoteTagStorable, CloudNoteTagStorable> {
  @override
  Future<void> startSync() {
    // TODO: implement startSync
    throw UnimplementedError();
  }
}
