import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/test_viewmodel.dart';
import '../../widgets/custom_button.dart';

class TestScreen extends StatefulWidget {
  final File selfieFile; // File dikirim dari SelfieScreen (Edge AI)

  const TestScreen({super.key, required this.selfieFile});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  void initState() {
    super.initState();
    // Memastikan ViewModel di-reset skor dan index-nya tiap kali masuk screen ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TestViewModel>().resetTest();
    });
  }

  void _handleAnswer(int score) async {
    final viewModel = context.read<TestViewModel>();
    
    // Kirim skor jawaban dan file selfie untuk di-upload otomatis di akhir tes
    final isFinished = await viewModel.answerQuestion(score, widget.selfieFile);

    if (isFinished && mounted) {
      // Jika berhasil di-submit, kembali ke Home
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tes berhasil diselesaikan dan disimpan!'),
          backgroundColor: Colors.teal,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skrining Psikologi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<TestViewModel>(
        builder: (context, viewModel, child) {
          // Tampilan loading saat mengunggah skor dan gambar di akhir tes
          if (viewModel.isSubmitting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.teal),
                  SizedBox(height: 16),
                  Text("Menyimpan hasil tes & memproses foto..."),
                ],
              ),
            );
          }

          // Mendapatkan objek pertanyaan saat ini
          final question = viewModel.questions[viewModel.currentIndex];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Indikator Progres
                Text(
                  'Pertanyaan ${viewModel.currentIndex + 1} / ${viewModel.questions.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (viewModel.currentIndex + 1) / viewModel.questions.length,
                  backgroundColor: Colors.teal.withOpacity(0.2),
                  color: Colors.teal,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 40),
                
                // Teks Pertanyaan
                Expanded(
                  child: Center(
                    child: Text(
                      question.text,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                // Pilihan Jawaban (Mapping menjadi CustomButton bertema Teal)
                ...viewModel.options.map((option) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: CustomButton(
                      text: option['text'] as String,
                      color: Colors.teal,
                      onPressed: () => _handleAnswer(option['score'] as int),
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}