import 'dart:async';
import 'dart:developer';

import 'package:async/async.dart';
import 'package:isar/isar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_sync/domain/note_change.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable_exceptions.dart';

class NoteChangeStorable extends LocalStorable<NoteChange> {
  static final NoteChangeStorable _shared = NoteChangeStorable._sharedInstance();

  NoteChangeStorable._sharedInstance() {
    _ensureCollectionIsOpen();
    _eventNotifierController = PublishSubject<void>();
    _noteChangeFeedController = PublishSubject<NoteChange>();
    // Sets up the local change-feed stream as a StreamQueue
    _changeFeedQueue = StreamQueue<NoteChange>(_noteChangeFeedController.stream);
  }

  factory NoteChangeStorable() => _shared;

  late final PublishSubject<NoteChange> _noteChangeFeedController;

  /// A [StreamQueue] to handle the local change feed stream
  late final StreamQueue<NoteChange> _changeFeedQueue;

  Future<bool> get hasNoPendingChanges async {
    await _ensureCollectionIsOpen();
    return (storableCollection.count() == 0) ? true : false;
  }

  late PublishSubject<void> _eventNotifierController;

  /// Emits an event on every new entry added to the change collection.
  Future<Stream<void>> get newChangeNotifier async {
    await _ensureCollectionIsOpen();
    return _eventNotifierController.stream;
  }

  /// Responsible for listening for [NoteChange] and adding them to the change
  /// feed collection.
  Future<void> handleLocalChangeFeed() async {
    while (true) {
      try {
        NoteChange change = await _changeFeedQueue.next;
        log('local change: ${change.type}');
        if (change.type == SyncableChangeType.create) {
          await NoteChangeStorable().handleCreateChange(change: change);
        } else if (change.type == SyncableChangeType.update) {
          await NoteChangeStorable().handleUpdateChange(change: change);
        } else if (change.type == SyncableChangeType.delete) {
          await NoteChangeStorable().handleDeleteChange(change: change);
        } else {
          log('Invalid NoteChangeType of value ${change.type.toString()}');
        }
      } on StateError {
        throw NoteFeedClosedSyncException();
      }
    }
  }

  void addToChangeFeed({
    required ChangedNote note,
    required SyncableChangeType type,
  }) {
    _noteChangeFeedController.add(
      NoteChange(
        isarId: storableCollection.autoIncrement(),
        note: note,
        type: type,
        timestamp: DateTime.now().toUtc(),
      ),
    );
  }

  /// For a [NoteChange] of type [SyncableChangeType.create], the change is
  /// simply added to the [NoteChange] collection.
  Future<void> handleCreateChange({required NoteChange change}) async {
    await createChange(change: change);

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
    LocalStorable.isar!.write(
      (isar) {
        final duplicateUpdatesCount = isar.noteChanges
            .where()
            .note((note) => note.isarIdEqualTo(change.note.isarId))
            .typeEqualTo(SyncableChangeType.update)
            .deleteAll();
        log(
          'Deleted $duplicateUpdatesCount updates to LocalNote with '
          'isarId=${change.note.isarId} from Collection',
          name: 'NoteChangeHelper',
        );
      },
    );
    // Add the given change to the collection
    await createChange(change: change);

    // Notify event stream controller
    _eventNotifierController.sink.add(null);
  }

  /// For a [NoteChange] of type [SyncableChangeType.delete], if a [NoteChange] of
  /// type [SyncableChangeType.create] is present for the same [LocalNote] in the
  /// [NoteChange] collection, it is removed & the given delete change is not
  /// added to the [NoteChange] collection.
  ///
  /// If [SyncableChangeType.create] to the same [LocalNote] is not found, then all
  /// [NoteChange] of type [SyncableChangeType.update] are purged from the [NoteChange]
  /// collection, and then the given delete change is added to the collection.
  Future<void> handleDeleteChange({required NoteChange change}) async {
    await _ensureCollectionIsOpen();
    // Find and delete NoteChange of type create of the same LocalNote from the
    // collection and ignore the given delete change
    int noteCreateDeleted = 0;
    LocalStorable.isar!.write(
      (isar) {
        noteCreateDeleted = isar.noteChanges
            .where()
            .note((note) => note.isarIdEqualTo(change.note.isarId))
            .typeEqualTo(SyncableChangeType.create)
            .deleteAll();
      },
    );
    if (noteCreateDeleted == 1) {
      log(
        'NoteChange of type create to LocalNote with isarId=${change.note.isarId}'
        ' found and deleted. Ignoring delete change',
        name: 'NoteChangeHelper',
      );
    } else if (noteCreateDeleted == 0) {
      // If no NoteChange of type create to the same LocalNote is found,
      // then delete all NoteChange of type update to the same LocalNote
      // and add the given delete change to the collection
      LocalStorable.isar!.write(
        (isar) {
          final duplicateUpdatesCount = isar.noteChanges
              .where()
              .note((note) => note.isarIdEqualTo(change.note.isarId))
              .typeEqualTo(SyncableChangeType.update)
              .deleteAll();
          log(
            'Deleted $duplicateUpdatesCount updates to LocalNote with '
            'isarId=${change.note.isarId} from Collection',
            name: 'NoteChangeHelper',
          );
        },
      );
      await createChange(change: change);
    } else {
      log(
        'You should not be seeing this :/',
        name: 'NoteChangeHelper',
      );
    }

    // Notify event stream controller
    _eventNotifierController.sink.add(null);
  }

  @override
  Future<List<NoteChange>> get getAllItems async {
    await _ensureCollectionIsOpen();
    return storableCollection.where().sortByTimestamp().findAll();
  }

  @override
  Future<NoteChange> getItem({required int id}) async {
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
    final couldDelete = LocalStorable.isar!.write<bool>(
      (isar) {
        return isar.noteChanges.delete(change.isarId);
      },
    );
    if (couldDelete) {
      if (!couldDelete) {
        throw CouldNotDeleteChangeSyncException();
      }
    }

    return change;
  }

  Future<NoteChange> createChange({required NoteChange change}) async {
    await _ensureCollectionIsOpen();
    final newChange = NoteChange(
      isarId: storableCollection.autoIncrement(),
      type: change.type,
      timestamp: change.timestamp,
      note: change.note,
    );
    LocalStorable.isar!.write(
      (isar) {
        isar.noteChanges.put(newChange);
      },
    );

    return newChange;
  }

  @override
  Future<void> deleteAllItems() async {
    await _ensureCollectionIsOpen();
    LocalStorable.isar!.write((isar) {
      isar.noteChanges.clear();
    });
  }

  @override
  Future<void> deleteItem({required int id}) async {
    await _ensureCollectionIsOpen();

    // This will throw if change is not found in the collection
    await getItem(id: id);

    final couldDelete = LocalStorable.isar!.write(
      (isar) {
        return isar.noteChanges.delete(id);
      },
    );
    if (couldDelete) {
      if (!couldDelete) {
        throw CouldNotDeleteNoteException();
      }
    }
  }

  Future<void> deleteAllChangesForNote({required int isarNoteId}) async {
    await _ensureCollectionIsOpen();

    LocalStorable.isar!.write((isar) {
      isar.noteChanges.where().note((note) => note.isarIdEqualTo(isarNoteId)).deleteAll();
    });
  }

  Future<NoteChange> getItemAndDelete({required int isarId}) async {
    await _ensureCollectionIsOpen();

    // This will throw if change is not found in the collection
    final change = await getItem(id: isarId);

    final couldDelete = LocalStorable.isar!.write(
      (isar) {
        return isar.noteChanges.delete(isarId);
      },
    );
    if (couldDelete) {
      if (!couldDelete) {
        throw CouldNotDeleteNoteException();
      }
    }

    return change;
  }

  Future<void> _ensureCollectionIsOpen() async {
    if (LocalStorable.isar == null) {
      await LocalStore.open();
    }
  }
}
