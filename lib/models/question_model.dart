class Question {
  final int id;
  final String text;
  final String category; // 'depression', 'anxiety', atau 'stress'

  Question({
    required this.id, 
    required this.text, 
    required this.category
  });
}