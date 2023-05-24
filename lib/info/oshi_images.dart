import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:image_picker/image_picker.dart';

import 'dart:io';

// ImageSetクラスを定義
class ImageSet {
  // _imgというImage型のプロパティを定義

  // imagesというList<Widget>型のstatic変数を定義

  static List<Widget> images = [];

  // downloadメソッドを定義

  // uploadメソッドを定義
  void upload(oshiName, uid, Wref) async {
    print("picker");
    // ファイルpickerFileを選択(ImagePicker)
    final pickerFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickerFile == null) {
      return;
    } else {
      print(pickerFile.path);
    }

    File file = File(pickerFile.path);
    late Future<int> images;

    FirebaseStorage storage = FirebaseStorage.instance;

    try {
      // FirebaseFirestoreのインスタンスを生成(db)
      final db = FirebaseFirestore.instance;
      // ドキュメントへの参照(docNumRef)
      final docNumRef =
          db.collection('users').doc(uid).collection("oshi").doc(oshiName);

      // imageNumメソッドを定義
      Future<int> imageNum(db, docNumRef, uid, oshiName) async {
        final images = await docNumRef.get("imageNum");
        print("枚数は$images");
        return images;
      }

      // imagesに画像枚数を代入
      images = imageNum(db, docNumRef, uid, oshiName);

      // 目的の保存領域(storeImage)を指定し、ファイルをアップロード
      var storeImage = storage.ref().child("UL/$oshiName/$images");
      await storeImage.putFile(file);
      String imageUrl = await storeImage.getDownloadURL();

      final docRef = db
          .collection('users')
          .doc(uid)
          .collection("oshi")
          .doc(oshiName)
          .collection("images");

      await docRef.doc(images.toString()).set({
        'imageURL': imageUrl,
      });

      int tmp = await images + 1;

      await docNumRef.update({"imageNum": tmp});
    } catch (e) {
      print(e);
    }
  }
}
