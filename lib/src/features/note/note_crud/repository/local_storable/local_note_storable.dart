import 'dart:async';
import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';
import 'package:thoughtbook/src/features/note/note_sync/domain/note_change.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_syncable/note_change_storable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_syncable/note_syncable.dart';
import 'package:thoughtbook/src/helpers/debouncer/debouncer.dart';

class LocalNoteStorable extends LocalStorable<LocalNote> {
  LocalNoteStorable() {
    _cacheNotes();
    _notesStreamController = BehaviorSubject<List<LocalNote>>.seeded(_notes);
    log('Created LocalNoteStorable instance');
  }

  final _debouncer = Debouncer(delay: const Duration(milliseconds: 250));
  List<LocalNote> _notes = [];
  late final BehaviorSubject<List<LocalNote>> _notesStreamController;

  @override
  IsarCollection<int, LocalNote> get storableCollection =>
      LocalStorable.isar!.localNotes;

  @override
  ValueStream<List<LocalNote>> get allItemStream =>
      _notesStreamController.stream;

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
    LocalNote? note;
    try {
      note = await getItem(id: id);
    } on CouldNotFindNoteException {
      throw CouldNotUpdateNoteException();
    }
    final newNote = LocalNote(
      isarId: id,
      cloudDocumentId: cloudDocumentId ?? note.cloudDocumentId,
      title: title ?? note.title,
      content: content ?? note.content,
      tags: tags ?? note.tags,
      color: (color == null || color > 0) ? color : note.color,
      created: created ?? note.created,
      modified: modified ?? DateTime.now().toUtc(),
      isSyncedWithCloud: isSyncedWithCloud,
    );

    // Add the updated note to the Isar collection
    await LocalStorable.isar!.writeAsync<void>(
      (isar) => isar.localNotes.put(newNote),
    );

    // Add event to notes stream
    _notes.removeWhere((note) => note.isarId == id);
    _notes.add(newNote);
    _notesStreamController.add(_notes);

    // Add event to note change feed
    if (addToChangeFeed) {
      if (debounceChangeFeedEvent) {
        _debouncer.run(
          () => NoteChangeStorable().addToChangeFeed(
            note: ChangedNote.fromLocalNote(newNote),
            type: SyncableChangeType.update,
          ),
        );
      } else {
        NoteChangeStorable().addToChangeFeed(
          note: ChangedNote.fromLocalNote(newNote),
          type: SyncableChangeType.update,
        );
      }
    }
  }

  @override
  Future<List<LocalNote>> get getAllItems async {
    await _ensureCollectionIsOpen();
    return storableCollection.where().sortByModifiedDesc().findAll();
  }

  @override
  Future<LocalNote> getItem({
    required int? id,
    String? cloudDocumentId,
  }) async {
    await _ensureCollectionIsOpen();
    if (id == null) {
      if (cloudDocumentId == null) {
        throw CouldNotFindNoteException();
      }
      try {
        final note = storableCollection
            .where()
            .cloudDocumentIdEqualTo(cloudDocumentId)
            .findAll()
            .first;
        return note;
      } on StateError {
        throw CouldNotFindNoteException();
      }
    } else {
      final note = storableCollection.get(id);
      if (note == null) {
        throw CouldNotFindNoteException();
      } else {
        return note;
      }
    }
  }

  @override
  Future<Stream<LocalNote>> itemStream({required int id}) async {
    await _ensureCollectionIsOpen();
    await getItem(id: id);
    Stream<LocalNote?> noteStreamNullable = storableCollection.watchObject(
      id,
      fireImmediately: true,
    );

    Stream<LocalNote> noteStream = noteStreamNullable
        .where((note) => note != null)
        .map((note) => note!)
        .asBroadcastStream();

    return noteStream;
  }

  @override
  Future<LocalNote> createItem({
    bool addToChangeFeed = true,
    bool debounceChangeFeedEvent = false,
  }) async {
    await _ensureCollectionIsOpen();
    final currentTime = DateTime.now().toUtc();
    final note = LocalNote(
      isarId: storableCollection.autoIncrement(),
      isSyncedWithCloud: false,
      cloudDocumentId: null,
      title: '',
      content: '',
      tags: [],
      color: null,
      created: currentTime,
      modified: currentTime,
    );

    //Create a new note in the Isar collection
    await LocalStorable.isar!.writeAsync(
      (isar) {
        isar.localNotes.put(note);
      },
    );

    log('New LocalNote with id=${note.isarId} created');

    // Add event to the stream
    _notes.add(note);
    _notesStreamController.add(_notes);

    // Add event to note change feed
    if (addToChangeFeed) {
      if (debounceChangeFeedEvent) {
        _debouncer.run(
          () => NoteChangeStorable().addToChangeFeed(
            note: ChangedNote.fromLocalNote(note),
            type: SyncableChangeType.create,
          ),
        );
      } else {
        NoteChangeStorable().addToChangeFeed(
          note: ChangedNote.fromLocalNote(note),
          type: SyncableChangeType.create,
        );
      }
    }

    return note;
  }

  @override
  Future<void> deleteAllItems({bool addToChangeFeed = false}) async {
    await _ensureCollectionIsOpen();
    await LocalStorable.isar!.writeAsync((isar) {
      isar.localNotes.clear();
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
    final note = await getItem(id: id);
    await LocalStorable.isar!.writeAsync<bool>(
      (isar) {
        return isar.localNotes.delete(id);
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
          () => NoteChangeStorable().addToChangeFeed(
            note: ChangedNote.fromLocalNote(note),
            type: SyncableChangeType.delete,
          ),
        );
      } else {
        NoteChangeStorable().addToChangeFeed(
          note: ChangedNote.fromLocalNote(note),
          type: SyncableChangeType.delete,
        );
      }
    }
  }

  Future<void> _ensureCollectionIsOpen() async {
    await LocalStore.open();
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllItems;
    _notes = allNotes;
    _notesStreamController.add(_notes);
  }
}

const retainNoteColor = -1;
