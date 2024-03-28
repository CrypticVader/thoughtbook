import 'dart:developer';

import 'package:async/async.dart';
import 'package:isar/isar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_sync/domain/note_tag_change.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable_exceptions.dart';

class NoteTagChangeStorable extends LocalStorable<NoteTagChange> {
  static final NoteTagChangeStorable _shared = NoteTagChangeStorable._sharedInstance();

  NoteTagChangeStorable._sharedInstance() {
    _ensureCollectionIsOpen();
    _eventNotifierController = PublishSubject<void>();
    _noteTagChangeFeedController = PublishSubject<NoteTagChange>();
    // Sets up the local change-feed stream as a StreamQueue
    _changeFeedQueue = StreamQueue<NoteTagChange>(_noteTagChangeFeedController.stream);
  }

  factory NoteTagChangeStorable() => _shared;

  late final PublishSubject<NoteTagChange> _noteTagChangeFeedController;

  /// A [StreamQueue] to handle the local change feed stream
  late final StreamQueue<NoteTagChange> _changeFeedQueue;

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

  /// Responsible for listening for [NoteTagChange] and adding them to the change
  /// feed collection.
  Future<void> handleLocalChangeFeed() async {
    while (true) {
      try {
        NoteTagChange change = await _changeFeedQueue.next;
        log('local change: ${change.type}');
        if (change.type == SyncableChangeType.create) {
          await NoteTagChangeStorable().handleCreateChange(change: change);
        } else if (change.type == SyncableChangeType.update) {
          await NoteTagChangeStorable().handleUpdateChange(change: change);
        } else if (change.type == SyncableChangeType.delete) {
          await NoteTagChangeStorable().handleDeleteChange(change: change);
        } else {
          log('Invalid NoteTagChangeType of value ${change.type.toString()}');
        }
      } on StateError {
        throw NoteFeedClosedSyncException();
      }
    }
  }

  void addToChangeFeed({
    required ChangedNoteTag noteTag,
    required SyncableChangeType type,
  }) {
    _noteTagChangeFeedController.add(
      NoteTagChange(
        isarId: storableCollection.autoIncrement(),
        noteTag: noteTag,
        type: type,
        timestamp: DateTime.now().toUtc(),
      ),
    );
  }

  /// For a [NoteTagChange] of type [SyncableChangeType.create], the change is
  /// simply added to the [NoteTagChange] collection.
  Future<void> handleCreateChange({required NoteTagChange change}) async {
    await createChange(change: change);
  }

  /// For a [NoteTagChange] of type [SyncableChangeType.update], all existing changes
  /// of type [SyncableChangeType.update] to the same [ChangedNoteTag]
  /// are first removed from the [NoteTagChange] collection.
  ///
  /// Then the given [NoteTagChange] is added to the collection.
  Future<void> handleUpdateChange({required NoteTagChange change}) async {
    await _ensureCollectionIsOpen();
    // Find all changes on the given note of type update and delete them.
    LocalStorable.isar!.write(
      (isar) {
        final duplicateUpdatesCount = isar.noteTagChanges
            .where()
            .noteTag((noteTag) => noteTag.isarIdEqualTo(change.noteTag.isarId))
            .typeEqualTo(SyncableChangeType.update)
            .deleteAll();
        if (duplicateUpdatesCount > 0) {
          log(
            'Deleted $duplicateUpdatesCount updates to LocalNoteTag with '
            'isarId=${change.noteTag.isarId} from Collection',
            name: 'NoteTagChangeHelper',
          );
        }
      },
    );
    // Add the given change to the collection
    await createChange(change: change);
  }

  /// For a [NoteTagChange] of type [SyncableChangeType.delete], if a [NoteTagChange]
  /// of type [SyncableChangeType.create] is present for the same [LocalNote] in the
  /// [NoteTagChange] collection, it is removed & the given delete change is not
  /// added to the [NoteTagChange] collection.
  ///
  /// If [SyncableChangeType.create] to the same [LocalNote] is not found, then all
  /// [NoteTagChange] of type [SyncableChangeType.update] are purged from the [NoteTagChange]
  /// collection, and then the given delete change is added to the collection.
  Future<void> handleDeleteChange({required NoteTagChange change}) async {
    await _ensureCollectionIsOpen();
    // Find and delete NoteTagChange of type create of the same LocalNoteTag from the
    // collection and ignore the given delete change
    int noteTagCreateDeleted = 0;
    LocalStorable.isar!.write(
      (isar) {
        noteTagCreateDeleted = isar.noteTagChanges
            .where()
            .noteTag((noteTag) => noteTag.isarIdEqualTo(change.noteTag.isarId))
            .typeEqualTo(SyncableChangeType.create)
            .deleteAll();
      },
    );
    if (noteTagCreateDeleted == 1) {
      log(
        'NoteTagChange of type create to LocalNoteTag with isarId=${change.noteTag.isarId}'
        ' found and deleted. Ignoring delete change',
        name: 'NoteTagChangeHelper',
      );
    } else if (noteTagCreateDeleted == 0) {
      // If no NoteTagChange of type create to the same LocalNoteTag is found,
      // then delete all NoteTagChange of type update to the same LocalNote
      // and add the given delete change to the collection
      LocalStorable.isar!.write(
        (isar) {
          final duplicateUpdatesCount = isar.noteTagChanges
              .where()
              .noteTag((noteTag) => noteTag.isarIdEqualTo(change.noteTag.isarId))
              .typeEqualTo(SyncableChangeType.update)
              .deleteAll();
          if (duplicateUpdatesCount > 0) {
            log(
              'Deleted $duplicateUpdatesCount updates to LocalNoteTag with '
              'isarId=${change.noteTag.isarId} from Collection',
              name: 'NoteTagChangeHelper',
            );
          }
        },
      );
      await createChange(change: change);
    } else {
      log(
        'You should not be seeing this :/',
        name: 'NoteTagChangeStorable',
      );
    }
  }

  @override
  Future<List<NoteTagChange>> get getAllItems async {
    await _ensureCollectionIsOpen();
    return storableCollection.where().sortByTimestamp().findAll();
  }

  @override
  Future<NoteTagChange> getItem({required int id}) async {
    await _ensureCollectionIsOpen();
    final change = storableCollection.get(id);
    if (change == null) {
      throw CouldNotFindChangeException();
    } else {
      return change;
    }
  }

  Future<NoteTagChange> getOldestChangeAndDelete() async {
    await _ensureCollectionIsOpen();
    final change = storableCollection.where().sortByTimestamp().findFirst();
    if (change == null) {
      throw CouldNotFindChangeException();
    }
    final couldDelete = LocalStorable.isar!.write<bool>(
      (isar) {
        return isar.noteTagChanges.delete(change.isarId);
      },
    );
    if (couldDelete) {
      if (!couldDelete) {
        throw CouldNotDeleteChangeSyncException();
      }
    }

    return change;
  }

  Future<NoteTagChange> createChange({required NoteTagChange change}) async {
    await _ensureCollectionIsOpen();
    final newChange = NoteTagChange(
      isarId: storableCollection.autoIncrement(),
      type: change.type,
      timestamp: change.timestamp,
      noteTag: change.noteTag,
    );
    LocalStorable.isar!.write(
      (isar) {
        isar.noteTagChanges.put(newChange);
      },
    );

    // Notify event stream controller
    _eventNotifierController.sink.add(null);

    return newChange;
  }

  @override
  Future<void> deleteAllItems() async {
    await _ensureCollectionIsOpen();
    LocalStorable.isar!.write((isar) {
      isar.noteTagChanges.clear();
    });
  }

  @override
  Future<void> deleteItem({required int id}) async {
    await _ensureCollectionIsOpen();

    // This will throw if change is not found in the collection
    await getItem(id: id);

    final couldDelete = LocalStorable.isar!.write(
      (isar) {
        return isar.noteTagChanges.delete(id);
      },
    );
    if (couldDelete) {
      if (!couldDelete) {
        throw CouldNotDeleteNoteException();
      }
    }
  }

  Future<void> deleteAllChangesForNoteTag({required int isarNoteId}) async {
    await _ensureCollectionIsOpen();

    LocalStorable.isar!.write((isar) {
      isar.noteTagChanges
          .where()
          .noteTag((noteTag) => noteTag.isarIdEqualTo(isarNoteId))
          .deleteAll();
    });
  }

  Future<NoteTagChange> getItemAndDelete({required int isarId}) async {
    await _ensureCollectionIsOpen();

    // This will throw if change is not found in the collection
    final change = await getItem(id: isarId);

    final couldDelete = LocalStorable.isar!.write(
      (isar) {
        return isar.noteTagChanges.delete(isarId);
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
