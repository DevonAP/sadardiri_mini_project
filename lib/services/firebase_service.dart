import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/test_result_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =======================================================
  // HELPER: Upload gambar ke ImgBB
  // =======================================================

  /// Upload gambar ke ImgBB dan kembalikan URL publik.
  /// Digunakan oleh uploadSelfie dan uploadTestSelfie.
  Future<String> _uploadToImgBB(File file) async {
    try {
      final String imgbbApiKey = dotenv.env['IMGBB_API_KEY'] ?? '';
      if (imgbbApiKey.isEmpty) {
        print('Error: IMGBB_API_KEY tidak ditemukan di .env');
        return '';
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey'),
      );

      request.files.add(await http.MultipartFile.fromPath('image', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResult = json.decode(responseData);

        // Mengembalikan URL publik dari gambar yang baru diupload
        return jsonResult['data']['url'];
      } else {
        print('Gagal upload ke ImgBB: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      print('Error uploading to ImgBB: $e');
      return '';
    }
  }

  // =======================================================
  // 1. BAGIAN REGISTER / AUTHENTICATION
  // =======================================================

  Future<String> uploadSelfie(File file, String uid) async {
    return await _uploadToImgBB(file);
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
    return await _uploadToImgBB(file);
  }
}