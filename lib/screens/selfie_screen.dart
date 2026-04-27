import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'test_screen.dart';

class SelfieScreen extends StatefulWidget {
  @override
  _SelfieScreenState createState() => _SelfieScreenState();
}

class _SelfieScreenState extends State<SelfieScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verifikasi Identitas')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(_image!, height: 300)
                : Text('Ambil selfie untuk memulai skrining mental health.'),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Ambil Selfie'),
              onPressed: _takeSelfie,
            ),
            if (_image != null)
              ElevatedButton(
                child: Text('Lanjutkan ke Tes'),
                onPressed: () {
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => TestScreen(selfieFile: _image!),
                  //   ),
                  // );
                },
              ),
          ],
        ),
      ),
    );
  }
}
