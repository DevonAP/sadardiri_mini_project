import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/test_result_model.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  void navigateToSelfie() {
    Navigator.pushNamed(context, 'selfie');
  }

  void navigateToLogin() {
    Navigator.pushReplacementNamed(context, 'login');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<HomeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SadarDiri - Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal, // Tema warna utama Teal
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await viewModel.signOut();
              if (mounted) navigateToLogin();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sapaan Pengguna
            Text(
              'Halo, ${viewModel.currentUser?.email ?? "Pengguna"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pantau kesehatan mentalmu secara berkala di sini.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Tombol Mulai Tes (Menggunakan CustomButton wajib bertema Teal)
            CustomButton(
              text: 'Mulai Tes Baru',
              onPressed: navigateToSelfie,
              color: Colors.teal,
            ),
            const SizedBox(height: 32),

            const Text(
              'Riwayat Tes Screening',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 12),

            // Membangun daftar riwayat tes menggunakan Stream dari ViewModel
            Expanded(
              child: StreamBuilder<List<TestResult>>(
                stream: viewModel.testHistoryStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.teal));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                  }

                  final results = snapshot.data ?? [];

                  if (results.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada riwayat tes.\nSilakan klik tombol di atas untuk memulai screening.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final res = results[index];
                      
                      // Mengambil klasifikasi tingkat keparahan dari ViewModel
                      final depLvl = viewModel.getDepressionLevel(res.depressionScore);
                      final anxLvl = viewModel.getAnxietyLevel(res.anxietyScore);
                      final strLvl = viewModel.getStressLevel(res.stressScore);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal Tes: ${res.date.toLocal().toString().substring(0, 16)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildScoreChip(
                                    'Depresi',
                                    depLvl,
                                    viewModel.getLevelColor(depLvl),
                                  ),
                                  _buildScoreChip(
                                    'Cemas',
                                    anxLvl,
                                    viewModel.getLevelColor(anxLvl),
                                  ),
                                  _buildScoreChip(
                                    'Stres',
                                    strLvl,
                                    viewModel.getLevelColor(strLvl),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreChip(String label, String level, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 1.2),
          ),
          child: Text(
            level,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}