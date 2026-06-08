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
      return true;
    } catch (e) {
      debugPrint("Gagal menyimpan mood: $e");
      _saving = false; 
      notifyListeners();
      return false;
    }
  }
}