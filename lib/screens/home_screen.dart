import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/local_db_service.dart';
import '../models/test_result_model.dart';
import 'selfie_screen.dart';
import 'login_screen.dart'; // Pastikan file ini ada sesuai struktur sebelumnya

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalDbService _localDbService = LocalDbService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  late Future<List<TestResult>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Memuat riwayat tes dari SQLite berdasarkan userId saat ini
  void _loadHistory() {
    if (currentUser != null) {
      _historyFuture = _localDbService.getResults(currentUser!.uid);
    } else {
      _historyFuture = Future.value([]);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SadarDiri Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Welcome & Action Section ---
            Card(
              elevation: 4,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Halo, ${currentUser?.email ?? 'Pengguna'}!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sudahkah kamu mengecek kondisi mentalmu hari ini?',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      icon: const Icon(Icons.camera_front),
                      label: const Text('Mulai Skrining Sekarang'),
                      onPressed: () {
                        // Navigasi ke layar Selfie Verifikasi sebelum tes
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelfieScreen(),
                          ),
                        ).then((_) {
                          // Refresh history setelah kembali dari tes
                          setState(() {
                            _loadHistory();
                          });
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- History Section ---
            Text(
              'Riwayat Skrining',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: FutureBuilder<List<TestResult>>(
                future: _historyFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Belum ada riwayat tes. Yuk mulai skrining pertamamu!'),
                    );
                  }

                  final results = snapshot.data!;
                  
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final result = results[index];
                      // Format tanggal sederhana
                      final dateStr = '${result.date.day}/${result.date.month}/${result.date.year}';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: result.score > 70 
                                ? Colors.red.shade100 
                                : Colors.green.shade100,
                            child: Icon(
                              Icons.psychology,
                              color: result.score > 70 ? Colors.red : Colors.green,
                            ),
                          ),
                          title: Text('Skor Skrining: ${result.score}'),
                          subtitle: Text('Tanggal: $dateStr'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                           // TODO: Buat navigasi ke DetailResultScreen jika ingin melihat detail jawaban
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Membuka detail untuk ID: ${result.id}')),
                            );
                          },
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
}