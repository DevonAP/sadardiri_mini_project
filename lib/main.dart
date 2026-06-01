import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Import Provider
// import 'services/notification_service.dart';
import 'firebase_options.dart';

// ViewModels (Nanti di-uncomment setelah file-nya dibuat)
// import 'viewmodels/login_viewmodel.dart';

// Views
import 'views/login/login_screen.dart';
import 'views/register/register_screen.dart';
import 'views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        // ChangeNotifierProvider(create: (_) => LoginViewModel()),
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
        },
      ),
    );
  }
}