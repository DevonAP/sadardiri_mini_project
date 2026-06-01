import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/selfie_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../test/test_screen.dart'; // Untuk navigasi membawa parameter gambar

class SelfieScreen extends StatefulWidget {
  const SelfieScreen({super.key});

  @override
  State<SelfieScreen> createState() => _SelfieScreenState();
}

class _SelfieScreenState extends State<SelfieScreen> {
  @override
  void initState() {
    super.initState();
    // Reset status gambar tiap kali masuk ke halaman ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SelfieViewModel>().reset();
    });
  }

  void _verifyAndProceed() async {
    final viewModel = context.read<SelfieViewModel>();

    // Memulai verifikasi AI
    final isValid = await viewModel.verifyFace(viewModel.image!);

    if (isValid && mounted) {
      // Jika wajah cocok, navigasi ke TestScreen dengan mengirim File gambarnya
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TestScreen(selfieFile: viewModel.image!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verifikasi Wajah',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal, // Aturan warna FP
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<SelfieViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Frame Foto Profil (Bulat bertema Teal)
                  Container(
                    height: 220,
                    width: 220,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.teal, width: 3),
                    ),
                    child: viewModel.image != null
                        ? ClipOval(
                            child: Image.file(
                              viewModel.image!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.face_retouching_natural,
                            size: 100,
                            color: Colors.teal,
                          ),
                  ),
                  const SizedBox(height: 32),

                  // Teks Petunjuk
                  Text(
                    viewModel.image != null
                        ? 'Foto siap diverifikasi.'
                        : 'Sistem Edge AI akan mencocokkan wajah Anda dengan data pendaftaran.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),

                  // Teks Error AI jika ada
                  if (viewModel.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        viewModel.errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Tombol Ambil / Ulang Foto
                  CustomButton(
                    text: viewModel.image != null
                        ? 'Foto Ulang'
                        : 'Buka Kamera',
                    onPressed: viewModel.isVerifying
                        ? () {}
                        : viewModel.takeSelfie,
                    color: viewModel.image != null ? Colors.grey : Colors.teal,
                  ),

                  const SizedBox(height: 16),

                  // Tombol Verifikasi (Hanya muncul kalau gambar sudah diambil)
                  if (viewModel.image != null)
                    CustomButton(
                      text: 'Verifikasi & Mulai Tes',
                      onPressed: _verifyAndProceed,
                      isLoading: viewModel.isVerifying,
                      color: Colors.teal,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
