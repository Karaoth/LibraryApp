import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CrudPage extends StatefulWidget {
  const CrudPage({Key? key}) : super(key: key);

  @override
  State<CrudPage> createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  Map<String, dynamic> bookToAdd = {
    'ad': 'Denemeler',
    'yazar': 'Montaigne',
    'sene': 1580
  };

  @override
  Widget build(BuildContext context) {
    final CollectionReference<Map<String, dynamic>> kitaplarRef =
        _database.collection('kitaplar');

    //final DocumentReference<Map<String, dynamic>> hobbitRef =
    //_database.collection('kitaplar').doc('Hobbit');

    /// Yorum satırında bulunan ifade ile aynı anlama geliyor.
    final DocumentReference<Map<String, dynamic>> hobbitRef =
        kitaplarRef.doc('Hobbit');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Crud İşlemleri'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'veriler',
              style: TextStyle(fontSize: 30),
            ),
            const Divider(thickness: 1, color: Colors.black),

            /// StreamBuilder ile yaptığımız bu yapıyı
            /// StreamProvider ile de oluşturabiliriz. bunu incelemeliyim.
            StreamBuilder<QuerySnapshot>(
              stream: kitaplarRef.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
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
                    /// burada öncelikle asyncSnapshot.data, StreamBuilder'dan dönen
                    /// veriyi QuerySnapshotları data getterı ile querySnapshot'a verdik
                    QuerySnapshot<Object?>? querySnapshot = asyncSnapshot.data;

                    /// Ardından querySnapshot'ın içerisinde ki liste halinde bulunan
                    /// DocumentSnapshotları booksData'ya gönderdik.
                    /// QueryDocumentSnapshot DocumentSnapshot 'dan implemente edildiği için
                    /// DocumentSnapshot yazdım bunun orjinali QueryDocumentSnapshot'dır
                    /// ve arasında hiçbir fark yok.
                    List<DocumentSnapshot<Object?>>? booksData =
                        querySnapshot?.docs;

                    return Flexible(
                      child: ListView.builder(
                        itemCount: booksData?.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                            onDismissed: (direction) async {
                              /// await booksData?[index].reference.delete(); ile
                              /// önce silinecek verinin referansına erişip
                              /// ardından onu veritabanından delete metodu ile siliyoruz.
                              //await booksData?[index].reference.delete();
                              print(booksData?[index].data());
                              print(booksData?[index].id);

                              /// reference bize DocumentReference değeri dönüyor.
                              print(booksData?[index].reference);

                                  /// booksData?[index].reference.update() metodunu
                                  /// kullanarak bir dökümanın içinde ki alanı
                                  /// silme işlemi gerçekleştirmiş oluyoruz.
                                  booksData?[index]
                                      .reference
                                      .update({'sene': FieldValue.delete()});
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
                                title: Text('${booksData?[index].get('ad')}'),
                                subtitle:
                                    Text('${booksData?[index].get('yazar')}'),
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
                /// Ayrıca add metodu future içinde bir deocumentReference
                /// olarak bize gönderdiğimiz verileri dönüyor.
                /* DocumentReference<Map<String, dynamic>> addedBook =
                    await kitaplarRef.add(bookToAdd);

                print(addedBook.id);
                print(addedBook.path);
                 */
                _database.collection('Bla').doc('docy').delete();

                /// yukarıda ki add metodunda id'yi otomatik kendisi firebase
                /// üzerinden oluşturuyordu ve biz kontrol edemiyorduk.
                //await kitaplarRef.doc('Denemeler').set(bookToAdd);
                //await kitaplarRef.doc(bookToAdd['ad']).set(bookToAdd);

                /// update ile döküman üzerinden günceleme işlemi gerçekleşebiliyor
                /// örneğin sene bilgisini 1580'den 2000 olarak güncelleniyor.
                //await kitaplarRef.doc(bookToAdd['ad']).update({'sene': 2000});

                /// burada da sıfırdan bir kolesiyon oluşturup içerisinde
                /// döküman ve onun içerisinde de bir data oluşturduk.
                /*_database
                    .collection('kayıpKitaplar')
                    .doc('Harry Poter')
                    .set({'ad': 'Harry Poter', 'yazar': 'J. K. Rowling', 'sene': 1997});
                 */
              },
              child: const Icon(Icons.add),
            )
          ],
        ),
      ),
    );
  }
}
