import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/mood_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class MoodCheckinScreen extends StatefulWidget {
  const MoodCheckinScreen({super.key});

  @override
  State<MoodCheckinScreen> createState() => _MoodCheckinScreenState();
}

class _MoodCheckinScreenState extends State<MoodCheckinScreen> {
  // Controller untuk CustomTextField
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Widget kustom untuk pilihan Emoji yang lebih cantik dan interaktif
  Widget _buildEmoji(BuildContext context, int value, String emoji, int selectedMood) {
    final isSelected = selectedMood == value;
    final viewModel = context.read<MoodViewModel>();
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => viewModel.setMood(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isSelected ? 16 : 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withOpacity(0.15) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? cs.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          emoji, 
          style: TextStyle(fontSize: isSelected ? 40 : 28)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MoodViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Check-in',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Bagaimana perasaanmu hari ini?',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: cs.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih emoji yang paling menggambarkan suasana hatimu.',
                style: TextStyle(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Baris Emoji Mood
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEmoji(context, 1, '😞', vm.mood), // Sangat Buruk
                  _buildEmoji(context, 2, '😕', vm.mood), // Buruk
                  _buildEmoji(context, 3, '😐', vm.mood), // Biasa saja
                  _buildEmoji(context, 4, '🙂', vm.mood), // Baik
                  _buildEmoji(context, 5, '😁', vm.mood), // Sangat Baik
                ],
              ),
              
              const SizedBox(height: 48),
              
              // Input Catatan Menggunakan CustomTextField sesuai aturan
              CustomTextField(
                label: 'Catatan Jurnal (Opsional)',
                hintText: 'Ceritakan sedikit apa yang membuatmu merasa demikian...',
                controller: _noteController,
              ),
              
              const SizedBox(height: 48),
              
              // Tombol Simpan Menggunakan CustomButton
              CustomButton(
                text: 'Simpan Mood',
                isLoading: vm.saving,
                onPressed: () async {
                  // Set catatan dari controller sebelum save
                  vm.setNote(_noteController.text);

                  final success = await vm.save();
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mood berhasil disimpan!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).pop(); // Kembali ke Home
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}