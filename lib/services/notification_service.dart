import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  // 1. Inisialisasi Channel Notifikasi
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // Gunakan null untuk icon default aplikasi
      [
        // --- CHANNEL SKRINING (KODE ANDA) ---
        NotificationChannel(
          channelGroupKey: 'screening_group',
          channelKey: 'screening_channel',
          channelName: 'Pengingat Skrining',
          channelDescription: 'Notifikasi untuk mengingatkan skrining DASS rutin',
          defaultColor: const Color(0xFF00796B), // Warna teal
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        // --- CHANNEL MOOD TRACKER ---
        NotificationChannel(
          channelGroupKey: 'sadardiri_group',
          channelKey: 'mood_channel',
          channelName: 'Pengingat Mood Harian',
          channelDescription: 'Notifikasi untuk check-in mood harian',
          defaultColor: Colors.teal,
          ledColor: Colors.teal,
          importance: NotificationImportance.High,
        )
      ],
      debug: true, // Set false saat rilis ke Play Store
    );
  }

  // 2. Minta Izin Notifikasi (Kode Anda)
  static Future<void> requestPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  // 3. Buat Jadwal Pengingat SKRINING (KODE ANDA)
  static Future<void> scheduleScreeningReminder() async {
    // --- MODE DEVELOPMENT (Testing) ---
    Duration interval = const Duration(seconds: 62);

    // --- MODE PRODUCTION (2 Minggu) ---
    // Duration interval = const Duration(days: 14);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 100, // ID 100 untuk Skrining
        channelKey: 'screening_channel',
        title: 'Waktunya Skrining SadarDiri! 🧠',
        body: 'Sudah 2 minggu sejak tes terakhirmu. Yuk, luangkan 5 menit untuk mengecek kondisi mentalmu.',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationInterval(
        interval: interval,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: true, 
      ),
    );
  }

  // 4. Buat Jadwal Pengingat MOOD HARIAN
  static Future<void> scheduleMoodReminder({int hour = 17, int minute = 37}) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 101, // ID 101 untuk Mood
        channelKey: 'mood_channel',
        title: 'Bagaimana perasaanmu malam ini?',
        body: 'Yuk, catat mood dan refleksi harianmu di SadarDiri.',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        repeats: true, 
      ),
    );
  }

  // (Opsional) Fungsi untuk membatalkan pengingat
  static Future<void> cancelAllReminders() async {
    await AwesomeNotifications().cancelAllSchedules();
  }

  static Future<void> cancelMoodReminder() async {
    await AwesomeNotifications().cancel(101);
  }
}