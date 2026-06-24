import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceAiService {
  static late Interpreter _interpreter;
  static final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
  );
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite');
      _isInitialized = true;
    } catch (e) {
      debugPrint("Gagal memuat model TFLite: $e");
    }
  }

  // Fungsi mengubah gambar wajah menjadi Vektor Numerik (Embedding)
  static Future<List<double>?> getFaceEmbedding(File imageFile) async {
    await initialize();

    // 1. Deteksi letak wajah menggunakan ML Kit
    final inputImage = InputImage.fromFile(imageFile);
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null; // Tidak ada wajah terdeteksi

    final face = faces.first;

    // 2. Baca gambar ke format Image package
    final imageBytes = await imageFile.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return null;

    // 3. Crop bagian wajah sesuai Bounding Box
    img.Image croppedFace = img.copyCrop(
      originalImage,
      x: max(0, face.boundingBox.left.toInt()),
      y: max(0, face.boundingBox.top.toInt()),
      width: face.boundingBox.width.toInt(),
      height: face.boundingBox.height.toInt(),
    );

    // 4. Resize ke 112x112 (Syarat input MobileFaceNet)
    img.Image resizedFace = img.copyResize(croppedFace, width: 112, height: 112);

    // 5. Konversi pixel RGB ke Matrix float32 dan normalisasi
    List inputMatrix = List.generate(1, (i) => List.generate(112, (y) => List.generate(112, (x) {
      final pixel = resizedFace.getPixel(x, y);
      return [
        (pixel.r - 127.5) / 127.5,
        (pixel.g - 127.5) / 127.5,
        (pixel.b - 127.5) / 127.5
      ];
    })));

    // 6. Jalankan Interpreter TFLite (Output: Vektor 1x192)
    var outputMatrix = List.generate(1, (index) => List.filled(192, 0.0));
    _interpreter.run(inputMatrix, outputMatrix);

    return List<double>.from(outputMatrix[0]);
  }

  // Fungsi Kalkulasi Jarak Kemiripan
  static double calculateEuclideanDistance(List<double> e1, List<double> e2) {
    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }
}