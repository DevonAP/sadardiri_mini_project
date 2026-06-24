import 'package:flutter/material.dart';
import '../models/mood_log.dart';
import '../services/mood_service.dart';

class MoodViewModel extends ChangeNotifier {
  // Enkapsulasi variabel state
  int _mood = 3; // Default: Netral (3)
  int get mood => _mood;

  String _note = '';
  String get note => _note;

  bool _saving = false;
  bool get saving => _saving;

  // State untuk riwayat
  List<MoodLog> _moodLogs = [];
  List<MoodLog> get moodLogs => _moodLogs;

  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;

  String _feedbackMessage = "Belum ada data yang cukup untuk dianalisis.";
  String get feedbackMessage => _feedbackMessage;

  void setMood(int m) { 
    _mood = m; 
    notifyListeners(); 
  }
  
  void setNote(String n) { 
    _note = n; 
  }

  // Mengubah menjadi return bool agar UI tahu proses berhasil
  Future<bool> save() async {
    _saving = true; 
    notifyListeners();
    
    try {
      final log = MoodLog(timestamp: DateTime.now(), mood: _mood, note: _note);
      await MoodService.instance.addMood(log);
      await MoodService.instance.syncPendingToFirestore();
      
      _saving = false; 
      notifyListeners();
      
      // Refresh riwayat setelah menyimpan
      await loadMoodHistory();
      
      return true;
    } catch (e) {
      debugPrint("Gagal menyimpan mood: $e");
      _saving = false; 
      notifyListeners();
      return false;
    }
  }

  // Mengambil riwayat mood 7 hari terakhir
  Future<void> loadMoodHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      
      _moodLogs = await MoodService.instance.getMoodLogs(from: sevenDaysAgo);
      _generateFeedback();
    } catch (e) {
      debugPrint("Gagal memuat riwayat mood: $e");
    }

    _isLoadingHistory = false;
    notifyListeners();
  }

  // Fungsi untuk menganalisis data dan menghasilkan kalimat balasan cerdas
  void _generateFeedback() {
    if (_moodLogs.isEmpty) {
      _feedbackMessage = "Belum ada catatan mood minggu ini. Yuk, mulai isi jurnalmu!";
      return;
    }

    // Hitung rata-rata mood
    double totalMood = 0;
    String allNotes = "";

    for (var log in _moodLogs) {
      totalMood += log.mood;
      if (log.note != null) {
        allNotes += "${log.note!.toLowerCase()} ";
      }
    }

    double avgMood = totalMood / _moodLogs.length;

    // Logika Template AI Sederhana
    String baseMessage = "";
    if (avgMood >= 4) {
      baseMessage = "Wah, rata-rata mood kamu sangat baik minggu ini! 🌟 Pertahankan energi positifmu.";
    } else if (avgMood <= 2.5) {
      baseMessage = "Sepertinya akhir-akhir ini cukup berat buatmu ya? 🫂 Ingatlah untuk selalu menyayangi dirimu sendiri. Jangan ragu istirahat atau cerita ke orang terdekat.";
    } else {
      baseMessage = "Mood kamu terpantau stabil minggu ini. Jangan lupa untuk meluangkan waktu bersantai ya! ☕";
    }

    // Deteksi Kata Kunci dalam catatan
    String keywordInsight = "";
    if (allNotes.contains("tugas") || allNotes.contains("kerja") || allNotes.contains("ujian") || allNotes.contains("deadline")) {
      keywordInsight = "\n\n💡 Insight: Saya melihat kamu sering membahas urusan pekerjaan atau tugas. Pastikan kamu mengambil jeda istirahat dan jangan memaksakan diri terlalu keras.";
    } else if (allNotes.contains("keluarga") || allNotes.contains("teman") || allNotes.contains("pacar")) {
      keywordInsight = "\n\n💡 Insight: Sepertinya interaksi sosial sedang banyak mewarnai harimu. Bersosialisasi itu penting, tapi ingat batas energi sosialmu juga ya!";
    }

    _feedbackMessage = baseMessage + keywordInsight;
  }
}