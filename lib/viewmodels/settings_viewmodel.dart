import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pilihan aksen warna aplikasi.
/// [materialYou] memakai warna dinamis dari sistem (Android 12+).
enum AccentOption {
  teal,
  blue,
  purple,
  orange,
  pink,
  green,
  materialYou,
}

/// Metadata tampilan untuk tiap aksen preset.
class AccentInfo {
  final String label;
  final Color seed;
  const AccentInfo(this.label, this.seed);
}

/// Mengelola preferensi tampilan (aksen & tema) dan menyimpannya
/// secara persisten memakai SharedPreferences.
class SettingsViewModel extends ChangeNotifier {
  static const String _accentKey = 'pref_accent';
  static const String _themeKey = 'pref_theme_mode';

  // Peta preset warna -> info tampilan. Material You ditangani terpisah.
  static const Map<AccentOption, AccentInfo> presets = {
    AccentOption.teal: AccentInfo('Teal', Colors.teal),
    AccentOption.blue: AccentInfo('Biru', Color(0xFF1976D2)),
    AccentOption.purple: AccentInfo('Ungu', Color(0xFF6750A4)),
    AccentOption.orange: AccentInfo('Oranye', Color(0xFFF57C00)),
    AccentOption.pink: AccentInfo('Merah Muda', Color(0xFFC2185B)),
    AccentOption.green: AccentInfo('Hijau', Color(0xFF2E7D32)),
  };

  AccentOption _accent = AccentOption.teal;
  ThemeMode _themeMode = ThemeMode.system;

  AccentOption get accent => _accent;
  ThemeMode get themeMode => _themeMode;

  bool get isMaterialYou => _accent == AccentOption.materialYou;

  /// Warna seed yang dipakai untuk membangun ColorScheme preset.
  /// (Untuk Material You, seed ini hanya jadi fallback bila warna
  /// dinamis sistem tidak tersedia.)
  Color get seedColor =>
      presets[_accent]?.seed ?? Colors.teal;

  /// Memuat preferensi tersimpan saat aplikasi mulai.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final accentIndex = prefs.getInt(_accentKey);
    if (accentIndex != null &&
        accentIndex >= 0 &&
        accentIndex < AccentOption.values.length) {
      _accent = AccentOption.values[accentIndex];
    }

    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null &&
        themeIndex >= 0 &&
        themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    notifyListeners();
  }

  Future<void> setAccent(AccentOption option) async {
    if (_accent == option) return;
    _accent = option;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentKey, option.index);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  /// Membangun ThemeData terang. [lightDynamic] berasal dari
  /// DynamicColorBuilder (null jika perangkat tak mendukung Material You).
  ThemeData lightTheme(ColorScheme? lightDynamic) =>
      _buildTheme(Brightness.light, lightDynamic);

  /// Membangun ThemeData gelap. [darkDynamic] berasal dari
  /// DynamicColorBuilder (null jika perangkat tak mendukung Material You).
  ThemeData darkTheme(ColorScheme? darkDynamic) =>
      _buildTheme(Brightness.dark, darkDynamic);

  ThemeData _buildTheme(Brightness brightness, ColorScheme? dynamicScheme) {
    final ColorScheme scheme;
    if (_accent == AccentOption.materialYou && dynamicScheme != null) {
      scheme = dynamicScheme.harmonized();
    } else {
      scheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      );
    }

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        titleTextStyle: TextStyle(
          color: scheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: scheme.onPrimary),
      ),
    );
  }
}
