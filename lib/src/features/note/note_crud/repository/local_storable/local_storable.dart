import 'package:isar/isar.dart';
import 'package:rxdart/rxdart.dart';

abstract class LocalStorable<T> {
  IsarCollection<T> get entityCollection;

  /// Opens the database collection for the entity [T]
  Future<void> open();

  /// Closes the database collection for the entity [T]
  Future<void> close();

  Future<T> createItem();

  Future<T> getItem({required int id});

  Future<List<T>> get getAllItems;

  Future<void> updateItem({required int id});

  Future<void> deleteItem({required int id});

  Future<void> deleteAllItems();

  ValueStream<List<T>> get allItemStream;

  Future<Stream<T>> itemStream({required int id});

  ValueStream get changeFeedStream;
}
