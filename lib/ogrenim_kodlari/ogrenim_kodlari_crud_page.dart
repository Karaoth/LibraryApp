import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CrudPage extends StatefulWidget {
  const CrudPage({Key? key}) : super(key: key);

  @override
  State<CrudPage> createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final CollectionReference<Map<String, dynamic>> kitaplarRef =
        _database.collection('kitaplar');

    //final DocumentReference<Map<String, dynamic>> hobbitRef =
    //_database.collection('kitaplar').doc('Hobbit');

    /// Yukarıdaki yorum satırında bulunan ifade ile aynı anlama geliyor.
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
            StreamBuilder<DocumentSnapshot>(
              /// stream'e eklenecek stream eklenmeli T tipinde
              stream: hobbitRef.snapshots(),

              /// builder 2 parametre alır 1. context widget agacında neyi
              /// nereye baglayacagını bilmesi için gereklidir.
              /// 2. Asyncsnapshot objesi yukarıda ki stream: 'den gelen verinin
              /// taşındığı obje olarak tanımlanabilir.
              /// 3 mutlaka bir widget dönmelidir, ve bu widget stream akışı
              /// ile birlikte ekranda yenilenecektir.

              /// Ayrıca Stream akışının 3 durumu vardır.
              /// 1. durum : hata gelmiş olabilir. = hasError metodu
              /// 2. durum : Veri bekleniyor = hasData metodu
              /// 3. durum : veri geldi ve kullanılabilir.
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> asyncSnapshot) {
                /// öncelikle veriyi AsyncSnapshot'dan çekip kendisine dönen
                /// degeri yani DocumentSnapshot bilgisini almamız gerekiyor.

                if (asyncSnapshot.hasError) {
                  /// buraya hata bilgisi içeren widget cizilecke
                  return const Center(
                    child: Text('Bir hata oluştu, sonra tekrar dneeyini<'),
                  );
                }
                else {
                  if (!asyncSnapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    /// DocumentSnapshot doküman(Document) verilerinin taşındığı sınıftır.
                    DocumentSnapshot<Object?>? documentSnapshot =
                        asyncSnapshot.data;

                    /// as Map  yazmadan veriyi Map olarak çekemedim.
                    /// as tür dönüşümünü araştırmalıyım.
                    var mapData =
                    documentSnapshot?.data() as Map<String?, dynamic>;

                    return Text('${mapData['yazar']}');
                  }
                }

              },
            )
          ],
        ),
      ),
    );
  }
}
