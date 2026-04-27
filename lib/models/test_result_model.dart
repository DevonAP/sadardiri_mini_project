class TestResult {
  final int? id; // Untuk SQLite
  final String userId;
  final int score;
  final String selfieUrl;
  final DateTime date;

  TestResult({this.id, required this.userId, required this.score, required this.selfieUrl, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'score': score,
      'selfieUrl': selfieUrl,
      'date': date.toIso8601String(),
    };
  }

  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      id: map['id'],
      userId: map['userId'],
      score: map['score'],
      selfieUrl: map['selfieUrl'],
      date: DateTime.parse(map['date']),
    );
  }
}