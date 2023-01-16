import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/book_model.dart';
import '../services/database.dart';

/// bu sınıfın amacı bookview'ın state bilgisini tutmak
/// bookview'ın ihtiyacı olan metodları ve hesaplamaları yapmak
/// gerekli servisler ile konuşmak

class BooksViewModel extends ChangeNotifier {
  Database _database = new Database();
  String _collectionpath = 'books';

  Stream<List<Book>> getBookList() {
    /// stream<QuerySnapshot> --> Stream<List<DocumentSnapshot>>
    /// ilk önce burada QuerySnapshotları DocumentSnapshotlara .map metodu çevirdik.
    /// ve bunları streamListDocument değişkeni içinde tanımladık

    Stream<List<DocumentSnapshot<Map<String, dynamic>>>> streamListDocument =
        _database
            .getBookListFromApi(_collectionpath)
            .map((querySnapshot) => querySnapshot.docs);

    /// Stream<List<DocumentSnapshot>> --> Stream<List<kitaplar>>
    /// Stream ve List yapısı iç içe 2 boyutlu bir dizi gibi olduğu için
    /// DocumentSnapshot olan streamListDocument'ın içerisinde ki elemanlara
    /// teker teker ulaşıp bunları Book nesnesine çevirme işlemi yapıyoruz.

    /// en sonda ki map'in sonuna toList() metodu ile Listeye dönüştürdük.
    /// aksi halde bize Iterable bir map döndürüyor olacaktır.
    Stream<List<Book>> streamListBook = streamListDocument.map(
        (listOfDocSnap) => listOfDocSnap
            .map((docSnap) => Book.fromMap(docSnap.data()))
            .toList());

    return streamListBook;
  }

  /// parametre olarak Book nesnesi alıyor olmasının sebebi book_view'de kitabın
  /// indeksine ulaşıp silinmesi istenilen indeks'de ki nesnenin id'si bilgisini alıyor olması.
  Future<void> deleteBook(Book book) async {
    await _database.deleteDocument(referencePath: _collectionpath, id: book.id);
  }
}

