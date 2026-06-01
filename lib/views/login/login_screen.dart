import 'package:flutter/material.dart';
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 48),
                // Icon utama bertema Teal sesuai aturan project
                const Icon(Icons.lock_outline, size: 100, color: Colors.teal),
                const SizedBox(height: 48),
                
                // Menggunakan CustomTextField sesuai dengan parameter aslinya
                CustomTextField(
                  label: 'Email',
                  hintText: 'Masukkan email Anda',
                  controller: _emailController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Password',
                  hintText: 'Masukkan password Anda',
                  controller: _passwordController,
                  isPassword: true, // Parameter penanda password terenkripsi
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
                            style: const TextStyle(color: Colors.red),
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
                      child: const Text(
                        'Register',
                        style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
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