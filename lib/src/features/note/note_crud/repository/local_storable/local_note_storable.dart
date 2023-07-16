import 'dart:async';
import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/crud_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_storable.dart';
import 'package:thoughtbook/src/features/note/note_sync/domain/note_change.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_syncable/note_syncable.dart';
import 'package:thoughtbook/src/helpers/debouncer/debouncer.dart';

class LocalNoteStorable implements LocalStorable<LocalNote> {
  static final LocalNoteStorable _shared = LocalNoteStorable._sharedInstance();

  LocalNoteStorable._sharedInstance() {
    _ensureCollectionIsOpen();
    _notesStreamController = BehaviorSubject<List<LocalNote>>.seeded(_notes);
    _noteChangeFeedController = BehaviorSubject<NoteChange>();
  }

  factory LocalNoteStorable() => _shared;

  Isar? _isar;
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 250));
  List<LocalNote> _notes = [];
  late final BehaviorSubject<List<LocalNote>> _notesStreamController;
  late final BehaviorSubject<NoteChange> _noteChangeFeedController;

  @override
  IsarCollection<LocalNote> get entityCollection => _isar!.localNotes;

  /// Returns a [ValueStream] of collection of all the [LocalNote] in the local note database.
  @override
  ValueStream<List<LocalNote>> get allItemStream =>
      _notesStreamController.stream;

  /// Returns a [ValueStream] of changes occurring in the local note database.
  @override
  ValueStream<NoteChange> get changeFeedStream =>
      _noteChangeFeedController.stream;

  @override
  Future<void> updateItem({
    required int id,
    String? title,
    String? content,
    List<int>? tags,
    int? color = retainNoteColor,
    bool isSyncedWithCloud = false,
    String? cloudDocumentId,
    bool addToChangeFeed = true,
    bool debounceChangeFeedEvent = false,
    DateTime? created,
    DateTime? modified,
  }) async {
    await _ensureCollectionIsOpen();
    final isar = _isar!;
    final notesCollection = entityCollection;
    final note = await notesCollection.get(id);
    if (note == null) {
      throw CouldNotUpdateNoteException();
    } else {
      final newNote = note
        ..title = title ?? note.title
        ..content = content ?? note.content
        ..tags = tags ?? note.tags
        ..color = (color == null || color > 0) ? color : note.color
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
      final updatedNote = await getItem(id: note.isarId);
      _notes.removeWhere((note) => note.isarId == updatedNote.isarId);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);

      // Add event to note change feed
      if (addToChangeFeed) {
        if (debounceChangeFeedEvent) {
          _debouncer.run(
            () => _noteChangeFeedController.add(
              NoteChange.fromLocalNote(
                note: updatedNote,
                type: NoteChangeType.update,
                timestamp: DateTime.now().toUtc(),
              ),
            ),
          );
        } else {
          _noteChangeFeedController.add(
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

  @override
  Future<List<LocalNote>> get getAllItems async {
    await _ensureCollectionIsOpen();
    final notesCollection = entityCollection;
    return await notesCollection.where().sortByModifiedDesc().findAll();
  }

  @override
  Future<LocalNote> getItem({
    required int? id,
    String? cloudDocumentId,
  }) async {
    await _ensureCollectionIsOpen();
    final notesCollection = entityCollection;
    if (id == null) {
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
      final note = await notesCollection.get(id);
      if (note == null) {
        throw CouldNotFindNoteException();
      } else {
        return note;
      }
    }
  }

  /// Returns the latest version of a note from the local database in a [Stream] of [LocalNote]
  @override
  Future<Stream<LocalNote>> itemStream({required int id}) async {
    await _ensureCollectionIsOpen();
    final notesCollection = entityCollection;
    final note = await notesCollection.get(id);
    if (note == null) {
      throw CouldNotFindNoteException();
    } else {
      Stream<LocalNote?> noteStreamNullable = notesCollection.watchObject(
        id,
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
  @override
  Future<LocalNote> createItem({
    bool addToChangeFeed = true,
    bool debounceChangeFeedEvent = false,
  }) async {
    await _ensureCollectionIsOpen();
    final isar = _isar!;
    final notesCollection = entityCollection;
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
          () => _noteChangeFeedController.add(
            NoteChange.fromLocalNote(
              type: NoteChangeType.create,
              note: note,
              timestamp: DateTime.now().toUtc(),
            ),
          ),
        );
      } else {
        _noteChangeFeedController.add(
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

  @override
  Future<void> deleteAllItems({bool addToChangeFeed = false}) async {
    await _ensureCollectionIsOpen();
    final isar = _isar!;
    final notesCollection = entityCollection;
    await isar.writeTxn(() async {
      await notesCollection.clear();
    });

    // Add event to notes stream
    _notes = [];
    _notesStreamController.add(_notes);

    // if (addToChangeFeed) {
    //   _noteChangeFeedController.add(
    //     NoteChange(
    //       type: NoteChangeType.deleteAll,
    //       noteIsarId: null,
    //       cloudDocumentId: null,
    //       timestamp: DateTime.now().toUtc(),
    //     ),
    //   );
    // }
  }

  @override
  Future<void> deleteItem({
    required int id,
    bool addToChangeFeed = true,
    bool debounceChangeFeedEvent = false,
  }) async {
    await _ensureCollectionIsOpen();
    final isar = _isar!;
    final note = await getItem(id: id);
    await isar.writeTxn(
      () async {
        return await entityCollection.delete(id);
      },
    ).then(
      (bool couldDelete) {
        if (!couldDelete) {
          throw CouldNotDeleteNoteException();
        }
      },
    );

    log('LocalNote with id=$id deleted');

    // Add event to stream
    _notes.removeWhere((note) => note.isarId == id);
    _notesStreamController.add(_notes);

    // Add event to note change feed
    if (addToChangeFeed) {
      if (debounceChangeFeedEvent) {
        _debouncer.run(
          () => _noteChangeFeedController.add(
            NoteChange.fromLocalNote(
              type: NoteChangeType.delete,
              note: note,
              timestamp: DateTime.now().toUtc(),
            ),
          ),
        );
      } else {
        _noteChangeFeedController.add(
          NoteChange.fromLocalNote(
            type: NoteChangeType.delete,
            note: note,
            timestamp: DateTime.now().toUtc(),
          ),
        );
      }
    }
  }

  @override
  Future<void> close() async {
    final isar = _isar;
    if (isar == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await isar.close();
    }
  }

  @override
  Future<void> open() async {
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
      await _cacheNotes();
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
      await open();
    } on CollectionAlreadyOpenException {
      // empty
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllItems;
    _notes = allNotes;
    _notesStreamController.add(_notes);
  }
}

const retainNoteColor = -1;
