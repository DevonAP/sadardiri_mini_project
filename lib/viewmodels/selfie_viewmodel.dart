import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/face_ai_service.dart';

class SelfieViewModel extends ChangeNotifier {
  // FaceAiService dalam kode Anda bersifat statis, jadi kita panggil langsung
  final ImagePicker _picker = ImagePicker();

  File? _image;
  File? get image => _image;

  bool _isVerifying = false;
  bool get isVerifying => _isVerifying;

  String _errorMessage = "";
  String get errorMessage => _errorMessage;

  // Threshold dari file asli Anda
  final double threshold = 1.0; 

  void reset() {
    _image = null;
    _isVerifying = false;
    _errorMessage = "";
    notifyListeners();
  }

  Future<void> takeSelfie() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (photo != null) {
      _image = File(photo.path);
      _errorMessage = "";
      notifyListeners();
    }
  }

  Future<bool> verifyFace(File referenceImage) async {
    if (_image == null) return false;

    _isVerifying = true;
    _errorMessage = "";
    notifyListeners();

    try {
      // 1. Ambil embedding dari foto selfie yang baru diambil
      List<double>? inputEmbedding = await FaceAiService.getFaceEmbedding(_image!);
      
      // 2. Ambil embedding dari foto referensi (yang disimpan saat register)
      List<double>? referenceEmbedding = await FaceAiService.getFaceEmbedding(referenceImage);

      if (inputEmbedding == null || referenceEmbedding == null) {
        _errorMessage = "Wajah tidak terdeteksi di salah satu foto.";
        _isVerifying = false;
        notifyListeners();
        return false;
      }

      // 3. Hitung Euclidean Distance (Logika pemanggilan AI yang Anda buat)
      double distance = 0;
      for (int i = 0; i < inputEmbedding.length; i++) {
        distance += (inputEmbedding[i] - referenceEmbedding[i]) * (inputEmbedding[i] - referenceEmbedding[i]);
      }
      distance = math.sqrt(distance); // Menggunakan Math untuk akar kuadrat

      // 4. Verifikasi dengan threshold
      bool isMatch = distance < threshold;

      if (!isMatch) {
        _errorMessage = "Wajah tidak cocok (Distance: ${distance.toStringAsFixed(2)})";
      }

      _isVerifying = false;
      notifyListeners();
      return isMatch;
    } catch (e) {
      _errorMessage = "Gagal memproses AI: $e";
      _isVerifying = false;
      notifyListeners();
      return false;
    }
  }
}