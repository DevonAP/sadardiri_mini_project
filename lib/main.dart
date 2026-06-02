import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'services/notification_service.dart';
import 'firebase_options.dart';

// ViewModels (Nanti di-uncomment setelah file-nya dibuat)
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/register_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/test_viewmodel.dart'; 
import 'viewmodels/selfie_viewmodel.dart'; // Import SelfieViewModel
// Views
import 'views/login/login_screen.dart';
import 'views/register/register_screen.dart';
import 'views/home/home_screen.dart';
import 'views/selfie/selfie_screen.dart'; // Import SelfieScreen
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await NotificationService.initialize(); // Inisialisasi notifikasi

  runApp(const SadarDiriApp());
}

class SadarDiriApp extends StatelessWidget {
  const SadarDiriApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider digunakan untuk mendaftarkan semua ViewModel
    return MultiProvider(
      providers: [
        // Nanti kita daftarkan viewmodel di sini, contohnya:
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => TestViewModel()),
        ChangeNotifierProvider(create: (_) => SelfieViewModel()), // ViewModel untuk SelfieScreen
      ],
      child: MaterialApp(
        title: 'SadarDiri',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        initialRoute: 'login', 
        routes: {
          'home': (context) => const HomeScreen(),
          'login': (context) => const LoginScreen(),
          'register': (context) => const RegisterScreen(),
          'selfie': (context) => const SelfieScreen(), // Nanti kita navigasi ke sini dengan parameter
        },
      ),
    );
  }
}