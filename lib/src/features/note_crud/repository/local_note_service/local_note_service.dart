import 'dart:async';
import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thoughtbook/src/features/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note_crud/domain/note_change.dart';
import 'package:thoughtbook/src/features/note_crud/repository/local_note_service/crud_exceptions.dart';
import 'package:thoughtbook/src/features/note_crud/repository/note_sync_service/note_sync_service.dart';
import 'package:thoughtbook/src/helpers/debouncer/debouncer.dart';

class LocalNoteService {
  Isar? _isar;
  final _debouncer =
      Debouncer<NoteChange>(delay: const Duration(milliseconds: 250));

  List<LocalNote> _notes = [];

  IsarCollection<LocalNote> get _getNotesCollection => _isar!.localNotes;

  static final LocalNoteService _shared = LocalNoteService._sharedInstance();

  LocalNoteService._sharedInstance() {
    // using broadcast makes the StreamController lose hold of previous values on every listen
    // This is mitigated by adding _notes to the stream broadcast every time it is subscribed to
    _ensureCollectionIsOpen();

    _notesStreamController = StreamController<List<LocalNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );

    noteChangeFeedController = StreamController<NoteChange>.broadcast();
  }

  factory LocalNoteService() => _shared;

  late final StreamController<List<LocalNote>> _notesStreamController;

  late final StreamController<NoteChange> noteChangeFeedController;

  /// Returns a [Stream] of collection of all the notes in the local note database.
  Stream<List<LocalNote>> get allNotes => _notesStreamController.stream;

  /// Returns a [Stream] of changes in the local note database.
  Stream<NoteChange> get getNoteChangeFeed => noteChangeFeedController.stream;

  Future<void> updateNote({
    required int isarId,
    required String title,
    required String content,
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
    return await notesCollection.where().anyModified().findAll();
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

  Future<void> close() async {
    final isar = _isar;
    if (isar == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await isar.close();
    }
  }

  Future<void> open() async {
    if (_isar != null) throw CollectionAlreadyOpenException();
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      Isar? isar = Isar.getInstance();
      isar ??= await Isar.open(
        [
          LocalNoteSchema,
          NoteChangeSchema,
        ],
        directory: docsPath.path,
        inspector: true,
      );
      _isar = isar;
      await _cacheNotes();
      log(
        'LocalNote collection opened',
        name: 'LocalNoteService',
      );
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> _ensureCollectionIsOpen() async {
    try {
      await open();
    } on CollectionAlreadyOpenException {
      // empty
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes;
    _notesStreamController.add(_notes);
  }
}
