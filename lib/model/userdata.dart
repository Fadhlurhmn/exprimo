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
      'email' : email,
      'password' : password,
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
