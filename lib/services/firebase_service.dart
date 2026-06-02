import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
        debugPrint('Error: IMGBB_API_KEY tidak ditemukan di .env');
        debugPrint('dotenv keys yang tersedia: ${dotenv.env.keys.toList()}');
        return '';
      }

      debugPrint('Uploading file ke ImgBB: ${file.path}');
      debugPrint('File exists: ${await file.exists()}');
      debugPrint('File size: ${await file.length()} bytes');

      // Baca file sebagai bytes lalu encode ke base64
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Gunakan POST biasa dengan base64 encoding (lebih reliable dari MultipartRequest)
      var response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload'),
        body: {
          'key': imgbbApiKey,
          'image': base64Image,
        },
      );

      debugPrint('ImgBB Response status: ${response.statusCode}');
      debugPrint('ImgBB Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);

        if (jsonResult['success'] == true) {
          final url = jsonResult['data']['url'] as String;
          debugPrint('Upload berhasil! URL: $url');
          return url;
        } else {
          debugPrint('ImgBB mengembalikan success=false: ${response.body}');
          return '';
        }
      } else {
        debugPrint('Gagal upload ke ImgBB: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return '';
      }
    } catch (e, stackTrace) {
      debugPrint('Error uploading to ImgBB: $e');
      debugPrint('StackTrace: $stackTrace');
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
        .collection('test_results')
        .where('userId', isEqualTo: uid)
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

  /// Menyimpan hasil tes ke collection 'test_results'
  Future<void> saveTestResult(TestResult result) async {
    await _firestore
        .collection('test_results')
        .add(result.toMap());
  }

  Future<String> uploadTestSelfie(File file, String uid) async {
    return await _uploadToImgBB(file);
  }
}