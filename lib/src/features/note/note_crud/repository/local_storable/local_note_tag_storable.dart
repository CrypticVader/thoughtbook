import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/crud_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_storable.dart';
import 'package:thoughtbook/src/features/note/note_sync/domain/note_change.dart';

class LocalNoteTagStorable implements LocalStorable<LocalNoteTag> {
  static final LocalNoteTagStorable _shared =
      LocalNoteTagStorable._sharedInstance();

  LocalNoteTagStorable._sharedInstance() {
    _ensureCollectionIsOpen();
    _noteTagsStreamController =
        BehaviorSubject<List<LocalNoteTag>>.seeded(_tags);
  }

  factory LocalNoteTagStorable() => _shared;

  Isar? _isar;
  List<LocalNoteTag> _tags = [];

  @override
  IsarCollection<LocalNoteTag> get entityCollection => _isar!.noteTags;

  late final BehaviorSubject<List<LocalNoteTag>> _noteTagsStreamController;

  /// Returns a [ValueStream] of collection of all the [LocalNoteTag] in the local note tags database.
  @override
  ValueStream<List<LocalNoteTag>> get allItemStream =>
      _noteTagsStreamController.stream;

  @override
  // TODO: implement changeFeedStream
  ValueStream get changeFeedStream => throw UnimplementedError();

  @override
  Future<List<LocalNoteTag>> get getAllItems async {
    await _ensureCollectionIsOpen();
    final noteTagsCollection = entityCollection;
    return await noteTagsCollection.where().anyId().findAll();
  }

  @override
  Future<LocalNoteTag> createItem() async {
    final currentTime = DateTime.now().toUtc();
    final isar = _isar!;

    final LocalNoteTag newTag = LocalNoteTag(
      name: '',
      cloudDocumentId: null,
      created: currentTime,
      modified: currentTime,
    );
    await isar.writeTxn(
      () async {
        final tagId = await entityCollection.put(newTag);
        return tagId;
      },
    ).then((value) => newTag..id = value);
    log('New NoteTag with id=${newTag.id} created');

    _tags.add(newTag);
    _noteTagsStreamController.add(_tags);

    return newTag;
  }

  @override
  Future<LocalNoteTag> getItem({required int id}) async {
    LocalNoteTag? noteTag;
    try {
      noteTag = await entityCollection.get(id);
      if (noteTag == null) {
        throw CouldNotFindNoteTagException();
      }
      return noteTag;
    } on StateError {
      throw CouldNotFindNoteTagException();
    }
  }

  /// Returns the latest version of a note from the local database in a [Stream] of [LocalNote]
  @override
  Future<Stream<LocalNoteTag>> itemStream({required int id}) async {
    await _ensureCollectionIsOpen();
    final noteTagsCollection = entityCollection;
    final note = await noteTagsCollection.get(id);
    if (note == null) {
      throw CouldNotFindNoteTagException();
    } else {
      Stream<LocalNoteTag?> noteTagStreamNullable =
          noteTagsCollection.watchObject(
        id,
        fireImmediately: true,
      );

      Stream<LocalNoteTag> noteTagStream = noteTagStreamNullable
          .where((note) => note != null)
          .map((note) => note!)
          .asBroadcastStream();

      return noteTagStream;
    }
  }

  @override
  Future<void> updateItem({
    required int id,
    String? name,
    String? cloudDocumentId,
    DateTime? modified,
    DateTime? created,
  }) async {
    final currentTime = DateTime.now().toUtc();
    LocalNoteTag? tag;
    final isar = _isar!;
    try {
      tag = await getItem(id: id);
    } catch (e) {
      throw CouldNotFindNoteTagException();
    }
    try {
      final newTag = LocalNoteTag(
        name: name ?? tag.name,
        cloudDocumentId: cloudDocumentId ?? tag.cloudDocumentId,
        modified: modified ?? currentTime,
        created: created ?? tag.created,
      )..id = id;
      await isar.writeTxn(() async => await entityCollection.put(newTag));

      _tags.removeWhere((tag) => tag.id == newTag.id);
      _tags.add(newTag);
      _noteTagsStreamController.add(_tags);
    } on IsarError catch (e) {
      if (e.message == 'Unique index violated.') {
        throw DuplicateNoteTagException();
      } else {
        throw CouldNotUpdateNoteTagException();
      }
    } catch (_) {
      throw CouldNotUpdateNoteTagException();
    }
  }

  @override
  Future<void> deleteItem({required int id}) async {
    final isar = _isar!;
    try {
      await getItem(id: id);
    } catch (e) {
      throw CouldNotFindNoteTagException();
    }
    try {
      await isar.writeTxn(() async => await entityCollection.delete(id));

      _tags.removeWhere((tag) => tag.id == id);
      _noteTagsStreamController.add(_tags);
    } catch (e) {
      throw CouldNotDeleteNoteTagException();
      // rethrow;
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
      await _cacheNoteTags();
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

  Future<void> _cacheNoteTags() async {
    final allNoteTags = await getAllItems;
    _tags = allNoteTags;
    _noteTagsStreamController.add(_tags);
  }

  @override
  Future<void> deleteAllItems() async {
    await _ensureCollectionIsOpen();
    final isar = _isar!;
    final noteTagsCollection = entityCollection;
    await isar.writeTxn(() async {
      await noteTagsCollection.clear();
    });

    // Add event to notes stream
    _tags = [];
    _noteTagsStreamController.add(_tags);
  }
}
