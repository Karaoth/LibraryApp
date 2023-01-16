import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowInfo {
  final String name;
  final String surname;
  final Timestamp borrowDate;
  final Timestamp returnDate;
  final String photoUrl;

  BorrowInfo(
      {required this.name,
      required this.surname,
      required this.borrowDate,
      required this.returnDate,
      required this.photoUrl});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'borrowDate': borrowDate,
      'returnDate': returnDate,
      'photoUrl': photoUrl
    };
  }

  factory BorrowInfo.fromMap(Map<String, dynamic> map) {
    return BorrowInfo(
        name: map['name'],
        surname: map['surname'],
        borrowDate: map['borrowDate'],
        returnDate: map['returnDate'],
        photoUrl: map['photoUrl']);
  }
}
