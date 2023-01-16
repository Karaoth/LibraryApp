import 'package:flutter/material.dart';
import 'package:kitaplar/views/update_book_view_model.dart';
import 'package:provider/provider.dart';

import '../models/book_model.dart';
import '../services/calculator.dart';
import 'add_book_view_model.dart';

class UpdateBookView extends StatefulWidget {
  /// BookView'den kitap bilgilerini almak için kullanacağız
  final Book book;

  const UpdateBookView({super.key, required this.book});

  @override
  State<UpdateBookView> createState() => _UpdateBookViewState();
}

class _UpdateBookViewState extends State<UpdateBookView> {
  TextEditingController bookCtrl = TextEditingController();
  TextEditingController authorCtrl = TextEditingController();
  TextEditingController publishCtrl = TextEditingController();
  var _selectedDate;

  final _formKey = GlobalKey<FormState>();

  /// dispose kullanmamızın sebebi, verinin cihaz hafızasında kapladığı alanı boşaltıyoruz.
  @override
  void dispose() {
    bookCtrl.dispose();
    authorCtrl.dispose();
    publishCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Stateful widgetların instance alanlarına widget.book diyerek ulaşıyoruz.
    bookCtrl.text = widget.book.bookName;
    authorCtrl.text = widget.book.authorName;

    /// önce calculator sınıfı ile widget.book.pusblishdate'den timestamp'ı datetime
    /// ardından datetime'ı string'e dönüşümünü yapıp publishctr.text'e gönderiyoruz.
    publishCtrl.text = Calculator.dateTimeToString(
        Calculator.datetimeFromTimestamp(widget.book.publishDate));

    return ChangeNotifierProvider<UpdateBookViewModel>(
      create: (context) => UpdateBookViewModel(),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Kitap Bilgisi Güncelle'),
        ),
        body: Container(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: bookCtrl,
                  decoration: const InputDecoration(
                    hintText: 'kitap Adı',
                    icon: Icon(Icons.book),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kitap Adı Boş Olamaz';
                    } else {
                      return null;
                    }
                  },
                ),
                TextFormField(
                  controller: authorCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Yazar Adı',
                    icon: Icon(Icons.edit),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Yazar Adı Boş Olamaz';
                    } else {
                      return null;
                    }
                  },
                ),
                TextFormField(
                  onTap: () async {
                    _selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(-1000),
                        lastDate: DateTime.now());

                    publishCtrl.text =
                        Calculator.dateTimeToString(_selectedDate!);
                  },
                  controller: publishCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Basım Tarihi',
                    icon: Icon(Icons.date_range),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen Tarih Seçiniz';
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        /// kullanıcı bilgileri ile addNewBook metodu cagırılacak

                        /// context.read() okuma, context.watch() ise NotifierListener'ı dinliyor
                        await context.read<UpdateBookViewModel>().updateBook(
                            bookName: bookCtrl.text,
                            authorName: authorCtrl.text,
                            publishDate: _selectedDate ??
                                Calculator.datetimeFromTimestamp(
                                    widget.book.publishDate),
                            book: widget.book
                        );

                        /// ardından Navigator.pop
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Güncelle'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
