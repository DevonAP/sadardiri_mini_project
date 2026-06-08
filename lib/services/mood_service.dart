import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/mood_log.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodService {
  static final MoodService instance = MoodService._();
  MoodService._();

  Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    final docs = await getApplicationDocumentsDirectory();
    final path = join(docs.path, 'sadar_diri.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE mood_logs(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp INTEGER,
          mood INTEGER,
          note TEXT,
          synced INTEGER DEFAULT 0,
          uid TEXT
        )
      ''');
    });
  }

  Future<int> addMood(MoodLog log) async {
    await init();
    final id = await _db!.insert('mood_logs', log.toMapForDb());
    return id;
  }

  Future<List<MoodLog>> getMoodLogs({DateTime? from, DateTime? to}) async {
    await init();
    String where = '';
    List<dynamic> args = [];
    if (from != null) {
      where = 'timestamp >= ?';
      args.add(from.millisecondsSinceEpoch);
    }
    if (to != null) {
      where = where.isEmpty ? 'timestamp <= ?' : '$where AND timestamp <= ?';
      args.add(to.millisecondsSinceEpoch);
    }
    final rows = await _db!.query('mood_logs', where: where.isEmpty ? null : where, whereArgs: args.isEmpty ? null : args, orderBy: 'timestamp DESC');
    return rows.map((r) => MoodLog.fromDb(r)).toList();
  }

  Future<void> syncPendingToFirestore() async {
    await init();
    final pending = await _db!.query('mood_logs', where: 'synced = 0');
    if (pending.isEmpty) return;
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    for (final row in pending) {
      final log = MoodLog.fromDb(row);
      try {
        final data = log.toFirestoreMap();
        if (user != null) data['uid'] = user.uid;
        await firestore.collection('mood_logs').add(data);
        await _db!.update('mood_logs', {'synced': 1}, where: 'id = ?', whereArgs: [log.id]);
      } catch (e) {
        // leave unsynced for retry
      }
    }
  }

  Future<void> scheduleDailyReminder({int hour = 20, int minute = 0}) async {
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 12345,
        channelKey: 'basic_channel',
        title: 'Time for your mood check-in',
        body: 'Tap to record how you feel today.',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(hour: hour, minute: minute, second: 0, repeats: true),
    );
  }
}