import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kitaplar/services/calculator.dart';
import '../models/book_model.dart';
import '../services/database.dart';

class AddBookViewModel extends ChangeNotifier {

  Database _database = Database();
  String collectionRef = 'books';

  Future<void> addNewBook(
      {required String bookName, required String authorName, required DateTime publishDate}) async {

    Book newBook = Book(
      bookName: bookName,
      authorName: authorName,
      publishDate: Calculator.datetimeToTimestamp(publishDate),
      id: DateTime.now().toIso8601String(),
      borrows: []
    );

    /// toMap metodu Book sınıfının içerisinde ki verileri Map'e dönüştürüyor.
    await _database.setBookData(collectionRef: collectionRef, bookAsMap: newBook.toMap());

  }

}