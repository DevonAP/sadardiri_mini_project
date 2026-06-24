import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/register_viewmodel.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void navigateLogin() {
    Navigator.pushReplacementNamed(context, 'login');
  }

  Future<void> register() async {
    final viewModel = context.read<RegisterViewModel>();
    final success = await viewModel.register(
      _emailController.text,
      _passwordController.text,
    );
    
    // Jika sukses, kembali ke login atau langsung masuk ke home
    if (success && mounted) {
      // Memberitahu sistem untuk menyimpan kredensial autofill
      TextInput.finishAutofillContext();
      navigateLogin();
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Buat Akun Baru',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: cs.primary),
                    ),
                    const SizedBox(height: 32),
                    
                    // Bagian Pengambilan Selfie Referensi
                    Consumer<RegisterViewModel>(
                      builder: (context, viewModel, child) {
                        return GestureDetector(
                          onTap: viewModel.pickSelfie,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: cs.primary.withValues(alpha: 0.2),
                            backgroundImage: viewModel.selfieFile != null
                                ? FileImage(viewModel.selfieFile!)
                                : null,
                            child: viewModel.selfieFile == null
                                ? Icon(Icons.camera_alt,
                                    size: 50, color: cs.primary)
                                : null,
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 12),
                    Text('Tap untuk ambil selfie referensi',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 32),

                    // Menggunakan parameter persis seperti di custom_textfield.dart
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
                      isPassword: true,
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    const SizedBox(height: 24),
                    
                    // Menampilkan Error Code
                    Consumer<RegisterViewModel>(
                      builder: (context, viewModel, child) {
                        if (viewModel.errorCode.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              viewModel.errorCode,
                              style: TextStyle(color: cs.error),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    
                    // Tombol Register
                    Consumer<RegisterViewModel>(
                      builder: (context, viewModel, child) {
                        return CustomButton(
                          text: 'Register',
                          onPressed: register,
                          isLoading: viewModel.isLoading,
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: navigateLogin,
                          child: Text(
                            'Login',
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
      ),
    );
  }
}