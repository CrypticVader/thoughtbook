import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_storable.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_storable.dart';

abstract class Syncable<localStorable extends LocalStorable, cloudStorable extends CloudStorable> {
  Future<void> startSync();

  Stream<int> initLocalFromCloud();

  Future<void> syncLocalChangeFeed();
}

enum SyncableChangeType {
  create,
  update,
  delete,
  deleteAll,
}
