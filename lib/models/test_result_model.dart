class TestResult {
  final int? id;
  final String userId;
  final int depressionScore;
  final int anxietyScore;
  final int stressScore;
  final String selfieUrl;
  final DateTime date;

  TestResult({
    this.id,
    required this.userId,
    required this.depressionScore,
    required this.anxietyScore,
    required this.stressScore,
    required this.selfieUrl,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'depressionScore': depressionScore,
      'anxietyScore': anxietyScore,
      'stressScore': stressScore,
      'selfieUrl': selfieUrl,
      'date': date.toIso8601String(),
    };
  }

  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      userId: map['userId'],
      depressionScore: map['depressionScore'],
      anxietyScore: map['anxietyScore'],
      stressScore: map['stressScore'],
      selfieUrl: map['selfieUrl'],
      date: DateTime.parse(map['date']),
    );
  }
}
