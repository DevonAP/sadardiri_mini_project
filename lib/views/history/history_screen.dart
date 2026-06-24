import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/test_result_model.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/test_result_card.dart';

/// Menampilkan seluruh riwayat hasil skrining (tanpa batas 3 seperti di Home).
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Skrining'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<TestResult>>(
          stream: viewModel.testHistoryStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: cs.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final results = snapshot.data ?? [];

            if (results.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_toggle_off,
                          size: 64, color: cs.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada riwayat tes.\nYuk, mulai skrining pertamamu!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return TestResultCard(result: results[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
