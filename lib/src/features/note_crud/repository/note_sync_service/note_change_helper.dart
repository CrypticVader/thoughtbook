import 'dart:async';
import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thoughtbook/src/features/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note_crud/domain/note_change.dart';
import 'package:thoughtbook/src/features/note_crud/repository/local_note_service/crud_exceptions.dart';
import 'package:thoughtbook/src/features/note_crud/repository/note_sync_service/note_sync_exceptions.dart';
import 'package:thoughtbook/src/features/note_crud/repository/note_sync_service/note_sync_service.dart';

class NoteChangeHelper {
  Isar? _isar;

  IsarCollection<NoteChange> get changeCollection => _isar!.noteChanges;

  static final NoteChangeHelper _shared = NoteChangeHelper._sharedInstance();

  NoteChangeHelper._sharedInstance() {
    _ensureCollectionIsOpen();
    eventNotifierController = StreamController<void>.broadcast();
  }

  factory NoteChangeHelper() => _shared;

  Future<bool> get isCollectionEmpty async {
    await _ensureCollectionIsOpen();
    return (await changeCollection.count() == 0) ? true : false;
  }

  late StreamController<void> eventNotifierController;

  Future<Stream<void>> get eventNotifier async {
    await _ensureCollectionIsOpen();
    return eventNotifierController.stream;
  }

  /// For a [NoteChange] of type [NoteChangeType.create], the change is simply
  /// added to the [NoteChange] collection.
  Future<void> handleCreateChange({required NoteChange change}) async {
    await NoteChangeHelper().createChange(change: change);

    // Notify event stream controller
    eventNotifierController.sink.add(null);
  }

  /// For a [NoteChange] of type [NoteChangeType.update], all existing changes
  /// of type [NoteChangeType.update] to the same [LocalNote]
  /// are first removed from the [NoteChange] collection.
  ///
  /// Then the given [NoteChange] is added to the collection.
  Future<void> handleUpdateChange({required NoteChange change}) async {
    await _ensureCollectionIsOpen();
    // Find all changes to the given note of type update and delete them.
    await _isar?.writeTxn(
      () async {
        final duplicateUpdatesCount = await changeCollection
            .where()
            .noteIsarIdEqualTo(change.noteIsarId)
            .filter()
            .typeEqualTo(NoteChangeType.update)
            .deleteAll();
        log(
          'Deleted $duplicateUpdatesCount updates to LocalNote with isarId=${change.noteIsarId} from Collection',
          name: 'NoteChangeHelper',
        );
      },
    );
    // Add the given change to the collection
    await createChange(change: change);

    // Notify event stream controller
    eventNotifierController.sink.add(null);
  }

  /// For a [NoteChange] of type [NoteChangeType.delete], if a [NoteChange] of
  /// type [NoteCHangeType.create] to the same [LocalNote] is present in the
  /// [NoteChange] collection, it is removed & the given delete change is not
  /// added to the [NoteChange] collection.
  ///
  /// If [NoteChangeType.create] to the same [LocalNote] is not found, then all
  /// [NoteChange] of type [NoteChangeType.update] are purged from the [NoteChage]
  /// collection, and then the given delete change is added to the collection.
  Future<void> handleDeleteChange({required NoteChange change}) async {
    await _ensureCollectionIsOpen();
    // Find and delete NoteChange of type create of the same LocalNote from the collection
    // and ignore the given delete change
    int noteCreateDeleted = 0;
    await _isar?.writeTxn(
      () async {
        noteCreateDeleted = await changeCollection
            .where()
            .noteIsarIdEqualTo(change.noteIsarId)
            .filter()
            .typeEqualTo(NoteChangeType.create)
            .deleteAll();
      },
    );
    if (noteCreateDeleted == 1) {
      log(
        'NoteChange of type create to LocalNote with isarId=${change.noteIsarId} found and deleted. Ignoring delete change',
        name: 'NoteChangeHelper',
      );
    } else if (noteCreateDeleted == 0) {
      // If no NoteChange of type create to the same LocalNote is found,
      // then delete all NoteChange of type update to the same LocalNote
      // and add the given delete change to the collection
      await _isar?.writeTxn(
        () async {
          final duplicateUpdatesCount = await changeCollection
              .where()
              .noteIsarIdEqualTo(change.noteIsarId)
              .filter()
              .typeEqualTo(NoteChangeType.update)
              .deleteAll();
          log(
            'Deleted $duplicateUpdatesCount updates to LocalNote with isarId=${change.noteIsarId} from Collection',
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
    eventNotifierController.sink.add(null);
  }

  Future<List<NoteChange>> get getAllChanges async {
    await _ensureCollectionIsOpen();
    return await changeCollection.where().sortByTimestamp().findAll();
  }

  Future<NoteChange> getChange({required int id}) async {
    await _ensureCollectionIsOpen();
    final change = await changeCollection.get(id);
    if (change == null) {
      throw CouldNotFindChangeException();
    } else {
      return change;
    }
  }

  Future<NoteChange> getOldestChangeAndDelete() async {
    await _ensureCollectionIsOpen();
    final isar = _isar!;

    final change = await changeCollection.where().sortByTimestamp().findFirst();
    if (change == null) {
      throw CouldNotFindChangeException();
    }
    await isar.writeTxn(
      () async {
        return await changeCollection.delete(change.id);
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

  Future<NoteChange> createChange({required NoteChange change}) async {
    await _ensureCollectionIsOpen();
    final isar = _isar!;
    await isar.writeTxn(
      () async {
        final changeId = await changeCollection.put(change);
        return changeId;
      },
    ).then((changeId) => change..id = changeId);

    return change;
  }

  Future<void> deleteAllChanges() async {
    await _ensureCollectionIsOpen();
    final isar = _isar!;
    await isar.writeTxn(() async {
      await changeCollection.clear();
    });
  }

  Future<void> deleteChange({required int id}) async {
    await _ensureCollectionIsOpen();
    final isar = _isar!;

    // This will throw if change is not found in the collection
    await getChange(id: id);

    await isar.writeTxn(
      () async {
        return await changeCollection.delete(id);
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
    final isar = _isar!;

    await isar.writeTxn(() async {
      await changeCollection.where().noteIsarIdEqualTo(isarNoteId).deleteAll();
    });
  }

  Future<NoteChange> getChangeAndDelete({required int isarId}) async {
    await _ensureCollectionIsOpen();
    final isar = _isar!;

    // This will throw if change is not found in the collection
    final change = await getChange(id: isarId);

    await isar.writeTxn(
      () async {
        return await changeCollection.delete(isarId);
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
    Isar? isar = Isar.getInstance();
    final docsPath = await getApplicationDocumentsDirectory();
    isar ??= await Isar.open(
      [
        LocalNoteSchema,
        NoteChangeSchema,
      ],
      directory: docsPath.path,
      inspector: true,
    );
    _isar = isar;
  }

  Future<void> _ensureCollectionIsOpen() async {
    try {
      await _open();
    } on CollectionAlreadyOpenException {
      // empty
    }
  }
}

class CouldNotFindChangeException implements Exception {}
