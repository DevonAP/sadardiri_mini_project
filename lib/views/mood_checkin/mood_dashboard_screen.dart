import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/mood_viewmodel.dart';
import '../../widgets/mood_chart.dart';
import 'mood_checkin_screen.dart';

class MoodDashboardScreen extends StatefulWidget {
  const MoodDashboardScreen({super.key});

  @override
  State<MoodDashboardScreen> createState() => _MoodDashboardScreenState();
}

class _MoodDashboardScreenState extends State<MoodDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodViewModel>().loadMoodHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final vm = context.watch<MoodViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: vm.isLoadingHistory
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kartu Grafik
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Grafik 7 Hari Terakhir', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
                          const SizedBox(height: 16),
                          MoodChart(logs: vm.moodLogs.reversed.toList()), // Di-reverse karena list utama DESC, chart butuh ASC
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Kartu Feedback / AI Insight
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.auto_awesome, color: cs.primary, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('SadarDiri Insight', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary, fontSize: 16)),
                                const SizedBox(height: 8),
                                Text(
                                  vm.feedbackMessage,
                                  style: TextStyle(color: cs.onPrimaryContainer, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Riwayat Log Jurnal
                    Text('Riwayat Jurnal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: cs.onSurface)),
                    const SizedBox(height: 12),
                    if (vm.moodLogs.isEmpty)
                      const Text('Belum ada catatan mood.')
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: vm.moodLogs.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final log = vm.moodLogs[index];
                          final dateStr = log.timestamp.toLocal().toString().substring(0, 16);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: _getMoodColor(log.mood, cs),
                              child: Text(_getMoodEmoji(log.mood), style: const TextStyle(fontSize: 20)),
                            ),
                            title: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            subtitle: log.note != null && log.note!.isNotEmpty
                                ? Text(log.note!, maxLines: 2, overflow: TextOverflow.ellipsis)
                                : const Text('Tanpa catatan', style: TextStyle(fontStyle: FontStyle.italic)),
                          );
                        },
                      ),
                    const SizedBox(height: 80), // Padding bawah agar tidak tertutup FAB
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodCheckinScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Isi Jurnal Hari Ini'),
      ),
    );
  }

  Color _getMoodColor(int mood, ColorScheme cs) {
    if (mood >= 4) return Colors.green.shade100;
    if (mood == 3) return Colors.orange.shade100;
    return Colors.red.shade100;
  }

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 1: return '😞';
      case 2: return '😕';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '😁';
      default: return '😐';
    }
  }
}
