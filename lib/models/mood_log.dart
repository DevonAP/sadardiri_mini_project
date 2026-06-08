import 'package:cloud_firestore/cloud_firestore.dart';

class MoodLog {
  final int? id;
  final DateTime timestamp;
  final int mood; // 1..5
  final String? note;
  final bool synced;
  final String? uid;

  MoodLog({
    this.id,
    required this.timestamp,
    required this.mood,
    this.note,
    this.synced = false,
    this.uid,
  });

  Map<String, dynamic> toMapForDb() => {
        'timestamp': timestamp.millisecondsSinceEpoch,
        'mood': mood,
        'note': note,
        'synced': synced ? 1 : 0,
        'uid': uid,
      };

  Map<String, dynamic> toFirestoreMap() => {
        'timestamp': Timestamp.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch),
        'mood': mood,
        'note': note ?? '',
        'uid': uid ?? '',
      };

  factory MoodLog.fromDb(Map<String, dynamic> m) => MoodLog(
        id: m['id'] as int?,
        timestamp: DateTime.fromMillisecondsSinceEpoch(m['timestamp'] as int),
        mood: m['mood'] as int,
        note: m['note'] as String?,
        synced: (m['synced'] as int) == 1,
        uid: m['uid'] as String?,
      );
}