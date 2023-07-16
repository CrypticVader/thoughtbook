import 'package:cloud_firestore/cloud_firestore.dart';

abstract class CloudStorable<T> {
  CollectionReference<Map<String, dynamic>> get entityCollection;

  Stream<Iterable<T>> get allItems;

  Future<T> createItem();

  Future<T> getItem({required String cloudDocumentId});

  Future<void> updateItem({required String cloudDocumentId});

  Future<void> deleteItem({required String cloudDocumentId});
}
