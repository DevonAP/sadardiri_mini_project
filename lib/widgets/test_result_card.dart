// lib/widgets/test_result_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/test_result_model.dart';
import '../viewmodels/home_viewmodel.dart';

/// Kartu ringkasan satu hasil skrining (tanggal + 3 skor DASS).
/// Dipakai bersama oleh HomeScreen dan HistoryScreen.
class TestResultCard extends StatelessWidget {
  final TestResult result;

  const TestResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final vm = context.read<HomeViewModel>();

    final depLvl = vm.getDepressionLevel(result.depressionScore);
    final anxLvl = vm.getAnxietyLevel(result.anxietyScore);
    final strLvl = vm.getStressLevel(result.stressScore);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: cs.shadow,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  result.date.toLocal().toString().substring(0, 16),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildScoreChip(
                    context, 'Depresi', depLvl, vm.getLevelColor(depLvl)),
                _buildScoreChip(
                    context, 'Cemas', anxLvl, vm.getLevelColor(anxLvl)),
                _buildScoreChip(
                    context, 'Stres', strLvl, vm.getLevelColor(strLvl)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreChip(
      BuildContext context, String label, String level, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 1.5),
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
