import 'dart:async';
import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'crud_exceptions.dart';
import 'local_note.dart';

class LocalNoteService {
  Isar? _isar;

  List<LocalNote> _notes = [];

  IsarCollection<LocalNote> get _getNotesCollection => _isar!.localNotes;

  static final LocalNoteService _shared = LocalNoteService._sharedInstance();

  LocalNoteService._sharedInstance() {
    _notesStreamController = StreamController<List<LocalNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }

  factory LocalNoteService() => _shared;

  late final StreamController<List<LocalNote>> _notesStreamController;

  Stream<List<LocalNote>> get allNotes => _notesStreamController.stream;

  Future<void> updateNote({
    required int id,
    required String title,
    required String content,
    required int? color,
    required bool isSyncedWithCloud,
  }) async {
    await _ensureDbIsOpen();
    log("isarId: $id");
    final isar = _isar!;
    final notesCollection = _getNotesCollection;
    final note = await notesCollection.get(id);
    if (note == null) {
      throw CouldNotUpdateNote();
    } else {
      final currentTime = DateTime.now().toUtc();
      await isar.writeTxn(
        () async {
          await notesCollection.delete(id);
        },
      );
      final newNote = note
        ..title = title
        ..content = content
        ..color = color
        ..isSyncedWithCloud = isSyncedWithCloud
        ..modified = currentTime;

      await isar.writeTxn(
        () async {
          await notesCollection.put(newNote);
        },
      );

      // Add event to stream
      final updatedNote = await getNote(id: note.isarId);
      _notes.removeWhere((note) => note.isarId == updatedNote.isarId);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
    }
  }

  Future<List<LocalNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final notesCollection = _getNotesCollection;
    return await notesCollection.where().findAll();
  }

  Future<LocalNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final notesCollection = _getNotesCollection;
    final note = await notesCollection.get(id);
    if (note == null) {
      throw CouldNotFindNote();
    } else {
      // Add event to stream
      _notes.removeWhere((note) => note.isarId == id);
      _notes.add(note);
      _notesStreamController.add(_notes);

      return note;
    }
  }

  Future<LocalNote> createNote() async {
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
    isar.writeTxn(() async {
      await notesCollection.put(note);
    });

    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<void> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final isar = _isar!;
    final notesCollection = _getNotesCollection;
    isar.writeTxn(() async {
      await notesCollection.clear();
    });

    // Add event to stream
    _notes = [];
    _notesStreamController.add(_notes);
  }

  Future<void> deleteNote({required int isarId}) async {
    await _ensureDbIsOpen();
    final isar = _isar!;
    await isar.writeTxn(() async {
      final couldDelete = await _getNotesCollection.delete(isarId);
      if (!couldDelete) {
        throw CouldNotDeleteNote();
      } else {
        _notes.removeWhere((note) => note.isarId == isarId);
        _notesStreamController.add(_notes);
      }
    });
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
