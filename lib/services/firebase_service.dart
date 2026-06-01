import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/test_result_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // =======================================================
  // 1. BAGIAN REGISTER / AUTHENTICATION
  // =======================================================

  Future<String> uploadSelfie(File file, String uid) async {
    final ref = _storage.ref().child('users_selfie/$uid.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> saveUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data);
  }

  // =======================================================
  // 2. BAGIAN DASHBOARD / TEST HISTORY
  // =======================================================

  /// Mengambil stream riwayat tes secara real-time
  Stream<List<TestResult>> getTestHistory(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('test_history')
        .orderBy('date', descending: true) // Sesuai dengan properti 'date' di model
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Kita petakan secara manual untuk mencegah error konversi tipe data
        // Karena di toMap() date disimpan sebagai String ISO8601
        return TestResult(
          userId: data['userId'] ?? uid,
          depressionScore: data['depressionScore'] ?? 0,
          anxietyScore: data['anxietyScore'] ?? 0,
          stressScore: data['stressScore'] ?? 0,
          selfieUrl: data['selfieUrl'] ?? '',
          // Cek apakah data berupa String ISO8601 (dari toMap) atau Timestamp Firestore
          date: data['date'] is String 
              ? DateTime.parse(data['date']) 
              : (data['date'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  /// Menyimpan hasil tes menggunakan instance TestResult
  Future<void> saveTestResult(TestResult result) async {
    await _firestore
        .collection('users')
        .doc(result.userId)
        .collection('test_history')
        .add(result.toMap()); // Memanfaatkan toMap() dari model Anda
  }

  Future<String> uploadTestSelfie(File file, String uid) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Disimpan di folder test_selfies agar tidak menimpa selfie referensi
    final ref = _storage.ref().child('test_selfies/${uid}_$timestamp.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}