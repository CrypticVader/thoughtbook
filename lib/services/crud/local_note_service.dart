import 'package:isar/isar.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'crud_exceptions.dart';
import 'local_note.dart';

class LocalNoteService {
  Isar? _isar;

  IsarCollection<LocalNote> get _getNotesCollection => _isar!.localNotes;

  static final LocalNoteService _shared = LocalNoteService._sharedInstance();

  LocalNoteService._sharedInstance();

  factory LocalNoteService() => _shared;

  Future<LocalNote> updateNote({
    required int id,
    required String title,
    required String content,
    required int color,
    required bool isSyncedWithCloud,
  }) async {
    await _ensureDbIsOpen();
    final notesCollection = _getNotesCollection;
    final note = await notesCollection.get(id);
    if (note == null) {
      throw CouldNotFindNote();
    } else {
      final currentTime = DateTime.now().toUtc();
      await notesCollection.delete(id);
      final newNote = note
        ..title = title
        ..content = content
        ..color = color
        ..isSyncedWithCloud = isSyncedWithCloud
        ..modified = currentTime;
      await notesCollection.put(newNote);
      return newNote;
    }
  }

  Future<Iterable<LocalNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final notesCollection = _getNotesCollection;
    return notesCollection.where().findAll();
  }

  Future<LocalNote> getNote(int id) async {
    await _ensureDbIsOpen();
    final notesCollection = _getNotesCollection;
    final note = await notesCollection.get(id);
    if (note == null) {
      throw CouldNotFindNote();
    } else {
      return note;
    }
  }

  Future<LocalNote> createNote() async {
    await _ensureDbIsOpen();
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
    await notesCollection.put(note);
    return note;
  }

  Future<void> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final notesCollection = _getNotesCollection;
    await notesCollection.clear();
  }

  Future<void> deleteNote(int id) async {
    await _ensureDbIsOpen();
    final couldDelete = await _getNotesCollection.delete(id);
    if (!couldDelete) {
      throw CouldNotDeleteNote();
    }
  }

  Future<void> close() {
    final isar = _isar;
    if (isar == null) {
      throw DatabaseIsNotOpen();
    } else {
      return isar.close();
    }
  }

  Future<void> open() async {
    if (_isar != null) throw DatabaseAlreadyOpenException();
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final isar = await Isar.open([LocalNoteSchema], directory: dbPath);
      _isar = isar;
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
}

const dbName = 'local_notes';
