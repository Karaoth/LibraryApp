import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kitaplar/views/borrow_list_view.dart';
import 'package:kitaplar/views/books_view_model.dart';
import 'package:kitaplar/views/update_book_view.dart';
import 'package:provider/provider.dart';

import '../models/book_model.dart';
import 'add_book_view.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
                    /// asyncSnapshot.error yazarak hata kodunu console'a yazdırabiliyoruz.
                    print(asyncSnapshot.error);
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

                      return BuildListView(kitapList: kitapList);
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

class BuildListView extends StatefulWidget {
  const BuildListView({
    Key? key,
    required this.kitapList,
  }) : super(key: key);

  final List<Book>? kitapList;

  @override
  State<BuildListView> createState() => _BuildListViewState();
}

class _BuildListViewState extends State<BuildListView> {
  bool isFiltering = false;
  List<Book>? filteredList;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefix: const Icon(Icons.search),
                hintText: 'Search: The Book Name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0)),
              ),

              /// Burada Flitreleme işlemlerinin yaptıldığı fonksiyon yer alıyor.
              onChanged: (query) {
                /// isNotEmpty denilmesinin sebebi kullanıcının boş bir karakter
                /// girip girmediğini bulmak
                if (query.isNotEmpty) {
                  isFiltering = true;

                  setState(() {
                    filteredList = widget.kitapList
                        ?.where((book) => book.bookName
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                        .toList();
                  });
                } else {
                  /// WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                  /// bize klavyenin focusunu kaldırmamızı sağlıyor.
                  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                  setState(() {
                    isFiltering = false;
                  });
                }
              },
            ),
          ),
          Flexible(
            child: ListView.builder(
              /// burada isFiltering ile kullanıcı klavyeden girdiği veri ile
              /// veritabanında eşleşen isimler olursa bu bilgileri yeni
              /// bir listeye ekleyip yeni bir ListView döndürüyor.
              itemCount:
                  isFiltering ? filteredList?.length : widget.kitapList?.length,
              itemBuilder: (context, index) {
                var list = isFiltering ? filteredList : widget.kitapList;
                return Slidable(
                  key: UniqueKey(),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    dismissible: null,
                    children: [
                      SlidableAction(
                        flex: 1,
                        onPressed: (context) async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                       BorrowListView(book: list![index])));


                        },
                        backgroundColor: const Color(0XFF81D4FA),
                        foregroundColor: Colors.white,
                        icon: Icons.person,
                        label: 'Kayıtlar',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    dismissible: null,
                    children: [
                      SlidableAction(
                        flex: 1,
                        onPressed: (context) async {
                          Provider.of<BooksViewModel>(context, listen: false)
                              .deleteBook(list![index]);

                          print(widget.kitapList?[index].id);
                        },
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      UpdateBookView(book: list![index])));
                        },
                        backgroundColor: const Color(0xFF21B7CA),
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                    ],
                  ),
                  child: Card(
                    color: Colors.grey,
                    shape: const StadiumBorder(
                      side: BorderSide(style: BorderStyle.solid),
                    ),
                    child: ListTile(
                      title: Text('${list?[index].bookName}'),
                      subtitle: Text('${list?[index].authorName}'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
