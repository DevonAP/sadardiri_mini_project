import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/face_ai_service.dart';
import 'test_screen.dart';

class SelfieScreen extends StatefulWidget {
  const SelfieScreen({super.key});

  @override
  _SelfieScreenState createState() => _SelfieScreenState();
}

class _SelfieScreenState extends State<SelfieScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isVerifying = false;

  // Threshold Euclidean: Biasanya di bawah 1.0 (MobileFaceNet) berarti orang yang sama.
  // Angka ini bisa kamu tuning (0.8 - 1.2) tergantung akurasi model.
  final double threshold = 1.0;

  Future<void> _takeSelfie() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

  Future<void> _verifyFaceAndProceed() async {
    setState(() => _isVerifying = true);

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User tidak ditemukan");

      // 1. Ekstraksi Vektor Wajah Ujian
      List<double>? testEmbedding = await FaceAiService.getFaceEmbedding(_image!);
      if (testEmbedding == null) {
        throw Exception("Wajah tidak terdeteksi. Silakan foto ulang dengan jelas.");
      }

      // 2. Ambil Vektor Wajah Referensi dari Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userDoc.exists || userDoc.data() == null) {
        throw Exception("Data wajah referensi tidak ditemukan di database.");
      }
      
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<dynamic> rawList = userData['face_embedding'];
      List<double> refEmbedding = rawList.cast<double>();

      // 3. Bandingkan!
      double distance = FaceAiService.calculateEuclideanDistance(testEmbedding, refEmbedding);
      print("Jarak Euclidean: $distance");

      if (distance < threshold) {
        // WAJAH COCOK -> Lanjut Tes
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TestScreen(selfieFile: _image!)),
        );
      } else {
        throw Exception("Verifikasi Gagal! Wajah tidak cocok dengan identitas akun (Distance: ${distance.toStringAsFixed(2)}).");
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi AI')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_image!, height: 300, fit: BoxFit.cover),
                    )
                  : Icon(Icons.face_retouching_natural, size: 100, color: Colors.blue.shade900),
              
              const SizedBox(height: 24),
              Text(
                _image != null 
                  ? 'Foto siap diverifikasi.' 
                  : 'Sistem Edge AI akan mencocokkan wajah Anda dengan data pendaftaran.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: Text(_image != null ? 'Foto Ulang' : 'Buka Kamera'),
                onPressed: _isVerifying ? null : _takeSelfie,
              ),
              
              const SizedBox(height: 16),
              if (_image != null)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _isVerifying ? null : _verifyFaceAndProceed,
                  child: _isVerifying 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Verifikasi & Mulai Tes'),
                )
            ],
          ),
        ),
      ),
    );
  }
}