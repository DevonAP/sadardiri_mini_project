import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/test_result_model.dart';
import '../services/local_db_service.dart';
import '../services/firebase_service.dart';

class TestScreen extends StatefulWidget {
  final File selfieFile;

  const TestScreen({super.key, required this.selfieFile});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _currentIndex = 0;
  bool _isSubmitting = false;

  // Variabel untuk 3 kategori penilaian
  int _depScore = 0;
  int _anxScore = 0;
  int _strScore = 0;

  // Daftar nomor soal sesuai kategori (1-based index)
  final List<int> depressionQs = [
    3,
    5,
    10,
    13,
    16,
    17,
    21,
    24,
    26,
    31,
    34,
    37,
    38,
    42,
  ]; //
  final List<int> anxietyQs = [
    2,
    4,
    7,
    9,
    15,
    19,
    20,
    23,
    25,
    28,
    30,
    36,
    40,
    41,
  ]; //
  final List<int> stressQs = [
    1,
    6,
    8,
    11,
    12,
    14,
    18,
    22,
    27,
    29,
    32,
    33,
    35,
    39,
  ]; //

  final List<String> _questions = [
    "Menjadi marah karena hal-hal kecil/sepele", // 1
    "Mulut terasa kering", // 2
    "Tidak dapat melihat hal yang positif dari suatu kejadian", // 3
    "Merasakan gangguan dalam bernapas (napas cepat, sulit bernapas)", // 4
    "Merasa sepertinya tidak kuat lagi untuk melakukan suatu kegiatan", // 5
    "Cenderung bereaksi berlebihan pada situasi", // 6
    "Kelemahan pada anggota tubuh", // 7
    "Kesulitan untuk relaksasi/bersantai", // 8
    "Cemas yang berlebihan dalam suatu situasi namun bisa lega jika hal/situasi itu berakhir", // 9
    "Pesimis", // 10
    "Mudah merasa kesal", // 11
    "Merasa banyak menghabiskan energi karena cemas", // 12
    "Merasa sedih dan depresi", // 13
    "Tidak sabaran", // 14
    "Kelelahan", // 15
    "Kehilangan minat pada banyak hal (misal: makan, ambulasi, sosialisasi)", // 16
    "Merasa diri tidak layak", // 17
    "Mudah tersinggung", // 18
    "Berkeringat (misal: tangan berkeringat) tanpa stimulasi oleh cuaca maupun latihan fisik", // 19
    "Ketakutan tanpa alasan yang jelas", // 20
    "Merasa hidup tidak berharga", // 21
    "Sulit untuk beristirahat", // 22
    "Kesulitan dalam menelan", // 23
    "Tidak dapat menikmati hal-hal yang saya lakukan", // 24
    "Perubahan kegiatan jantung dan denyut nadi tanpa stimulasi oleh latihan fisik", // 25
    "Merasa hilang harapan dan putus asa", // 26
    "Mudah marah", // 27
    "Mudah panik", // 28
    "Kesulitan untuk tenang setelah sesuatu yang mengganggu", // 29
    "Takut diri terhambat oleh tugas-tugas yang tidak biasa dilakukan", // 30
    "Sulit untuk antusias pada banyak hal", // 31
    "Sulit mentoleransi gangguan-gangguan terhadap hal yang sedang dilakukan", // 32
    "Berada pada keadaan tegang", // 33
    "Merasa tidak berharga", // 34
    "Tidak dapat memaklumi hal apapun yang menghalangi anda untuk menyelesaikan hal yang sedang Anda lakukan", // 35
    "Ketakutan", // 36
    "Tidak ada harapan untuk masa depan", // 37
    "Merasa hidup tidak berarti", // 38
    "Mudah gelisah", // 39
    "Khawatir dengan situasi saat diri Anda mungkin menjadi panik dan mempermalukan diri sendiri", // 40
    "Gemetar", // 41
    "Sulit untuk meningkatkan inisiatif dalam melakukan sesuatu", // 42
  ];

  final List<Map<String, dynamic>> _options = [
    {'text': 'Tidak pernah', 'score': 0}, // [cite: 3]
    {'text': 'Kadang-kadang', 'score': 1}, // [cite: 4]
    {'text': 'Sering', 'score': 2}, // [cite: 5]
    {'text': 'Hampir setiap saat', 'score': 3}, // [cite: 6]
  ];

  void _answerQuestion(int score) {
    int currentQNum = _currentIndex + 1;

    // Klasifikasi bobot skor ke aspek yang tepat
    if (depressionQs.contains(currentQNum)) {
      _depScore += score;
    } else if (anxietyQs.contains(currentQNum)) {
      _anxScore += score;
    } else if (stressQs.contains(currentQNum)) {
      _strScore += score;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _submitTest();
    }
  }

  Future<void> _submitTest() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User belum login");

      final firebaseService = FirebaseService();
      final localDbService = LocalDbService();

      String selfieUrl = await firebaseService.uploadSelfie(
        widget.selfieFile,
        user.uid,
      );

      final result = TestResult(
        userId: user.uid,
        depressionScore: _depScore,
        anxietyScore: _anxScore,
        stressScore: _strScore,
        selfieUrl: selfieUrl,
        date: DateTime.now(),
      );

      await localDbService.insertResult(result);
      await firebaseService.backupResult(result);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Skrining selesai! Hasil berhasil disimpan.'),
        ),
      );
      // Kembali ke HomeScreen
      Navigator.pop(context, true); // true untuk menandakan ada update history
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // ... (bagian build UI sama seperti sebelumnya) ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skrining SadarDiri'),
        automaticallyImplyLeading: !_isSubmitting,
      ),
      body: _isSubmitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Menyimpan hasil dan mengunggah verifikasi...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / _questions.length,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pertanyaan ${_currentIndex + 1} dari ${_questions.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Center(
                      child: Text(
                        _questions[_currentIndex],
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  ..._options.map((option) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            _answerQuestion(option['score'] as int),
                        child: Text(
                          option['text'] as String,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
