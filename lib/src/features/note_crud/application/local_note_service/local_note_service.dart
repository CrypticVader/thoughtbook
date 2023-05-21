import 'dart:async';
import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thoughtbook/src/features/note_crud/application/local_note_service/crud_exceptions.dart';
import 'package:thoughtbook/src/features/note_crud/application/note_sync_service/note_sync_service.dart';
import 'package:thoughtbook/src/features/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note_crud/domain/note_change.dart';

class LocalNoteService {
  Isar? _isar;

  List<LocalNote> _notes = [];

  IsarCollection<LocalNote> get _getNotesCollection => _isar!.localNotes;

  static final LocalNoteService _shared = LocalNoteService._sharedInstance();

  LocalNoteService._sharedInstance() {
    // using broadcast makes the StreamController lose hold of previous values on every listen
    // This is mitigated by adding _notes to the stream broadcast every time it is subscribed to
    _ensureDbIsOpen();

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
    bool addToChangeFeed = true,
    String? cloudDocumentId,
    DateTime? created,
    DateTime? modified,
  }) async {
    await _ensureDbIsOpen();
    final isar = _isar!;
    final notesCollection = _getNotesCollection;
    final note = await notesCollection.get(isarId);
    if (note == null) {
      throw CouldNotUpdateNote();
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
            throw CouldNotUpdateNote();
          }
        },
      );

      // Add event to notes stream
      final updatedNote = await getNote(id: note.isarId);
      _notes.removeWhere((note) => note.isarId == updatedNote.isarId);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);

      // Add event to note change feed
      if (addToChangeFeed) {
        noteChangeFeedController.add(
          NoteChange(
            type: NoteChangeType.update,
            isarId: updatedNote.isarId,
            cloudDocumentId: updatedNote.cloudDocumentId,
            timestamp: DateTime.now().toUtc(),
          ),
        );
      }
    }
  }

  Future<List<LocalNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final notesCollection = _getNotesCollection;
    return await notesCollection.where().anyModified().findAll();
  }

  Future<LocalNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final notesCollection = _getNotesCollection;
    final note = await notesCollection.get(id);
    if (note == null) {
      throw CouldNotFindNote();
    } else {
      return note;
    }
  }

  /// Returns the latest version of a note from the local database in a [Stream] of [LocalNote]
  Future<Stream<LocalNote>> getNoteAsStream({required int isarId}) async {
    await _ensureDbIsOpen();
    final notesCollection = _getNotesCollection;
    final note = await notesCollection.get(isarId);
    if (note == null) {
      throw CouldNotFindNote();
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

  /// Creates a [LocalNote] object and returns it.
  Future<LocalNote> createNote({bool addToChangeFeed = true}) async {
    log("Within createNote()");
    await _ensureDbIsOpen();
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
      noteChangeFeedController.add(
        NoteChange(
          type: NoteChangeType.create,
          isarId: note.isarId,
          cloudDocumentId: note.cloudDocumentId,
          timestamp: DateTime.now().toUtc(),
        ),
      );
    }

    return note;
  }

  Future<void> markNoteAsSynced({required int isarId}) async {
    await _ensureDbIsOpen();
    final isar = _isar!;
    final notesCollection = _getNotesCollection;
    final note = await notesCollection.get(isarId);
    if (note == null) {
      throw CouldNotUpdateNote();
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
            throw CouldNotUpdateNote();
          }
        },
      );

      // Add event to notes stream
      final updatedNote = await getNote(id: note.isarId);
      _notes.removeWhere((note) => note.isarId == updatedNote.isarId);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
    }
  }

  Future<void> deleteAllNotes({required bool addToChangeFeed}) async {
    await _ensureDbIsOpen();
    final isar = _isar!;
    final notesCollection = _getNotesCollection;
    isar.writeTxn(() async {
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

  Future<void> deleteNote({required int isarId}) async {
    await _ensureDbIsOpen();
    final isar = _isar!;
    final note = await getNote(id: isarId);
    await isar.writeTxn(
      () async {
        return await _getNotesCollection.delete(isarId);
      },
    ).then(
      (bool couldDelete) {
        if (!couldDelete) {
          throw CouldNotDeleteNote();
        }
      },
    );

    log("LocalNote with id=$isarId deleted");

    // Add event to stream
    _notes.removeWhere((note) => note.isarId == isarId);
    _notesStreamController.add(_notes);

    // Add event to note change feed
    noteChangeFeedController.add(
      NoteChange(
        type: NoteChangeType.delete,
        isarId: note.isarId,
        cloudDocumentId: note.cloudDocumentId,
        timestamp: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> close() async {
    final isar = _isar;
    if (isar == null) {
      throw DatabaseIsNotOpen();
    } else {
      await isar.close();
    }
  }

  Future<void> open() async {
    if (_isar != null) throw DatabaseAlreadyOpenException();
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      log("Within open()");
      final isar = await Isar.open(
        [LocalNoteSchema],
        directory: docsPath.path,
        inspector: true,
      );
      _isar = isar;
      await _cacheNotes();
      log("Within open() - after isar = await Isar.open(...)");
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes;
    _notesStreamController.add(_notes);
  }
}
