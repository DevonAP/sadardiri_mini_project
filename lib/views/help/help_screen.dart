import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _launchUrl(BuildContext context, Uri url) async {
    if (!await launchUrl(url)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal membuka tautan.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan Darurat', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Jangan ragu untuk mencari bantuan jika Anda merasa kewalahan. Para profesional siap mendengarkan dan membantu Anda.',
            style: TextStyle(fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 24),
          _buildContactCard(
            context,
            icon: Icons.phone_in_talk,
            title: 'Halo Kemenkes',
            subtitle: 'Layanan Kesehatan Jiwa Nasional',
            actionText: 'Telepon 1500-567',
            onTap: () => _launchUrl(context, Uri.parse('tel:1500567')),
          ),
          _buildContactCard(
            context,
            icon: Icons.telegram,
            title: 'Konselor Sadar Diri',
            subtitle: 'Layanan Konseling Psikologis',
            actionText: 'Chat Telegram',
            onTap: () => _launchUrl(context, Uri.parse('https://t.me/leyanharits')),
          ),
          _buildContactCard(
            context,
            icon: Icons.local_hospital,
            title: 'Gawat Darurat Medis',
            subtitle: 'Ambulans & Gawat Darurat',
            actionText: 'Telepon 119',
            onTap: () => _launchUrl(context, Uri.parse('tel:119')),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: cs.primaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: cs.primary.withValues(alpha: 0.1),
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(actionText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
