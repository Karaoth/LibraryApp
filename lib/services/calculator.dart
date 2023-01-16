import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Calculator {
  /// DateTime zaman biçimini ---> String'e formatlayıp çeviren metoda ihtiyacımız var

  static String dateTimeToString(DateTime dateTime) {
    String formattedDate = DateFormat('MM/ dd/ yyy').format(dateTime);

    return formattedDate;
  }

  /// Datetime'ı ---> TimeStamp'e dönüştürme
  static Timestamp datetimeToTimestamp(DateTime dateTime) {
    /// firebase tarihi bu şekilde tuttuğu için bizde tarih çevirme işlemlerimizi
    /// x tarihten itibaren kaç milisaniye geçtiğini hesaplatıyoruz.

    //Timestamp.fromDate(dateTime);
    ///yukarda ki şekli ile de bir kullanımı denemeliyim.
    return Timestamp.fromMillisecondsSinceEpoch(
        dateTime.millisecondsSinceEpoch);
  }

  /// TimeStamp'ı ---> DateTime'a dönüştürmek
  static DateTime datetimeFromTimestamp(Timestamp timeStamp) {
    /// firebase bizden milisaniye değil saniye olarak geldiği için 1000 ile çarptık.
    /// ayrıca bu metodları DateTime ile güncellenmiş kullanımlarına da göz atmalıyım.

    return DateTime.fromMillisecondsSinceEpoch(timeStamp.seconds * 1000);
  }
}
