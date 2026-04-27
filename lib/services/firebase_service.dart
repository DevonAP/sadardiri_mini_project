import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/test_result_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadSelfie(File image, String userId) async {
    try {
      const String imgbbApiKey = '2d90e01b9b82adfd0e3958d1d676aa40';
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey'),
      );

      request.files.add(await http.MultipartFile.fromPath('image', image.path));

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

  Stream<QuerySnapshot> getResultsStream(String userId) {
    return _firestore
        .collection('test_results')
        .where('userId', isEqualTo: userId)
        // .orderBy('date', descending: true) // Aktifkan ini jika ingin diurutkan dari yang terbaru (butuh Indexing di Firebase Console)
        .snapshots();
  }
}
