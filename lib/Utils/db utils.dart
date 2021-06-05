import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:uuid/uuid.dart';

Future<void> detectLabels(String imagePath, String userId) async {
  final imageLabeler = GoogleMlKit.vision.imageLabeler();
  final List<ImageLabel> labels =
      await imageLabeler.processImage(InputImage.fromFilePath(imagePath));

  List<String> labelTexts = [];
  for (ImageLabel label in labels) {
    final String text = label.label;

    labelTexts.add(text);
  }

  final String uuid = Uuid().v1();
  final String downloadURL = await _uploadFile(uuid, imagePath, userId);

  await _addItem(downloadURL, labelTexts, userId);
}

Future<String> _uploadFile(filename, String imagePath, String userId) async {
  final File file = File(imagePath);

  final firebase_storage.Reference ref = firebase_storage
      .FirebaseStorage.instance
      .ref()
      .child('$userId/$filename.jpg');
  final firebase_storage.UploadTask uploadTask = ref.putFile(
    file,
    firebase_storage.SettableMetadata(
      contentLanguage: 'en',
    ),
  );

  firebase_storage.TaskSnapshot snapshot = await uploadTask;
  final downloadURL = await snapshot.ref.getDownloadURL();
  return downloadURL;
}

Future<void> _addItem(
    String downloadURL, List<String> labels, String userId) async {
  await FirebaseFirestore.instance
      .collection(userId)
      .add(<String, dynamic>{'downloadURL': downloadURL, 'labels': labels});
}

void showSnackBar(String message, BuildContext context) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.black87,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<void> deleteItem(String item, String userId) async {
  await FirebaseFirestore.instance
      .collection(userId)
      .doc(item)
      .delete()
      .then((value) => print('deletes'));
}
