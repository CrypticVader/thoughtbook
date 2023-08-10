import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';

class LocalNoteTagStorable extends LocalStorable<LocalNoteTag> {
  LocalNoteTagStorable() {
    _cacheNoteTags();
    _noteTagsStreamController =
        BehaviorSubject<List<LocalNoteTag>>.seeded(_tags);
    log('Created LocalNoteTagStorable instance');
  }

  List<LocalNoteTag> _tags = [];
  late final BehaviorSubject<List<LocalNoteTag>> _noteTagsStreamController;

  @override
  IsarCollection<int, LocalNoteTag> get storableCollection =>
      LocalStorable.isar!.localNoteTags;

  @override
  ValueStream<List<LocalNoteTag>> get allItemStream =>
      _noteTagsStreamController.stream;

  @override
  Future<List<LocalNoteTag>> get getAllItems async {
    await _ensureCollectionIsOpen();
    return storableCollection.where().findAll();
  }

  @override
  Future<LocalNoteTag> createItem() async {
    final currentTime = DateTime.now().toUtc();

    final LocalNoteTag newTag = LocalNoteTag(
      isarId: storableCollection.autoIncrement(),
      name: '',
      cloudDocumentId: null,
      created: currentTime,
      modified: currentTime,
    );
    await LocalStorable.isar!.writeAsync(
      (isar) {
        final tagId = isar.localNoteTags.put(newTag);
        return tagId;
      },
    );
    log('New NoteTag with id=${newTag.isarId} created');

    _tags.add(newTag);
    _noteTagsStreamController.add(_tags);

    return newTag;
  }

  @override
  Future<LocalNoteTag> getItem({required int id}) async {
    LocalNoteTag? noteTag;
    try {
      noteTag = storableCollection.get(id);
      if (noteTag == null) {
        throw CouldNotFindNoteTagException();
      }
      return noteTag;
    } on StateError {
      throw CouldNotFindNoteTagException();
    }
  }

  /// Returns the latest version of a note from the local database in a [Stream] of [LocalNote]
  @override
  Future<Stream<LocalNoteTag>> itemStream({required int id}) async {
    await _ensureCollectionIsOpen();
    final note = storableCollection.get(id);
    if (note == null) {
      throw CouldNotFindNoteTagException();
    } else {
      Stream<LocalNoteTag?> noteTagStreamNullable =
          storableCollection.watchObject(
        id,
        fireImmediately: true,
      );

      Stream<LocalNoteTag> noteTagStream = noteTagStreamNullable
          .where((note) => note != null)
          .map((note) => note!)
          .asBroadcastStream();

      return noteTagStream;
    }
  }

  @override
  Future<void> updateItem({
    required int id,
    String? name,
    String? cloudDocumentId,
    DateTime? modified,
    DateTime? created,
  }) async {
    final currentTime = DateTime.now().toUtc();
    LocalNoteTag? tag;
    if (name != null) {
      final tagIds = storableCollection
          .where()
          .nameEqualTo(name)
          .isarIdProperty()
          .findAll();
      if (tagIds.isNotEmpty) {
        if (tagIds.length > 1) {
          throw Exception('Should not happen... hopefully');
        } else if (tagIds[0] != id) {
          throw DuplicateNoteTagException();
        }
      }
    }
    try {
      tag = await getItem(id: id);
    } catch (e) {
      throw CouldNotFindNoteTagException();
    }
    try {
      final newTag = LocalNoteTag(
        isarId: id,
        name: name ?? tag.name,
        cloudDocumentId: cloudDocumentId ?? tag.cloudDocumentId,
        modified: modified ?? currentTime,
        created: created ?? tag.created,
      );
      await LocalStorable.isar!
          .writeAsync((isar) => isar.localNoteTags.put(newTag));

      _tags.removeWhere((tag) => tag.isarId == newTag.isarId);
      _tags.add(newTag);
      _noteTagsStreamController.add(_tags);
    } catch (_) {
      throw CouldNotUpdateNoteTagException();
    }
  }

  @override
  Future<void> deleteItem({required int id}) async {
    try {
      await getItem(id: id);
    } catch (e) {
      throw CouldNotFindNoteTagException();
    }
    try {
      await LocalStorable.isar!
          .writeAsync<bool>((isar) => isar.localNoteTags.delete(id));
      _tags.removeWhere((tag) => tag.isarId == id);
      _noteTagsStreamController.add(_tags);
    } catch (e) {
      throw CouldNotDeleteNoteTagException();
      // rethrow;
    }
  }

  Future<void> _ensureCollectionIsOpen() async {
    await LocalStore.open();
  }

  Future<void> _cacheNoteTags() async {
    final allNoteTags = await getAllItems;
    _tags = allNoteTags;
    _noteTagsStreamController.add(_tags);
  }

  @override
  Future<void> deleteAllItems() async {
    await _ensureCollectionIsOpen();
    await LocalStorable.isar!.writeAsync((isar) {
      isar.localNoteTags.clear();
    });

    // Add event to noteTags stream
    _tags = [];
    _noteTagsStreamController.add(_tags);
  }
}
