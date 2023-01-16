import 'package:cloud_firestore/cloud_firestore.dart';

import 'borrow_info.dart';

class Book {
  final String id;
  final String bookName;
  final String authorName;
  final Timestamp publishDate;
  final List<BorrowInfo> borrows;

  Book(
      {required this.id,
      required this.bookName,
      required this.authorName,
      required this.publishDate,
      required final this.borrows});

  /// Firebase'den veriler bize map olarak geldiği için bize Objeden Map oluşturan
  /// oluşturan bir metod gerekmektedir

  Map<String, dynamic> toMap() {
    /// veritabanın içinde borros adında Maplerden oluşan bir liste var.
    /// bunların dönüşümünü List<BorrowsInfo> --> dan List<Map> e çeviriyoruz.
    List<Map<String, dynamic>> borrows =
        this.borrows.map((borrowInfo) => borrowInfo.toMap()).toList();

    return {
      'id': id,
      'bookName': bookName,
      'authorName': authorName,
      'publishDate': publishDate,
      'borrows': borrows
    };
  }

  /// Ayrıca map'den obje oluşturan bir constructor'a ihtiyaç var
  /// isimli bir constructor'un bir return değeri döndürebilmesi için bunun
  /// factory ile belirtilmesi gerekmetedir.

  factory Book.fromMap(Map<String, dynamic>? map) {
    /// as anahtar kelimesi tür dönüşümü sağlamaktadır.
    /// fakay yalnızca dönüştürülecek türden eminsek kullanmalıyız.
    /// aşağıda orjianli as List; olarak yazıldı bunu as List<Map<String, dynamic>>
    /// olarak değiştirdim.

    var borrowListAsMap = (map?['borrows'] ?? []) as List;

    ///yukarda ki kod aşağıda yorum satırında ki gibi de yazılabilir.
    /*
    List borrowListAsMap;
    if (map?['borrows'] == null) {
      borrowListAsMap = [];
    }
    else {
      borrowListAsMap = map?['borrows'] as List;
    }
     */

    List<BorrowInfo> borrows = borrowListAsMap
        .map((borrowAsMap) => BorrowInfo.fromMap(borrowAsMap))
        .toList();

    return Book(
        id: map?['id'],
        bookName: map?['bookName'],
        authorName: map?['authorName'],
        publishDate: map?['publishDate'],
        borrows: borrows
    );
  }




  /// Bu static metodu fromMap yapıcısı yerine de kullanabilirim.
  static Book myMethodToTry(Map<String, dynamic>? map) {
    /// as anahtar kelimesi tür dönüşümü sağlamaktadır.
    /// fakay yalnızca dönüştürülecek türden eminsek kullanmalıyız.
    /// aşağıda orjianli as List; olarak yazıldı bunu as List<Map<String, dynamic>>
    /// olarak değiştirdim.

    var borrowListAsMap = (map?['borrows'] ?? []) as List;

    ///yukarda ki kod aşağıda yorum satırında ki gibi de yazılabilir.
    /*
    List borrowListAsMap;
    if (map?['borrows'] == null) {
      borrowListAsMap = [];
    }
    else {
      borrowListAsMap = map?['borrows'] as List;
    }
     */

    List<BorrowInfo> borrows = borrowListAsMap
        .map((borrowAsMap) => BorrowInfo.fromMap(borrowAsMap))
        .toList();

    return Book(
        id: map?['id'],
        bookName: map?['bookName'],
        authorName: map?['authorName'],
        publishDate: map?['publishDate'],
        borrows: borrows);
  }

}
