import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/test_result_model.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/test_result_card.dart';
import '../history/history_screen.dart';
import '../settings/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void navigateToSelfie() {
    Navigator.pushNamed(context, 'selfie'); // Rute untuk Skrining DASS-21
  }

  void navigateToMoodTracker() {
    // Pastikan Anda mendaftarkan rute 'mood_tracker' di main.dart nanti
    Navigator.pushNamed(context, 'mood_tracker');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('SadarDiri'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER / GREETING ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: cs.primary,
                      child: Icon(Icons.person, size: 35, color: cs.onPrimary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat datang,',
                            style: TextStyle(
                                fontSize: 14,
                                color: cs.onPrimaryContainer.withValues(alpha: 0.8)),
                          ),
                          Text(
                            viewModel.currentUser?.email?.split('@').first ??
                                "Pengguna",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: cs.onPrimaryContainer,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- FITUR UTAMA (GRID / CARDS) ---
              Text(
                'Layanan Kami',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFeatureCard(
                      context: context,
                      title: 'Skrining\nPsikologi',
                      icon: Icons.assignment_turned_in,
                      color: cs.primary,
                      onTap: navigateToSelfie,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFeatureCard(
                      context: context,
                      title: 'Mood Tracker\nHarian',
                      icon: Icons.mood,
                      color: Colors.orange, // Diberi warna berbeda agar menarik
                      onTap: navigateToMoodTracker,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- RIWAYAT TES ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Skrining Terakhir',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      );
                    },
                    child: Text('Lihat Semua',
                        style: TextStyle(color: cs.primary)),
                  )
                ],
              ),
              const SizedBox(height: 12),

              StreamBuilder<List<TestResult>>(
                stream: viewModel.testHistoryStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(color: cs.primary));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final results = snapshot.data ?? [];

                  if (results.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.history_toggle_off,
                              size: 50, color: cs.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada riwayat tes.\nYuk, mulai skrining pertamamu!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: results.length > 3 ? 3 : results.length, // Batasi 3 terbaru di Home
                    itemBuilder: (context, index) {
                      return TestResultCard(result: results[index]);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Kustom untuk Kartu Menu Utama
  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          // Glow halus mengikuti warna kartu (aksen / oranye)
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}