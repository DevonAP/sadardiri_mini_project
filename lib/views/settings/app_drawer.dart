import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import 'change_password_screen.dart';

/// Hamburger menu (Drawer) aplikasi.
/// Berisi tiga bagian: Akun, Pengaturan (Aksen + Tema), dan Keluar.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsViewModel>();
    final email =
        context.read<HomeViewModel>().currentUser?.email ?? 'Pengguna';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, colorScheme, email),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ---------- BAGIAN 1: AKUN ----------
                  _sectionLabel(context, 'Akun'),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Ubah Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),

                  // ---------- BAGIAN 2: PENGATURAN ----------
                  _sectionLabel(context, 'Pengaturan'),

                  // Sub-bagian 2.1: Aksen
                  ExpansionTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('Aksen'),
                    subtitle: Text(_accentLabel(settings.accent)),
                    childrenPadding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      _buildAccentPicker(context, settings),
                    ],
                  ),

                  // Sub-bagian 2.2: Tema
                  ExpansionTile(
                    leading: const Icon(Icons.brightness_6_outlined),
                    title: const Text('Tema'),
                    subtitle: Text(_themeLabel(settings.themeMode)),
                    children: [
                      // ignore: deprecated_member_use
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.light,
                        // ignore: deprecated_member_use
                        groupValue: settings.themeMode,
                        // ignore: deprecated_member_use
                        onChanged: (mode) => settings.setThemeMode(mode!),
                        secondary: const Icon(Icons.light_mode_outlined),
                        title: const Text('Mode Terang'),
                      ),
                      // ignore: deprecated_member_use
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.dark,
                        // ignore: deprecated_member_use
                        groupValue: settings.themeMode,
                        // ignore: deprecated_member_use
                        onChanged: (mode) => settings.setThemeMode(mode!),
                        secondary: const Icon(Icons.dark_mode_outlined),
                        title: const Text('Mode Gelap'),
                      ),
                      // ignore: deprecated_member_use
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.system,
                        // ignore: deprecated_member_use
                        groupValue: settings.themeMode,
                        // ignore: deprecated_member_use
                        onChanged: (mode) => settings.setThemeMode(mode!),
                        secondary: const Icon(Icons.settings_suggest_outlined),
                        title: const Text('Ikuti Sistem'),
                      ),
                    ],
                  ),
                  const Divider(),

                  // ---------- BAGIAN 3: BANTUAN DARURAT ----------
                  _sectionLabel(context, 'Bantuan Darurat'),
                  ListTile(
                    leading: const Icon(Icons.phone_in_talk, color: Colors.red),
                    title: const Text('Kontak Profesional', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.red),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, 'help');
                    },
                  ),
                  const Divider(),

                  // ---------- BAGIAN 4: KELUAR ----------
                  ListTile(
                    leading: Icon(Icons.logout, color: colorScheme.error),
                    title: Text(
                      'Keluar',
                      style: TextStyle(color: colorScheme.error),
                    ),
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme colorScheme,
    String email,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/Transparan_SadarDiri.png',
            height: 72,
            width: 72,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            email.split('@').first,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            email,
            style: TextStyle(
              color: colorScheme.onPrimary.withValues(alpha: 0.8),
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildAccentPicker(BuildContext context, SettingsViewModel settings) {
    final swatches = <Widget>[
      // Preset warna
      for (final entry in SettingsViewModel.presets.entries)
        _AccentSwatch(
          color: entry.value.seed,
          label: entry.value.label,
          selected: settings.accent == entry.key && !settings.isMaterialYou,
          onTap: () => settings.setAccent(entry.key),
        ),
      // Material You
      _AccentSwatch(
        color: null,
        label: 'Material You',
        selected: settings.isMaterialYou,
        onTap: () => settings.setAccent(AccentOption.materialYou),
      ),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: swatches,
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<HomeViewModel>().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'login',
                  (route) => false,
                );
              }
            },
            child: Text(
              'Keluar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  String _accentLabel(AccentOption option) {
    if (option == AccentOption.materialYou) return 'Material You';
    return SettingsViewModel.presets[option]?.label ?? 'Teal';
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Mode Terang';
      case ThemeMode.dark:
        return 'Mode Gelap';
      case ThemeMode.system:
        return 'Ikuti Sistem';
    }
  }
}

/// Lingkaran pilihan warna aksen. Bila [color] null, ditampilkan
/// gradient khas Material You.
class _AccentSwatch extends StatelessWidget {
  final Color? color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AccentSwatch({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              gradient: color == null
                  ? const SweepGradient(
                      colors: [
                        Color(0xFF4285F4),
                        Color(0xFF34A853),
                        Color(0xFFFBBC05),
                        Color(0xFFEA4335),
                        Color(0xFF4285F4),
                      ],
                    )
                  : null,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? onSurface : Colors.transparent,
                width: 3,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 22)
                : null,
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 56,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: onSurface,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
