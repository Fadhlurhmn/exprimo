// lib/models/user_model.dart
class UserModel {
  final String idUser;
  final String username;
  final String email;
  final String password;

  UserModel({
    required this.idUser,
    required this.username,
    required this.email,
    required this.password,
  });

  // Buat factory untuk mengonversi data dari Firestore menjadi UserModel
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      idUser: documentId,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
    );
  }

  // Metode untuk mengonversi UserModel menjadi Map sebelum disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }
}
