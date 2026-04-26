import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart'; // Buat UI login basic yang mengarah ke HomeScreen
import 'screens/selfie_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pastikan kamu sudah menaruh google-services.json (Android) / Info.plist (iOS)
  // await Firebase.initializeApp(); 
  runApp(const SadarDiriApp());
}

class SadarDiriApp extends StatelessWidget {
  const SadarDiriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SadarDiri',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: SelfieScreen(), // Arahkan ke AuthService untuk cek status login
    );
  }
}