import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'firebase_options.dart';

import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/register_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/test_viewmodel.dart';
import 'viewmodels/selfie_viewmodel.dart';
import 'viewmodels/mood_viewmodel.dart';

import 'views/login/login_screen.dart';
import 'views/register/register_screen.dart';
import 'views/home/home_screen.dart';
import 'views/selfie/selfie_screen.dart';
import 'views/mood_checkin/mood_checkin_screen.dart';

import 'services/mood_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env").catchError((e) {
    debugPrint('Warning: Gagal load .env file: $e');
  });
  debugPrint('dotenv loaded keys: ${dotenv.env.keys.toList()}');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MoodService.instance.init();
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic',
        channelDescription: 'Mood reminders',
        importance: NotificationImportance.High,
      )
    ],
  );

  runApp(const SadarDiriApp());
}

class SadarDiriApp extends StatelessWidget {
  const SadarDiriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => TestViewModel()),
        ChangeNotifierProvider(create: (_) => SelfieViewModel()),
        ChangeNotifierProvider(create: (_) => MoodViewModel()),
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
          'selfie': (context) => const SelfieScreen(),
          'mood_tracker': (_) => const MoodCheckinScreen(),
        },
      ),
    );
  }
}