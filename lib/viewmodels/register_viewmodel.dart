import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorCode = "";
  String get errorCode => _errorCode;

  File? _selfieFile;
  File? get selfieFile => _selfieFile;

  // Fungsi mengambil foto dari kamera depan
  Future<void> pickSelfie() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (photo != null) {
      _selfieFile = File(photo.path);
      notifyListeners();
    }
  }

  // Fungsi utama register
  Future<bool> register(String email, String password) async {
    if (_selfieFile == null) {
      _errorCode = "Selfie referensi wajib diisi.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorCode = "";
    notifyListeners();

    try {
      // 1. Buat akun di Firebase Auth
      UserCredential cred = await _authService.registerWithEmailAndPassword(email, password);
      String uid = cred.user!.uid;

      // 2. Upload Selfie ke Firebase Storage (Bukan ImgBB lagi)
      String photoUrl = await _firebaseService.uploadSelfie(_selfieFile!, uid);

      // 3. Simpan data referensi ke Firestore
      await _firebaseService.saveUserData(uid, {
        'email': email,
        'selfieUrl': photoUrl,
        'createdAt': DateTime.now().toIso8601String(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorCode = e.message ?? e.code;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorCode = "Terjadi kesalahan: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}