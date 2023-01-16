import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/book_model.dart';

///                 -Vereceği Hizmetler-
/// Firestore servisinden kitapların verisini stream olarak alıp bu hizmeti sağlamak.
/// Firestore üzerinden silme hizmeti verecek.
/// Firestore üzerinden güncelleme hizmeti verecek.
/// Firestore üzerinden yazma hizmeti verecek.

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getBookListFromApi(
      String referencePath) {

    return _firestore.collection(referencePath).snapshots();
  }

  Future<void> deleteDocument(
      {required String referencePath, required String id}) async {

    await _firestore.collection(referencePath).doc(id).delete();
  }

  Future<void> setBookData(
      {required String collectionRef,
      required Map<String, dynamic> bookAsMap}) async {

    /// Book.fromMap(bookAsMap).id --> bookAsMap['id'] şeklinde de yazılabilirdi.
    _firestore
        .collection(collectionRef)
        .doc(Book.fromMap(bookAsMap).id)
        .set(bookAsMap);
  }
}
