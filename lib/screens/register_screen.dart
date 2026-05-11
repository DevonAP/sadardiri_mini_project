import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/face_ai_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  File? _selfieFile;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  String _errorCode = "";

  void navigateLogin() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'login');
  }

  Future<void> _takeReferenceSelfie() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (photo != null) {
      setState(() {
        _selfieFile = File(photo.path);
      });
    }
  }

  void register() async {
    if (_selfieFile == null) {
      setState(() => _errorCode = "Selfie wajah wajib diisi untuk verifikasi!");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorCode = "";
    });

    try {
      // 1. Ekstraksi Vektor Wajah dari foto menggunakan Edge AI
      List<double>? faceEmbedding = await FaceAiService.getFaceEmbedding(_selfieFile!);
      if (faceEmbedding == null) {
        throw Exception("Wajah tidak terdeteksi di foto. Pastikan pencahayaan baik.");
      }

      // 2. Buat akun Firebase Auth
      UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // 3. Simpan data user & referensi vektor wajah ke Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
        'email': _emailController.text,
        'face_embedding': faceEmbedding, // Disimpan sebagai array numerik
        'createdAt': FieldValue.serverTimestamp(),
      });

      navigateLogin();
    } catch (e) {
      setState(() {
        _errorCode = e is FirebaseAuthException ? e.code : e.toString();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: ListView(
              children: [
                const SizedBox(height: 48),
                Icon(Icons.how_to_reg, size: 80, color: Colors.blue.shade900),
                const SizedBox(height: 24),
                
                // Area Pengambilan Selfie
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: _selfieFile != null ? FileImage(_selfieFile!) : null,
                        child: _selfieFile == null 
                            ? Icon(Icons.face, size: 50, color: Colors.blue.shade900)
                            : null,
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade900,
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          onPressed: _takeReferenceSelfie,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ambil foto wajah untuk referensi verifikasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                _errorCode != ""
                    ? Column(
                        children: [
                          Text(_errorCode, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 16)
                        ],
                      )
                    : const SizedBox.shrink(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: register,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Register', style: TextStyle(fontSize: 16)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: navigateLogin,
                      child: Text('Login', style: TextStyle(color: Colors.blue.shade900)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}