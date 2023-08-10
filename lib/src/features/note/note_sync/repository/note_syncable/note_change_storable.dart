import 'dart:async';
import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_sync/domain/note_change.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/note_syncable/note_syncable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable_exceptions.dart';

class NoteChangeStorable extends LocalStorable<NoteChange> {
  static final NoteChangeStorable _shared =
      NoteChangeStorable._sharedInstance();

  NoteChangeStorable._sharedInstance() {
    _ensureCollectionIsOpen();
    _eventNotifierController = StreamController<void>.broadcast();
    _noteChangeFeedController = BehaviorSubject<NoteChange>();
  }

  factory NoteChangeStorable() => _shared;

  late final BehaviorSubject<NoteChange> _noteChangeFeedController;

  /// Returns a [ValueStream] of changes occurring in the local note database.
  ValueStream<NoteChange> get changeFeedStream =>
      _noteChangeFeedController.stream;

  Future<bool> get hasNoPendingChanges async {
    await _ensureCollectionIsOpen();
    return (storableCollection.count() == 0) ? true : false;
  }

  late StreamController<void> _eventNotifierController;

  Future<Stream<void>> get eventNotifier async {
    await _ensureCollectionIsOpen();
    return _eventNotifierController.stream;
  }

  void addToChangeFeed({
    required ChangedNote note,
    required SyncableChangeType type,
  }) {
    _noteChangeFeedController.add(
      NoteChange(
        isarId: storableCollection.autoIncrement(),
        changedNote: note,
        type: type,
        timestamp: DateTime.now().toUtc(),
      ),
    );
  }

  /// For a [NoteChange] of type [SyncableChangeType.create], the change is simply
  /// added to the [NoteChange] collection.
  Future<void> handleCreateChange({required NoteChange change}) async {
    await addChange(change: change);

    // Notify event stream controller
    _eventNotifierController.sink.add(null);
  }

  /// For a [NoteChange] of type [SyncableChangeType.update], all existing changes
  /// of type [SyncableChangeType.update] to the same [ChangedNote]
  /// are first removed from the [NoteChange] collection.
  ///
  /// Then the given [NoteChange] is added to the collection.
  Future<void> handleUpdateChange({required NoteChange change}) async {
    await _ensureCollectionIsOpen();
    // Find all changes on the given note of type update and delete them.
    await LocalStorable.isar!.writeAsync(
      (isar) {
        final duplicateUpdatesCount = isar.noteChanges
            .where()
            .changedNote(
                (note) => note.isarIdEqualTo(change.changedNote.isarId))
            .typeEqualTo(SyncableChangeType.update)
            .deleteAll();
        log(
          'Deleted $duplicateUpdatesCount updates to LocalNote with isarId=${change.changedNote.isarId} from Collection',
          name: 'NoteChangeHelper',
        );
      },
    );
    // Add the given change to the collection
    await addChange(change: change);

    // Notify event stream controller
    _eventNotifierController.sink.add(null);
  }

  /// For a [NoteChange] of type [SyncableChangeType.delete], if a [NoteChange] of
  /// type [SyncableChangeType.create] is present for the same [ChangedNote] in the
  /// [NoteChange] collection, it is removed & the given delete change is not
  /// added to the [NoteChange] collection.
  ///
  /// If [SyncableChangeType.create] to the same [ChangedNote] is not found, then all
  /// [NoteChange] of type [SyncableChangeType.update] are purged from the [NoteChange]
  /// collection, and then the given delete change is added to the collection.
  Future<void> handleDeleteChange({required NoteChange change}) async {
    await _ensureCollectionIsOpen();
    // Find and delete NoteChange of type create of the same LocalNote from the collection
    // and ignore the given delete change
    int noteCreateDeleted = 0;
    await LocalStorable.isar!.writeAsync(
      (isar) {
        noteCreateDeleted = isar.noteChanges
            .where()
            .changedNote(
                (note) => note.isarIdEqualTo(change.changedNote.isarId))
            .typeEqualTo(SyncableChangeType.create)
            .deleteAll();
      },
    );
    if (noteCreateDeleted == 1) {
      log(
        'NoteChange of type create to LocalNote with isarId=${change.changedNote.isarId} found and deleted. Ignoring delete change',
        name: 'NoteChangeHelper',
      );
    } else if (noteCreateDeleted == 0) {
      // If no NoteChange of type create to the same LocalNote is found,
      // then delete all NoteChange of type update to the same LocalNote
      // and add the given delete change to the collection
      await LocalStorable.isar!.writeAsync(
        (isar) {
          final duplicateUpdatesCount = isar.noteChanges
              .where()
              .changedNote(
                  (note) => note.isarIdEqualTo(change.changedNote.isarId))
              .typeEqualTo(SyncableChangeType.update)
              .deleteAll();
          log(
            'Deleted $duplicateUpdatesCount updates to LocalNote with isarId=${change.changedNote.isarId} from Collection',
            name: 'NoteChangeHelper',
          );
        },
      );
      await addChange(change: change);
    } else {
      log(
        'You should not be seeing this :/',
        name: 'NoteChangeHelper',
      );
    }

    // Notify event stream controller
    _eventNotifierController.sink.add(null);
  }

  Future<List<NoteChange>> get getAllChanges async {
    await _ensureCollectionIsOpen();
    return storableCollection.where().sortByTimestamp().findAll();
  }

  Future<NoteChange> getChange({required int id}) async {
    await _ensureCollectionIsOpen();
    final change = storableCollection.get(id);
    if (change == null) {
      throw CouldNotFindChangeException();
    } else {
      return change;
    }
  }

  Future<NoteChange> getOldestChangeAndDelete() async {
    await _ensureCollectionIsOpen();
    final change = storableCollection.where().sortByTimestamp().findFirst();
    if (change == null) {
      throw CouldNotFindChangeException();
    }
    await LocalStorable.isar!.writeAsync<bool>(
      (isar) {
        return isar.noteChanges.delete(change.isarId);
      },
    ).then(
      (bool couldDelete) {
        if (!couldDelete) {
          throw CouldNotDeleteChangeSyncException();
        }
      },
    );

    return change;
  }

  Future<NoteChange> addChange({required NoteChange change}) async {
    await _ensureCollectionIsOpen();
    final newChange = NoteChange(
      isarId: storableCollection.autoIncrement(),
      type: change.type,
      timestamp: change.timestamp,
      changedNote: change.changedNote,
    );
    await LocalStorable.isar!.writeAsync(
      (isar) {
        isar.noteChanges.put(newChange);
      },
    );

    return newChange;
  }

  Future<void> deleteAllChanges() async {
    await _ensureCollectionIsOpen();
    await LocalStorable.isar!.writeAsync((isar) {
      isar.noteChanges.clear();
    });
  }

  Future<void> deleteChange({required int id}) async {
    await _ensureCollectionIsOpen();

    // This will throw if change is not found in the collection
    await getChange(id: id);

    await LocalStorable.isar!.writeAsync(
      (isar) {
        return isar.noteChanges.delete(id);
      },
    ).then(
      (bool couldDelete) {
        if (!couldDelete) {
          throw CouldNotDeleteNoteException();
        }
      },
    );
  }

  Future<void> deleteAllChangesToNote({required int isarNoteId}) async {
    await _ensureCollectionIsOpen();

    await LocalStorable.isar!.writeAsync((isar) {
      isar.noteChanges
          .where()
          .changedNote((note) => note.isarIdEqualTo(isarNoteId))
          .deleteAll();
    });
  }

  Future<NoteChange> getChangeAndDelete({required int isarId}) async {
    await _ensureCollectionIsOpen();

    // This will throw if change is not found in the collection
    final change = await getChange(id: isarId);

    await LocalStorable.isar!.writeAsync(
      (isar) {
        return isar.noteChanges.delete(isarId);
      },
    ).then(
      (bool couldDelete) {
        if (!couldDelete) {
          throw CouldNotDeleteNoteException();
        }
      },
    );

    return change;
  }

  Future<void> _ensureCollectionIsOpen() async {
    if (LocalStorable.isar == null) {
      await LocalStore.open();
    }
  }
}

class CouldNotFindChangeException implements Exception {}
