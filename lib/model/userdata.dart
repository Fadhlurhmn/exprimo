import 'package:firebase_database/firebase_database.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

class User {
  String username;
  String email;
  String password;

  User({
    required this.username,
    required this.email,
    required this.password,
  });

  //Mengubah objek user ke map
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }
}

void tambahUser(User user) {
  // Referensi ke lokasi 'users' di database
  DatabaseReference usersRef = database.ref("users");

  // Menambahkan user ke database dengan ID unik yang dihasilkan oleh `push()`
  usersRef.push().set(user.toJson()).then((_) {
    print("User berhasil ditambahkan!");
  }).catchError((error) {
    print("Gagal menambahkan user: $error");
  });
}

void checkUserID(String email) {}



// void changeUsername(String userId, String newUsername) {
//   DatabaseReference userRef = database.ref("users/$userId");

//   userRef.update({'username': newUsername}).then((_) {
//     print("Username berhasil diubah!");
//   }).catchError((error) {
//     print("Gagal mengubah username: $error");
//   });
// }

// void changeEmail(String userId, String newEmail, String password) {
//   DatabaseReference userRef = database.ref("users/$userId", "users/$password");

//   userRef.update({'email': newEmail}).then((_) {
//     print("Email berhasil diubah!");
//   }).catchError((error) {
//     print("Gagal mengubah email: $error");
//   });
// }
