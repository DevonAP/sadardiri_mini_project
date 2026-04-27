import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan import ini
import '../services/firebase_service.dart'; // Ganti dari local_db_service
import '../models/test_result_model.dart';
import 'selfie_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService =
      FirebaseService(); // Gunakan FirebaseService
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Logika Klasifikasi (Tetap sama seperti sebelumnya)
  String getDepressionLevel(int score) {
    if (score <= 9) return "Normal";
    if (score <= 13) return "Ringan";
    if (score <= 20) return "Sedang";
    if (score <= 27) return "Parah";
    return "Sangat Parah";
  }

  String getAnxietyLevel(int score) {
    if (score <= 7) return "Normal";
    if (score <= 9) return "Ringan";
    if (score <= 14) return "Sedang";
    if (score <= 19) return "Parah";
    return "Sangat Parah";
  }

  String getStressLevel(int score) {
    if (score <= 14) return "Normal";
    if (score <= 18) return "Ringan";
    if (score <= 25) return "Sedang";
    if (score <= 33) return "Parah";
    return "Sangat Parah";
  }

  Color getLevelColor(String level) {
    switch (level) {
      case "Normal":
        return Colors.green;
      case "Ringan":
        return Colors.yellow.shade700;
      case "Sedang":
        return Colors.orange;
      case "Parah":
        return Colors.deepOrange;
      case "Sangat Parah":
        return Colors.red;
      default:
        return Colors.grey;
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
          IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.camera_front),
                      label: const Text('Mulai Skrining Sekarang'),
                      onPressed: () {
                        // Tidak perlu await atau .then() lagi karena StreamBuilder otomatis mendeteksi perubahan di Firebase!
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelfieScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Riwayat Skrining',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              // --- PENGGUNAAN STREAMBUILDER ---
              child: StreamBuilder<QuerySnapshot>(
                // Memanggil fungsi stream yang baru dibuat
                stream: currentUser != null
                    ? _firebaseService.getResultsStream(currentUser!.uid)
                    : const Stream.empty(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Belum ada riwayat tes.'));
                  }

                  // Mengambil data docs seperti contoh di GitHub mu
                  List<DocumentSnapshot> resultsList = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: resultsList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = resultsList[index];
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;

                      // Konversi data Map dari Firestore kembali menjadi model TestResult
                      TestResult result = TestResult.fromMap(data);

                      final dateStr =
                          '${result.date.day}/${result.date.month}/${result.date.year}';

                      String depLvl = getDepressionLevel(
                        result.depressionScore,
                      );
                      String anxLvl = getAnxietyLevel(result.anxietyScore);
                      String strLvl = getStressLevel(result.stressScore);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hasil Tes - $dateStr',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildScoreChip(
                                    'Depresi',
                                    depLvl,
                                    getLevelColor(depLvl),
                                  ),
                                  _buildScoreChip(
                                    'Cemas',
                                    anxLvl,
                                    getLevelColor(anxLvl),
                                  ),
                                  _buildScoreChip(
                                    'Stres',
                                    strLvl,
                                    getLevelColor(strLvl),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
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
