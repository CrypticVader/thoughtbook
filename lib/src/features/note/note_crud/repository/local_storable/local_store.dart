import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_note_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_note_tag_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/storable_exceptions.dart';

/// The access class for all [LocalStorable] extenders.
abstract class LocalStore {
  static LocalNoteStorable? _note;
  static LocalNoteTagStorable? _noteTag;

  /// Get a shared instance of [LocalNoteStorable]
  static LocalNoteStorable get note {
    if (_note == null) {
      throw Exception(
        'Could not find an instance of LocalNoteStorable.\n'
        'Please make sure to call LocalStore.open() before accessing any '
        'LocalStorable instances',
      );
    }
    return _note!;
  }

  /// Get a shared instance of [LocalNoteTagStorable]
  static LocalNoteTagStorable get noteTag {
    if (_noteTag == null) {
      throw Exception(
        'Could not find an instance of LocalNoteTagStorable.\n'
        'Please make sure to call LocalStore.open() before accessing any '
        'LocalStorable instances',
      );
    }
    return _noteTag!;
  }

  /// Open local database collections.
  /// This method should be run before accessing instances of any [LocalStorable].
  ///
  /// By default the collection for every model is opened. Pass the required
  /// argument to not open the collection for any model.
  static Future<void> open({
    bool note = true,
    bool noteTag = true,
    bool noteChange = true,
    bool noteTagChange = true,
  }) async {
    try {
      await LocalStorable.open(
        note: note,
        noteTag: noteTag,
        noteChange: noteChange,
        noteTagChange: noteTagChange,
      );
      _note = LocalNoteStorable();
      _noteTag = LocalNoteTagStorable();
    } on DatabaseAlreadyOpenException {
      return;
    }
  }

  /// Close all the local database collections & dispose every open
  /// [LocalStorable] instance.
  ///
  /// No [LocalStorable] class can be accessed after calling this method unless
  /// `LocalStore.open()` is called.
  static Future<void> close({bool clearData = false}) async {
    if (clearData) {
      LocalStorable.isar?.write((isar) => isar.clear());
    }
    await LocalStorable.close();
    _note = null;
    _noteTag = null;
  }
}
