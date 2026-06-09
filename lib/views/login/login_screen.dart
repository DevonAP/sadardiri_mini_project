import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void navigateRegister() {
    Navigator.pushReplacementNamed(context, 'register');
  }

  void navigateHome() {
    Navigator.pushReplacementNamed(context, 'home');
  }

  Future<void> signIn() async {
    final viewModel = context.read<LoginViewModel>();
    final success = await viewModel.signIn(
      _emailController.text,
      _passwordController.text,
    );
    
    if (success && mounted) {
      // Memberitahu sistem untuk menyimpan kredensial autofill
      TextInput.finishAutofillContext();
      navigateHome();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: AutofillGroup(
              child: ListView(
                shrinkWrap: true,
                children: [
                  const SizedBox(height: 48),
                  // Icon utama mengikuti warna aksen aktif
                  Icon(Icons.lock_outline, size: 100, color: cs.primary),
                  const SizedBox(height: 48),
                  
                  // Menggunakan CustomTextField sesuai dengan parameter aslinya
                  CustomTextField(
                    label: 'Email',
                    hintText: 'Masukkan email Anda',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Password',
                    hintText: 'Masukkan password Anda',
                    controller: _passwordController,
                    isPassword: true, // Parameter penanda password terenkripsi
                    autofillHints: const [AutofillHints.password],
                  ),
                  const SizedBox(height: 24),
                  
                  // Menampilkan teks error jika login gagal
                  Consumer<LoginViewModel>(
                    builder: (context, viewModel, child) {
                      if (viewModel.errorCode.isNotEmpty) {
                        return Column(
                          children: [
                            Text(
                              viewModel.errorCode,
                              style: TextStyle(color: cs.error),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24)
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  // Menggunakan CustomButton sesuai dengan parameter aslinya
                  Consumer<LoginViewModel>(
                    builder: (context, viewModel, child) {
                      return CustomButton(
                        text: 'Login',
                        onPressed: signIn,
                        isLoading: viewModel.isLoading, // State loading langsung dikontrol widget kustom Anda
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: navigateRegister,
                        child: Text(
                          'Register',
                          style: TextStyle(
                              color: cs.primary, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}