import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitaplar/views/books_view_model.dart';
import 'package:kitaplar/views/update_book_view.dart';
import 'package:provider/provider.dart';

import '../models/book_model.dart';
import '../views/add_book_view.dart';


class BooksView extends StatefulWidget {
  const BooksView({Key? key}) : super(key: key);

  @override
  State<BooksView> createState() => _BooksViewState();
}

class _BooksViewState extends State<BooksView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BooksViewModel>(
      create: (context) {
        return BooksViewModel();
      },

      /// builder:(context, child) yerine child : Scaffold olarak kullansaydık
      /// Flutter paketi bize hata vereceti.
      /// builder metodu eğer BooksViewModel sınıfında bir değişiklik olursa
      /// tekrar kendini rebuild edecek ve böylece state dinleme gerçekleşecek
      /// Kendime Not: neden builder eklememiz gerektiğini araştır!!!
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Cloud Crud İşlemleri'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Kitap Listesi',
                style: TextStyle(fontSize: 30),
              ),
              const Divider(thickness: 1, color: Colors.black),

              /// StreamBuilder ile yaptığımız bu yapıyı
              /// StreamProvider ile de oluşturabiliriz. bunu incelemeliyim.
              StreamBuilder<List<Book>>(
                stream: Provider.of<BooksViewModel>(context, listen: false)
                    .getBookList(),
                builder: (BuildContext context, asyncSnapshot) {
                  if (asyncSnapshot.hasError) {
                    return const Center(
                      child: Text('Bir hata oluştu, lütfen tekar deneyin'),
                    );
                  } else {
                    if (!asyncSnapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      /// asyncSnapshot Iterable olduğu için onun index'ine
                      /// ulaşabilmek için toList() metodunu kullandım.
                      /// yani Iterable olan bir yapıyı Listeye dönüştürdüm.
                      List<Book>? kitapList = asyncSnapshot.data;

                      return Flexible(
                        child: ListView.builder(
                          itemCount: kitapList?.length,
                          itemBuilder: (context, index) {
                            return Dismissible(
                              onDismissed: (direction) async {
                                Provider.of<BooksViewModel>(context,
                                        listen: false)
                                    .deleteBook(kitapList![index]);

                                print(kitapList[index].id);
                              },
                              key: UniqueKey(),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                color: Colors.red,
                                child: const Icon(Icons.delete),
                              ),
                              child: Card(
                                color: Colors.grey,
                                shape: const StadiumBorder(
                                  side: BorderSide(style: BorderStyle.solid),
                                ),
                                child: ListTile(
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                   UpdateBookView(book: kitapList![index])));
                                    },
                                  ),
                                  title: Text('${kitapList?[index].bookName}'),
                                  subtitle:
                                      Text('${kitapList?[index].authorName}'),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  }
                },
              ),
              FloatingActionButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddBookView()));
                },
                child: const Icon(Icons.add),
              )
            ],
          ),
        ),
      ),
    );
  }
}
