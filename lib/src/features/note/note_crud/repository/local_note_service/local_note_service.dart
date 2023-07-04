import 'dart:async';
import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_note_service/crud_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_sync/domain/note_change.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_sync_service/note_sync_service.dart';
import 'package:thoughtbook/src/helpers/debouncer/debouncer.dart';

class LocalNoteService {
  Isar? _isar;
  final _debouncer =
      Debouncer<NoteChange>(delay: const Duration(milliseconds: 250));

  List<LocalNote> _notes = [];
  List<NoteTag> _tags = [];

  IsarCollection<LocalNote> get _getNotesCollection => _isar!.localNotes;

  IsarCollection<NoteTag> get _getNoteTagsCollection => _isar!.noteTags;

  static final LocalNoteService _shared = LocalNoteService._sharedInstance();

  LocalNoteService._sharedInstance() {
    _ensureCollectionIsOpen();

    // Using broadcast makes the StreamController lose hold of previous values on every listen
    // This is mitigated by adding _notes to the stream broadcast every time it is subscribed to
    _notesStreamController = StreamController<List<LocalNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
    _noteTagsStreamController = StreamController<List<NoteTag>>.broadcast(
      onListen: () {
        _noteTagsStreamController.sink.add(_tags);
      },
    );

    noteChangeFeedController = StreamController<NoteChange>.broadcast();
  }

  factory LocalNoteService() => _shared;

  late final StreamController<List<LocalNote>> _notesStreamController;
  late final StreamController<List<NoteTag>> _noteTagsStreamController;
  late final StreamController<NoteChange> noteChangeFeedController;

  /// Returns a [Stream] of collection of all the [LocalNote] in the local note database.
  Stream<List<LocalNote>> get allNotes => _notesStreamController.stream;

  /// Returns a [Stream] of collection of all the [NoteTag] in the local note tags database.
  Stream<List<NoteTag>> get allNoteTags => _noteTagsStreamController.stream;

  /// Returns a [Stream] of changes occurring in the local note database.
  Stream<NoteChange> get getNoteChangeFeed => noteChangeFeedController.stream;

  Future<void> updateNote({
    required int isarId,
    required String title,
    required String content,
    required List<int> tags,
    required int? color,
    required bool isSyncedWithCloud,
    String? cloudDocumentId,
    bool addToChangeFeed = true,
    bool debounceChangeFeedEvent = false,
    DateTime? created,
    DateTime? modified,
  }) async {
    await _ensureCollectionIsOpen();
    final isar = _isar!;
    final notesCollection = _getNotesCollection;
    final note = await notesCollection.get(isarId);
    if (note == null) {
      throw CouldNotUpdateNoteException();
    } else {
      final newNote = note
        ..title = title
        ..content = content
        ..tags = tags
        ..color = color
        ..isSyncedWithCloud = isSyncedWithCloud
        ..cloudDocumentId = cloudDocumentId ?? note.cloudDocumentId
        ..created = created ?? note.created
        ..modified = modified ?? DateTime.now().toUtc();

      // Add the updated note to the Isar collection
      // Check whether the new Id of the updated note is the same as the old Id
      // If not the same, throw
      await isar.writeTxn(
        () async {
          return await notesCollection.put(newNote);
        },
      ).then(
        (newId) {
          if (newId == note.isarId) {
            log('Note with id=$newId updated');
          } else {
            throw CouldNotUpdateNoteException();
          }
        },
      );

      // Add event to notes stream
      final updatedNote = await getNote(isarId: note.isarId);
      _notes.removeWhere((note) => note.isarId == updatedNote.isarId);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);

      // Add event to note change feed
      if (addToChangeFeed) {
        if (debounceChangeFeedEvent) {
          _debouncer.run(
            () => noteChangeFeedController.add(
              NoteChange.fromLocalNote(
                note: updatedNote,
                type: NoteChangeType.update,
                timestamp: DateTime.now().toUtc(),
              ),
            ),
          );
        } else {
          noteChangeFeedController.add(
            NoteChange.fromLocalNote(
              note: updatedNote,
              type: NoteChangeType.update,
              timestamp: DateTime.now().toUtc(),
            ),
          );
        }
      }
    }
  }

  Future<List<LocalNote>> getAllNotes() async {
    await _ensureCollectionIsOpen();
    final notesCollection = _getNotesCollection;
    return await notesCollection.where().sortByModifiedDesc().findAll();
  }

  Future<List<NoteTag>> getAllNoteTags() async {
    await _ensureCollectionIsOpen();
    final noteTagsCollection = _getNoteTagsCollection;
    return await noteTagsCollection.where().anyId().findAll();
  }

  Future<LocalNote> getNote({
    int? isarId,
    String? cloudDocumentId,
  }) async {
    await _ensureCollectionIsOpen();
    final notesCollection = _getNotesCollection;
    if (isarId == null) {
      if (cloudDocumentId == null) {
        throw CouldNotFindNoteException();
      }
      try {
        final note = (await notesCollection
                .filter()
                .cloudDocumentIdEqualTo(cloudDocumentId)
                .findAll())
            .first;
        return note;
      } on StateError {
        throw CouldNotFindNoteException();
      }
    } else {
      final note = await notesCollection.get(isarId);
      if (note == null) {
        throw CouldNotFindNoteException();
      } else {
        return note;
      }
    }
  }

  /// Returns the latest version of a note from the local database in a [Stream] of [LocalNote]
  Future<Stream<LocalNote>> getNoteAsStream({required int isarId}) async {
    await _ensureCollectionIsOpen();
    final notesCollection = _getNotesCollection;
    final note = await notesCollection.get(isarId);
    if (note == null) {
      throw CouldNotFindNoteException();
    } else {
      Stream<LocalNote?> noteStreamNullable = notesCollection.watchObject(
        isarId,
        fireImmediately: true,
      );

      Stream<LocalNote> noteStream = noteStreamNullable
          .where((note) => note != null)
          .map((note) => note!)
          .asBroadcastStream();

      return noteStream;
    }
  }

  /// Creates a [LocalNote] object in the collection & and returns its instance.
  Future<LocalNote> createNote({
    bool addToChangeFeed = true,
    bool debounceChangeFeedEvent = false,
  }) async {
    log('Within createNote()');
    await _ensureCollectionIsOpen();
    final isar = _isar!;
    final notesCollection = _getNotesCollection;
    final currentTime = DateTime.now().toUtc();
    final note = LocalNote(
      isSyncedWithCloud: false,
      cloudDocumentId: null,
      title: '',
      content: '',
      tags: [],
      color: null,
      created: currentTime,
      modified: currentTime,
    );

    //Create a new note in the Isar collection, then update the note object with the new Id
    await isar.writeTxn(
      () async {
        final noteId = await notesCollection.put(note);
        return noteId;
      },
    ).then((noteId) => note..isarId = noteId);

    log('New LocalNote with id=${note.isarId} created');

    // Add event to the stream
    _notes.add(note);
    _notesStreamController.add(_notes);

    // Add event to note change feed
    if (addToChangeFeed) {
      if (debounceChangeFeedEvent) {
        _debouncer.run(
          () => noteChangeFeedController.add(
            NoteChange.fromLocalNote(
              type: NoteChangeType.create,
              note: note,
              timestamp: DateTime.now().toUtc(),
            ),
          ),
        );
      } else {
        noteChangeFeedController.add(
          NoteChange.fromLocalNote(
            type: NoteChangeType.create,
            note: note,
            timestamp: DateTime.now().toUtc(),
          ),
        );
      }
    }

    return note;
  }

  // TODO: Get rid of this, as it is useless if we consider cloud to local sync
  Future<void> markNoteAsSynced({required int isarId}) async {
    await _ensureCollectionIsOpen();
    final isar = _isar!;
    final notesCollection = _getNotesCollection;
    final note = await notesCollection.get(isarId);
    if (note == null) {
      throw CouldNotUpdateNoteException();
    } else {
      final newNote = note..isSyncedWithCloud = true;

      // Add the updated note to the Isar collection
      // Check whether the new Id of the updated note is the same as the old Id
      // If not the same, throw
      await isar.writeTxn(
        () async {
          return await notesCollection.put(newNote);
        },
      ).then(
        (newId) {
          if (newId == note.isarId) {
            log('Note with id=$newId updated');
          } else {
            throw CouldNotUpdateNoteException();
          }
        },
      );

      // Add event to notes stream
      final updatedNote = await getNote(isarId: note.isarId);
      _notes.removeWhere((note) => note.isarId == updatedNote.isarId);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
    }
  }

  Future<void> deleteAllNotes({required bool addToChangeFeed}) async {
    await _ensureCollectionIsOpen();
    final isar = _isar!;
    final notesCollection = _getNotesCollection;
    await isar.writeTxn(() async {
      await notesCollection.clear();
    });

    // Add event to notes stream
    _notes = [];
    _notesStreamController.add(_notes);

    // TODO: Add event to note change feed but be careful as db is cleared locally on logout but this should not be reflected on the cloud
    // if (addToChangeFeed) {
    //   noteChangeFeedController.add(
    //     NoteChange(
    //       type: NoteChangeType.deleteAll,
    //       isarId: null,
    //       cloudDocumentId: null,
    //       timestamp: DateTime.now().toUtc(),
    //     ),
    //   );
    // }
  }

  Future<void> deleteNote({
    required int isarId,
    bool addToChangeFeed = true,
    bool debounceChangeFeedEvent = false,
  }) async {
    await _ensureCollectionIsOpen();
    final isar = _isar!;
    final note = await getNote(isarId: isarId);
    await isar.writeTxn(
      () async {
        return await _getNotesCollection.delete(isarId);
      },
    ).then(
      (bool couldDelete) {
        if (!couldDelete) {
          throw CouldNotDeleteNoteException();
        }
      },
    );

    log('LocalNote with id=$isarId deleted');

    // Add event to stream
    _notes.removeWhere((note) => note.isarId == isarId);
    _notesStreamController.add(_notes);

    // Add event to note change feed
    if (addToChangeFeed) {
      if (debounceChangeFeedEvent) {
        _debouncer.run(
          () => noteChangeFeedController.add(
            NoteChange.fromLocalNote(
              type: NoteChangeType.delete,
              note: note,
              timestamp: DateTime.now().toUtc(),
            ),
          ),
        );
      } else {
        noteChangeFeedController.add(
          NoteChange.fromLocalNote(
            type: NoteChangeType.delete,
            note: note,
            timestamp: DateTime.now().toUtc(),
          ),
        );
      }
    }
  }

  Future<NoteTag> createNoteTag({required String name}) async {
    final isar = _isar!;
    final NoteTag newTag = NoteTag(
      name: name,
      cloudDocumentId: null,
    );
    //TODO: Handle duplicate tag name exception
    await isar.writeTxn(
      () async {
        final tagId = await _getNoteTagsCollection.put(newTag);
        return tagId;
      },
    ).then((value) => newTag..id = value);
    log('New NoteTag with id=${newTag.id} created');

    _tags.add(newTag);
    _noteTagsStreamController.add(_tags);

    return newTag;
  }

  Future<NoteTag> getNoteTag({required int id}) async {
    NoteTag? noteTag;
    try {
      noteTag = await _getNoteTagsCollection.get(id);
      if (noteTag == null) {
        throw CouldNotFindNoteTagException();
      }
      return noteTag;
    } on StateError {
      throw CouldNotFindNoteTagException();
    }
  }

  Future<void> updateNoteTag({
    required int id,
    String? name,
    String? cloudDocumentId,
  }) async {
    NoteTag? tag;
    try {
      tag = await getNoteTag(id: id);
    } catch (e) {
      throw CouldNotFindNoteTagException();
    }
    try {
      final newTag = NoteTag(
        name: (name != null) ? name : tag.name,
        cloudDocumentId:
            (cloudDocumentId != null) ? cloudDocumentId : tag.cloudDocumentId,
      )..id = tag.id;
      await _getNoteTagsCollection.put(newTag);

      _tags.removeWhere((tag) => tag.id == newTag.id);
      _tags.add(newTag);
      _noteTagsStreamController.add(_tags);
    } catch (e) {
      throw CouldNotUpdateNoteTagException();
    }
  }

  Future<void> deleteNoteTag({required int id}) async {
    try {
      await getNoteTag(id: id);
    } catch (e) {
      throw CouldNotFindNoteTagException();
    }
    try {
      await _getNoteTagsCollection.delete(id);

      _tags.removeWhere((tag) => tag.id == id);
      _noteTagsStreamController.add(_tags);
    } catch (e) {
      throw CouldNotDeleteNoteTagException();
    }
  }

  Future<void> close() async {
    final isar = _isar;
    if (isar == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await isar.close();
    }
  }

  Future<void> _open() async {
    if (_isar != null) throw CollectionAlreadyOpenException();
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      Isar? isar = Isar.getInstance();
      isar ??= await Isar.open(
        [
          LocalNoteSchema,
          NoteChangeSchema,
          NoteTagSchema,
        ],
        directory: docsPath.path,
        inspector: true,
      );
      _isar = isar;
      await _cacheNotesAndTags();
      log(
        'All Isar collections opened',
        name: 'LocalNoteService',
      );
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> _ensureCollectionIsOpen() async {
    try {
      await _open();
    } on CollectionAlreadyOpenException {
      // empty
    }
  }

  Future<void> _cacheNotesAndTags() async {
    final allNotes = await getAllNotes();
    final allNoteTags = await getAllNoteTags();
    _notes = allNotes;
    _tags = allNoteTags;
    _notesStreamController.add(_notes);
    _noteTagsStreamController.add(_tags);
  }
}
