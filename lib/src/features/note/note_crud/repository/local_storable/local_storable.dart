import 'dart:developer' show log;

import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart' show ValueStream;
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';
import 'package:thoughtbook/src/features/note/note_sync/domain/note_change.dart';
import 'package:thoughtbook/src/features/note/note_sync/domain/note_tag_change.dart';

abstract class LocalStorable<T> {
  static Isar? _isar;

  /// Gets the [Isar] instance, if it is open.
  static Isar? get isar => _isar;

  /// The database collection of the the type [T].
  IsarCollection<int, T> get storableCollection => isar!.collection<int, T>();

  /// Opens the database collections.
  static Future<void> open({
    required bool note,
    required bool noteTag,
    required bool noteChange,
    required bool noteTagChange,
  }) async {
    if (_isar != null) throw DatabaseAlreadyOpenException();

    final docsPath = kIsWeb ? Isar.sqliteInMemory : (await getApplicationDocumentsDirectory()).path;
    final schemas = [
      if (note) LocalNoteSchema,
      if (noteChange) NoteChangeSchema,
      if (noteTag) LocalNoteTagSchema,
      if (noteTagChange) NoteTagChangeSchema,
    ];

    if (kIsWeb) {
      Isar.initialize();
    }
    _isar ??= Isar.open(
      engine: kIsWeb ? IsarEngine.sqlite : IsarEngine.isar,
      schemas: schemas,
      directory: docsPath,
      inspector: !kReleaseMode,
    );
    log('Isar opened');
  }

  /// Closes all the database collections.
  static Future<void> close() async {
    if (_isar != null) {
      _isar!.close();
      _isar = null;
    }
  }

  /// Creates a [T] in the collection & and returns its instance.
  Future<T> createItem() async =>
      throw UnsupportedError('This method must be implemented by a child class.');

  /// Gets the [T] with the given [id] from the database.
  ///
  /// Throws if not found.
  Future<T> getItem({required int id}) =>
      throw UnsupportedError('This method must be implemented by a child class.');

  /// Returns a list of all the objects of type [T] in the database.
  Future<List<T>> get getAllItems =>
      throw UnsupportedError('This method must be implemented by a child class.');

  /// Tries to update the [T] with the given [id] in the database.
  Future<void> updateItem({required int id}) =>
      throw UnsupportedError('This method must be implemented by a child class.');

  /// Tries to delete the [T] with the given [id] in the database.
  Future<void> deleteItem({required int id}) =>
      throw UnsupportedError('This method must be implemented by a child class.');

  /// Deletes all the objects in the collection of type [T].
  Future<void> deleteAllItems() =>
      throw UnsupportedError('This method must be implemented by a child class.');

  /// Returns a [ValueStream] of collection of all the [T] in the local database.
  ValueStream<List<T>> get allItemStream =>
      throw UnsupportedError('This method must be implemented by a child class.');

  /// Returns the latest version of a [T] from the local database in a [ValueStream]
  ValueStream<T> itemStream({required int id}) =>
      throw UnsupportedError('This method must be implemented by a child class.');
}
