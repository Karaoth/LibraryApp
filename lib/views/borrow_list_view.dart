import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/book_model.dart';
import '../models/borrow_info.dart';
import '../services/calculator.dart';
import 'borrow_list_view_model.dart';
import 'dart:io';

class BorrowListView extends StatefulWidget {
  final Book book;

  const BorrowListView({Key? key, required this.book}) : super(key: key);

  @override
  State<BorrowListView> createState() => _BorrowListViewState();
}

class _BorrowListViewState extends State<BorrowListView> {
  @override
  Widget build(BuildContext context) {
    List<BorrowInfo> borrowList = widget.book.borrows;

    return ChangeNotifierProvider<BorrowListViewModel>(
      create: (context) => BorrowListViewModel(),
      builder: (context, child) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            FirebaseStorage _storage = FirebaseStorage.instance;

            Reference photosRef = _storage.ref().child('photos');
            String info =
                await photosRef.child('age of empies.jpg').getDownloadURL();

            print(info);
          },
        ),
        appBar: AppBar(
          title: const Text('Barrow List'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            /// spaceBetween childlerin arasını olabildiğince açacak şekilde dağıtıyor.
            /// yani bir child'ini en üste diğerini en alta yapıştırıyor.
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              NetworkImage(borrowList[index].photoUrl),
                          /*
                              backgroundImage: NetworkImage(
                                  'https://www.icons101.com/c/icons/icon_ico/id_80541/Elder_Scrolls_Online.ico'),
                               */
                        ),
                        title: Text(
                            '${borrowList[index].name} ${borrowList[index].surname}'),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    itemCount: borrowList.length),
              ),
              InkWell(
                onTap: () async {
                  /// showModalBottomSheet kapatıldığında bize bir veri dönüyor.
                  /// eğer showModalBottomSheet kapatılırsa geriye null değer döner
                  /// enableDrag ve isDismissible parametreleri showModalBottomSheet
                  /// açıldığında mouse'la tıklayınca ya da modal'ı aşağı çekerek
                  /// kapatmayı engellemeye yarıyor.
                  BorrowInfo newBorrowInfo = await showModalBottomSheet(
                    enableDrag: false,
                    isDismissible: false,
                    context: context,
                    builder: (context) {
                      /// WillPopScope bize geri tuşunu sarmaladığımız build edilen
                      /// yapı üzerinde kullanmamızı engelliyor.
                      return WillPopScope(
                          onWillPop: () async {
                            return false;
                          },
                          child: const BorrowForm());
                    },
                  );

                  if (newBorrowInfo == null) {
                    /// eğer değer null geliyorsa fotoyu silecek.

                  }

                  if (newBorrowInfo != null) {
                    setState(() {
                      borrowList.add(newBorrowInfo);
                    });
                    context
                        .read<BorrowListViewModel>()
                        .addBorrow(book: widget.book, borrows: borrowList);
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 80,
                  color: Colors.blueAccent,
                  child: const Text('YENİ ÖDÜNÇ',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///BorrowForm
class BorrowForm extends StatefulWidget {
  const BorrowForm({Key? key}) : super(key: key);

  @override
  State<BorrowForm> createState() => _BorrowFormState();
}

class _BorrowFormState extends State<BorrowForm> {
  TextEditingController nameCtr = TextEditingController();
  TextEditingController surnameCtr = TextEditingController();
  TextEditingController borrowDateCtr = TextEditingController();
  TextEditingController returnDateCtr = TextEditingController();

  DateTime? _selectedBorrowDate;
  DateTime? _selectedReturnDate;

  final _formKey = GlobalKey<FormState>();

  File? _image;
  final ImagePicker _imagePicker = ImagePicker();
  String? _photoUrl;

  /// Kameradan fotograf çekme işlemi yapılıyor.
  Future getImage() async {
    final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 200);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('no image selected');
      }
    });
    if (pickedFile != null) {
      _photoUrl = await uploadGetStorage(_image!);
    }

    print('downloaded photo url: $_photoUrl');
  }

  Future<String> uploadGetStorage(File imageFile) async {
    FirebaseStorage _storage = FirebaseStorage.instance;

    ///Storage üzerinde ki dosya adını oluşturuyor.
    String path = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    Reference photosRef = _storage.ref().child('photos').child(path);

    /// TaskSnapshot fotograf yüklemenin sonucu döndüren bir sınıf
    TaskSnapshot uploadTask = await photosRef.putFile(imageFile);

    /// getDownloadURL ile Buradan yüklenen fotografın url'ine ulaşıyoruz.
    String uploadedImageUrl = await uploadTask.ref.getDownloadURL();
    //print('Uploaded Image is ==> $uploadedImageUrl');

    return uploadedImageUrl;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameCtr.dispose();
    surnameCtr.dispose();
    borrowDateCtr.dispose();
    returnDateCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BorrowListViewModel>(
      create: (context) => BorrowListViewModel(),
      builder: (context, child) => Container(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          /*
                         child: (_image == null) ?
                         const Image(image: NetworkImage(
                          'https://evrimagaci.org/public/content_media/98f5eba2e2402d965ee8d6c04f26b005.jpg',
                        )) : Image.file(_image!),
                         /// Ayrıca yukarda ki gibi FileImage(_image!) yerine Image.file(_image!)'da
                         /// kullanılabilir. fakat Image.file() bir widget'dır
                         /// FileImage() ise as ImageProvider ile ImageProvider nesnesi döner.
                          */
                          backgroundImage: (_image == null)
                              ? const NetworkImage(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRqcg1nnArkKn1N_AYD89xjPiso9Fj10_ZnfA&usqp=CAU',
                                )
                              : FileImage(_image!) as ImageProvider,

                          /// yukarda 'as ImageProvider' yazmamızın sebebi backgroundImage
                          /// ImageProvider türünde nesne kabul ediliyor olmasıdır.
                          /// Ayrıca FileImage(_image!) yerine Image.file(_image!)'da kullanılabilir.
                        ),
                        Positioned(
                          bottom: -5,
                          right: -10,
                          child: IconButton(
                              onPressed: getImage,
                              icon: Icon(
                                Icons.photo_camera_rounded,
                                color: Colors.grey.shade100,
                                size: 26,
                              )),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameCtr,
                          decoration: const InputDecoration(
                            hintText: 'Ad',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ad Giriniz';
                            } else {
                              return null;
                            }
                          },
                        ),
                        TextFormField(
                          controller: surnameCtr,
                          decoration: const InputDecoration(
                            hintText: 'Soyad',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Soyadı Giriniz';
                            } else {
                              return null;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: TextFormField(
                        onTap: () async {
                          _selectedBorrowDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)));

                          borrowDateCtr.text =
                              Calculator.dateTimeToString(_selectedBorrowDate!);
                        },
                        controller: borrowDateCtr,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.date_range),
                          hintText: 'Alım Tarihi',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen Tarih Seçiniz';
                          } else {
                            return null;
                          }
                        }),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: TextFormField(
                        onTap: () async {
                          _selectedReturnDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)));

                          returnDateCtr.text =
                              Calculator.dateTimeToString(_selectedReturnDate!);
                        },
                        controller: returnDateCtr,
                        decoration: const InputDecoration(
                            hintText: 'İade Tarihi',
                            prefixIcon: Icon(Icons.date_range)),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen Tarih Seçiniz';
                          } else {
                            return null;
                          }
                        }),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          BorrowInfo newBorrowInfo = BorrowInfo(
                              name: nameCtr.text,
                              surname: surnameCtr.text,
                              photoUrl: _photoUrl ??
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRqcg1nnArkKn1N_AYD89xjPiso9Fj10_ZnfA&usqp=CAU',
                              returnDate: Calculator.datetimeToTimestamp(
                                  _selectedReturnDate!),
                              borrowDate: Calculator.datetimeToTimestamp(
                                  _selectedBorrowDate!));

                          Navigator.pop(context, newBorrowInfo);
                        }
                      },
                      child: const Text('ÖDÜNÇ KAYIT EKLE')),
                  ElevatedButton(
                      onPressed: () {
                        if (_photoUrl != null) {
                          context
                              .read<BorrowListViewModel>()
                              .deletePhoto(_photoUrl!);
                        }

                        Navigator.pop(context);
                      },
                      child: const Text('İPTAL'))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
