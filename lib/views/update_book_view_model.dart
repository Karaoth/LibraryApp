import 'package:flutter/material.dart';
import 'package:kitaplar/services/calculator.dart';
import '../models/book_model.dart';
import '../services/database.dart';

class UpdateBookViewModel extends ChangeNotifier {
  Database _database = Database();
  String collectionRef = 'books';

  /// updateBook'da ayrıca book adında Book sınıfından bir parametre ekliyoruz.
  /// bunun sebebi tekrar yeni bir nesne yaratmak yerine varolan nesne üzerinden
  /// güncelleştirmeyi sağlamak.
  Future<void> updateBook(
      {required String bookName,
      required String authorName,
      required DateTime publishDate,
      required Book book}) async {

    /// burada book sınıfının book.id'sini kullanarak hangi veri üzerinde işlem
    /// yaptıgımızı biliyoruz
     Book newBook = Book(
        bookName: bookName,
        authorName: authorName,
        publishDate: Calculator.datetimeToTimestamp(publishDate),
        id: book.id,
        borrows: book.borrows
     );

    /// toMap metodu Book sınıfının içerisinde ki verileri Map'e dönüştürüyor.
    await _database.setBookData(
        collectionRef: collectionRef, bookAsMap: newBook.toMap());
  }
}




















