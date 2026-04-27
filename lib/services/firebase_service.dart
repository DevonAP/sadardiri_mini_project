import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/test_result_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadSelfie(File image, String userId) async {
    try {
      String fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('selfies/$fileName');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading selfie: $e');
      return '';
    }
  }

  Future<void> backupResult(TestResult result) async {
    try {
      await _firestore.collection('test_results').add(result.toMap());
    } catch (e) {
      print('Error backing up data: $e');
    }
  }
}