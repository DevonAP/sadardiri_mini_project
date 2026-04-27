import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  // 1. Inisialisasi Channel Notifikasi
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // Gunakan null untuk icon default aplikasi, atau 'resource://drawable/res_app_icon'
      [
        NotificationChannel(
          channelGroupKey: 'screening_group',
          channelKey: 'screening_channel',
          channelName: 'Pengingat Skrining',
          channelDescription:
              'Notifikasi untuk mengingatkan skrining DASS rutin',
          defaultColor: const Color(0xFF00796B), // Warna teal
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
      debug: true, // Set false saat rilis ke Play Store
    );
  }

  // 2. Minta Izin Notifikasi (Sangat penting di Android 13 ke atas)
  static Future<void> requestPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  // 3. Buat Jadwal Pengingat
  static Future<void> scheduleScreeningReminder() async {
    // --- MODE DEVELOPMENT (Testing) ---
    // Menggunakan 10 detik agar kamu bisa lihat hasilnya langsung
    Duration interval = const Duration(seconds: 62);

    // --- MODE PRODUCTION (2 Minggu) ---
    // Jika sudah mau rilis, comment baris di atas, dan uncomment baris di bawah ini:
    // Duration interval = const Duration(days: 14); // 14 hari

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 100, // ID unik untuk notifikasi ini
        channelKey: 'screening_channel',
        title: 'Waktunya Skrining SadarDiri! 🧠',
        body:
            'Sudah 2 minggu sejak tes terakhirmu. Yuk, luangkan 5 menit untuk mengecek kondisi mentalmu.',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationInterval(
        interval: interval,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: true, // Akan terus berulang setiap interval tersebut
      ),
    );
  }

  // (Opsional) Fungsi untuk membatalkan pengingat saat user logout
  static Future<void> cancelAllReminders() async {
    await AwesomeNotifications().cancelAllSchedules();
  }
}
