import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CrudPage extends StatefulWidget {
  const CrudPage({Key? key}) : super(key: key);

  @override
  State<CrudPage> createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  /// firebase veritabanında ki her bir collection ve document'in adresini
  /// CollectionREference ve DocumentReference ile elde edebiliyoruz.
  /// bunun üzerinde sorgulama (bilgilerien erişme) işlemi gerçekleştiremeyiz.
  @override
  Widget build(BuildContext context) {
    final CollectionReference<Map<String, dynamic>> kitaplarRef =
        _database.collection('kitaplar');

    //final DocumentReference<Map<String, dynamic>> hobbitRef =
    //_database.collection('kitaplar').doc('Hobbit');

    /// Yukarda yorum satırında bulunan ifade ile aynı anlama geliyor.
    final DocumentReference<Map<String, dynamic>> hobbitRef =
        kitaplarRef.doc('Hobbit');

    final deneme =
        hobbitRef.collection('odunckayit').doc('VxrFIh8pfizCBFp87IvS');

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
            Text(
              'kitaplarRef: ${kitaplarRef.id}',
              style: const TextStyle(fontSize: 20),
            ),
            const Divider(thickness: 1, color: Colors.black),
            Text(
              'documentRef: ${hobbitRef.path}',
              style: const TextStyle(fontSize: 20),
            ),
            const Divider(thickness: 1, color: Colors.black),
            Text(
              'documentRef: ${deneme.id}',
              style: const TextStyle(fontSize: 20),
            ),
            const Divider(thickness: 1, color: Colors.black),
            ElevatedButton(
                onPressed: () async {
                  /// DocumentSnapshot döküman verilerinin taşındığı (okundugu) bir sınıf
                  final DocumentSnapshot<Map<String, dynamic>>
                      documentSnapshot = await hobbitRef.get();

                  /// Bu aşağıda ki kod get yukarda ki .get() metodu gibi fakat
                  /// bir Stream içinde döndürülüyor ve herhangi bir değişiklik
                  /// olduğu zaman bize DocmentSnapshot olarak veri gönderiyor.
                  final Stream<DocumentSnapshot<Map<String, dynamic>>>
                  streamDocumentSnapshot = await hobbitRef.snapshots();

                  final Map<String, dynamic>? data = documentSnapshot.data();

                  print('veri: ${data}');

                  /// Collection olarak veri çekme işlemi aşağıda yapılıyor.

                  /// QuerySnapshot bize Listeler halinde DocumentSnapshot döndürüyor.
                  QuerySnapshot<Map<String, dynamic>> x = await kitaplarRef.get();

                  /// QueryDocumentSnapshot DocumentSnapshot'dan implement edildiği için
                  /// List<DocumentSnapshot> newList = x.docs; Listeyi bu şekilde yazabiliyoruz
                  /// ayrıca docs getter'ı bize tüm dökümanların listesini verir.
                  List<DocumentSnapshot> newList = x.docs;

                  newList.forEach((element) {
                    print(element.data());
                  });

                },
                child: const Text('Get Data')),
          ],
        ),
      ),
    );
  }
}
