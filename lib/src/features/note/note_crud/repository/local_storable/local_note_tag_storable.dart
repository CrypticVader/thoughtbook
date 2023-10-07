import 'dart:async';
import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_sync/domain/note_tag_change.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_tag_syncable/note_tag_change_storable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable.dart';

class LocalNoteTagStorable extends LocalStorable<LocalNoteTag> {
  LocalNoteTagStorable() {
    _cacheNoteTags();
    _noteTagsStreamController = BehaviorSubject<List<LocalNoteTag>>.seeded(_tags);
    log('Created LocalNoteTagStorable instance');
  }

  List<LocalNoteTag> _tags = [];
  late final BehaviorSubject<List<LocalNoteTag>> _noteTagsStreamController;

  @override
  IsarCollection<int, LocalNoteTag> get storableCollection => LocalStorable.isar!.localNoteTags;

  @override
  ValueStream<List<LocalNoteTag>> get allItemStream => _noteTagsStreamController.stream;

  @override
  Future<List<LocalNoteTag>> get getAllItems async {
    await _ensureCollectionIsOpen();
    return storableCollection.where().findAll();
  }

  @override
  Future<LocalNoteTag> createItem({bool addToChangeFeed = true}) async {
    final currentTime = DateTime.now().toUtc();

    final LocalNoteTag newTag = LocalNoteTag(
      isarId: storableCollection.autoIncrement(),
      name: '',
      cloudDocumentId: null,
      created: currentTime,
      modified: currentTime,
      isSyncedWithCloud: false,
    );
    LocalStorable.isar!.write(
      (isar) {
        final tagId = isar.localNoteTags.put(newTag);
        return tagId;
      },
    );
    log('New NoteTag with id=${newTag.isarId} created');

    _tags.add(newTag);
    _noteTagsStreamController.add(_tags);

    if (addToChangeFeed) {
      NoteTagChangeStorable().addToChangeFeed(
        noteTag: ChangedNoteTag.fromLocalNoteTag(newTag),
        type: SyncableChangeType.create,
      );
    }

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

  /// Returns the latest version of a note from the local database in a [ValueStream] of [LocalNoteTag]
  @override
  ValueStream<LocalNoteTag> itemStream({required int id}) {
    LocalNoteTag? lastEmittedValue;
    return _noteTagsStreamController.stream.transform<LocalNoteTag>(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          final noteTag = data.where((noteTag) => noteTag.isarId == id).first;
          if (lastEmittedValue == null) {
            sink.add(noteTag);
          } else {
            if (lastEmittedValue != noteTag) {
              sink.add(noteTag);
            }
          }
          lastEmittedValue = noteTag;
        },
      ),
    ).shareValue();
  }

  @override
  Future<void> updateItem({
    required int id,
    String? name,
    String? cloudDocumentId,
    DateTime? modified,
    DateTime? created,
    bool isSyncedWithCloud = false,
    bool addToChangeFeed = true,
  }) async {
    final currentTime = DateTime.now().toUtc();
    LocalNoteTag? tag;
    if (name != null) {
      final tagIds =
          storableCollection.where().nameEqualTo(name).isarIdProperty().findAll(limit: 1);
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
    final newTag = LocalNoteTag(
      isarId: id,
      name: name ?? tag.name,
      cloudDocumentId: cloudDocumentId ?? tag.cloudDocumentId,
      modified: modified ?? currentTime,
      created: created ?? tag.created,
      isSyncedWithCloud: isSyncedWithCloud,
    );
    try {
      LocalStorable.isar!.write((isar) => isar.localNoteTags.put(newTag));

      _tags.removeWhere((tag) => tag.isarId == newTag.isarId);
      _tags.add(newTag);
      _noteTagsStreamController.add(_tags);
    } catch (_) {
      throw CouldNotUpdateNoteTagException();
    }

    if (addToChangeFeed) {
      NoteTagChangeStorable().addToChangeFeed(
        noteTag: ChangedNoteTag.fromLocalNoteTag(newTag),
        type: SyncableChangeType.update,
      );
    }
  }

  @override
  Future<void> deleteItem({
    required int id,
    bool addToChangeFeed = true,
    bool notifyOtherCollections = true,
  }) async {
    await _ensureCollectionIsOpen();
    final noteTag = await getItem(id: id);
    try {
      LocalStorable.isar!.write<bool>((isar) => isar.localNoteTags.delete(id));
      _tags.removeWhere((tag) => tag.isarId == id);
      _noteTagsStreamController.add(_tags);
    } catch (e) {
      throw CouldNotDeleteNoteTagException();
      // rethrow;
    }
    if (addToChangeFeed) {
      NoteTagChangeStorable().addToChangeFeed(
        noteTag: ChangedNoteTag.fromLocalNoteTag(noteTag),
        type: SyncableChangeType.delete,
      );
    }
    if (notifyOtherCollections) {
      await LocalStore.note.removeTagIdFromAllItems(tagId: id);
    }
  }

  List<String> getCloudIdsFor({required List<int> isarIds}) {
    if (isarIds.isEmpty) return [];

    final docIds = storableCollection
        .where()
        .cloudDocumentIdIsNotNull()
        .anyOf(isarIds, (noteTag, isarId) => noteTag.isarIdEqualTo(isarId))
        .cloudDocumentIdProperty()
        .findAll(limit: isarIds.length);
    return List<String>.from(docIds);
  }

  List<int> getLocalIdsFor({required List<String> documentIds}) {
    if (documentIds.isEmpty) return [];

    final isarIds = storableCollection
        .where()
        .anyOf(
          documentIds,
          (noteTag, documentId) => noteTag.cloudDocumentIdEqualTo(documentId),
        )
        .isarIdProperty()
        .findAll(limit: documentIds.length);
    return isarIds;
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
    LocalStorable.isar!.write((isar) {
      isar.localNoteTags.clear();
    });

    // Add event to noteTags stream
    _tags = [];
    _noteTagsStreamController.add(_tags);
  }
}
