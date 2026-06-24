import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorCode = "";
  String get errorCode => _errorCode;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorCode = "";
    notifyListeners();

    try {
      await _authService.signInWithEmailAndPassword(email, password);
      _isLoading = false;
      notifyListeners();
      return true; // Login sukses
    } on FirebaseAuthException catch (e) {
      _errorCode = e.code;
      _isLoading = false;
      notifyListeners();
      return false; // Login gagal
    }
  }
}