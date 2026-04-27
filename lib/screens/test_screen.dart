import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/question_model.dart';
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

  // Menggunakan Model Question agar rapi dan tidak perlu list terpisah
  final List<Question> _questions = [
    Question(id: 1, text: "Menjadi marah karena hal-hal kecil/sepele", category: "stress"),
    Question(id: 2, text: "Mulut terasa kering", category: "anxiety"),
    Question(id: 3, text: "Tidak dapat melihat hal yang positif dari suatu kejadian", category: "depression"),
    Question(id: 4, text: "Merasakan gangguan dalam bernapas (napas cepat, sulit bernapas)", category: "anxiety"),
    Question(id: 5, text: "Merasa sepertinya tidak kuat lagi untuk melakukan suatu kegiatan", category: "depression"),
    Question(id: 6, text: "Cenderung bereaksi berlebihan pada situasi", category: "stress"),
    Question(id: 7, text: "Kelemahan pada anggota tubuh", category: "anxiety"),
    Question(id: 8, text: "Kesulitan untuk relaksasi/bersantai", category: "stress"),
    Question(id: 9, text: "Cemas yang berlebihan dalam suatu situasi namun bisa lega jika hal/situasi itu berakhir", category: "anxiety"),
    Question(id: 10, text: "Pesimis", category: "depression"),
    Question(id: 11, text: "Mudah merasa kesal", category: "stress"),
    Question(id: 12, text: "Merasa banyak menghabiskan energi karena cemas", category: "stress"),
    Question(id: 13, text: "Merasa sedih dan depresi", category: "depression"),
    Question(id: 14, text: "Tidak sabaran", category: "stress"),
    Question(id: 15, text: "Kelelahan", category: "anxiety"),
    Question(id: 16, text: "Kehilangan minat pada banyak hal (misal: makan, ambulasi, sosialisasi)", category: "depression"),
    Question(id: 17, text: "Merasa diri tidak layak", category: "depression"),
    Question(id: 18, text: "Mudah tersinggung", category: "stress"),
    Question(id: 19, text: "Berkeringat (misal: tangan berkeringat) tanpa stimulasi oleh cuaca maupun latihan fisik", category: "anxiety"),
    Question(id: 20, text: "Ketakutan tanpa alasan yang jelas", category: "anxiety"),
    Question(id: 21, text: "Merasa hidup tidak berharga", category: "depression"),
    Question(id: 22, text: "Sulit untuk beristirahat", category: "stress"),
    Question(id: 23, text: "Kesulitan dalam menelan", category: "anxiety"),
    Question(id: 24, text: "Tidak dapat menikmati hal-hal yang saya lakukan", category: "depression"),
    Question(id: 25, text: "Perubahan kegiatan jantung dan denyut nadi tanpa stimulasi oleh latihan fisik", category: "anxiety"),
    Question(id: 26, text: "Merasa hilang harapan dan putus asa", category: "depression"),
    Question(id: 27, text: "Mudah marah", category: "stress"),
    Question(id: 28, text: "Mudah panik", category: "anxiety"),
    Question(id: 29, text: "Kesulitan untuk tenang setelah sesuatu yang mengganggu", category: "stress"),
    Question(id: 30, text: "Takut diri terhambat oleh tugas-tugas yang tidak biasa dilakukan", category: "anxiety"),
    Question(id: 31, text: "Sulit untuk antusias pada banyak hal", category: "depression"),
    Question(id: 32, text: "Sulit mentoleransi gangguan-gangguan terhadap hal yang sedang dilakukan", category: "stress"),
    Question(id: 33, text: "Berada pada keadaan tegang", category: "stress"),
    Question(id: 34, text: "Merasa tidak berharga", category: "depression"),
    Question(id: 35, text: "Tidak dapat memaklumi hal apapun yang menghalangi anda untuk menyelesaikan hal yang sedang Anda lakukan", category: "stress"),
    Question(id: 36, text: "Ketakutan", category: "anxiety"),
    Question(id: 37, text: "Tidak ada harapan untuk masa depan", category: "depression"),
    Question(id: 38, text: "Merasa hidup tidak berarti", category: "depression"),
    Question(id: 39, text: "Mudah gelisah", category: "stress"),
    Question(id: 40, text: "Khawatir dengan situasi saat diri Anda mungkin menjadi panik dan mempermalukan diri sendiri", category: "anxiety"),
    Question(id: 41, text: "Gemetar", category: "anxiety"),
    Question(id: 42, text: "Sulit untuk meningkatkan inisiatif dalam melakukan sesuatu", category: "depression"),
  ];

  final List<Map<String, dynamic>> _options = [
    {'text': 'Tidak pernah', 'score': 0},
    {'text': 'Kadang-kadang', 'score': 1},
    {'text': 'Sering', 'score': 2},
    {'text': 'Hampir setiap saat', 'score': 3},
  ];

  void _answerQuestion(int score) {
    // Membaca kategori dari objek model
    String category = _questions[_currentIndex].category;

    if (category == "depression") {
      _depScore += score;
    } else if (category == "anxiety") {
      _anxScore += score;
    } else if (category == "stress") {
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

      String selfieUrl = await firebaseService.uploadSelfie(widget.selfieFile, user.uid);

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
        const SnackBar(content: Text('Skrining selesai! Hasil berhasil disimpan.')),
      );
      
      // Kirim trigger kembali agar layar sebelumnya tahu tes sudah selesai
      Navigator.pop(context, true); 

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skrining SadarDiri'),
        // Tampilan UI awal dipertahankan:
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
                  // Progress bar dipertahankan
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
                        _questions[_currentIndex].text, // Memanggil text dari model
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Styling tombol dan jarak dipertahankan sepenuhnya
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
                        onPressed: () => _answerQuestion(option['score'] as int),
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