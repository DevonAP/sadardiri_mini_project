class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'user' atau 'counselor'

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.role = 'user', // Default sebagai user biasa
  });

  // Factory untuk mem-parsing data dari Firestore (Map) menjadi Object UserModel
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'user',
    );
  }

  // Method untuk mengubah Object UserModel menjadi Map (untuk disimpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
    };
  }
}