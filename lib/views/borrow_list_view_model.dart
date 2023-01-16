import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import '../models/book_model.dart';
import '../models/borrow_info.dart';
import '../services/database.dart';


class BorrowListViewModel extends ChangeNotifier {

  final Database _database = Database();
  String collectionRef = 'books';

  Future<void> addBorrow(
      {required Book book, required List<BorrowInfo> borrows}) async {

    Book newBook = Book(
      bookName: book.bookName,
      authorName: book.authorName,
      publishDate: book.publishDate,
      id: book.id,
      borrows: borrows
    );

    _database.setBookData(collectionRef: collectionRef, bookAsMap: newBook.toMap());

  }

  Future<void> deletePhoto (String photoUrl) async{
    /// url --> ref
    Reference photoref = FirebaseStorage.instance.refFromURL(photoUrl);

    await photoref.delete();
  }

}
