import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/test_result_model.dart';
import '../services/firebase_service.dart';

class HomeViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // Mendapatkan stream riwayat tes dari FirebaseService
  Stream<List<TestResult>> get testHistoryStream {
    if (currentUser == null) {
      return Stream.value([]);
    }
    return _firebaseService.getTestHistory(currentUser!.uid);
  }

  // Logika pengelompokan tingkat Depresi (pindahan dari view lama)
  String getDepressionLevel(int score) {
    if (score <= 9) return "Normal";
    if (score <= 13) return "Ringan";
    if (score <= 20) return "Sedang";
    if (score <= 27) return "Parah";
    return "Sangat Parah";
  }

  // Logika pengelompokan tingkat Kecemasan (pindahan dari view lama)
  String getAnxietyLevel(int score) {
    if (score <= 7) return "Normal";
    if (score <= 9) return "Ringan";
    if (score <= 14) return "Sedang";
    if (score <= 19) return "Parah";
    return "Sangat Parah";
  }

  // Logika pengelompokan tingkat Stres (pindahan dari view lama)
  String getStressLevel(int score) {
    if (score <= 14) return "Normal";
    if (score <= 18) return "Ringan";
    if (score <= 25) return "Sedang";
    if (score <= 33) return "Parah";
    return "Sangat Parah";
  }

  // Logika penentuan warna indikator berdasarkan tingkat keparahan
  Color getLevelColor(String level) {
    switch (level) {
      case "Normal":
        return Colors.green;
      case "Ringan":
        return Colors.amber;
      case "Sedang":
        return Colors.orange;
      case "Parah":
        return Colors.red;
      case "Sangat Parah":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Fungsi Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}