

import 'package:firebase_storage/firebase_storage.dart';

class PhotoUrl {

  FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> getUrlFromApi(String pathUrl, String photoUrl) async{

    Reference photoRef = _storage.ref().child(pathUrl);
    return photoRef.child(photoUrl).getDownloadURL();
  }


}