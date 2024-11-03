import 'package:firebase_database/firebase_database.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

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

  // Mengubah objek user ke map
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }
}

// Fungsi untuk melakukan hashing password
String hashPassword(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);
  return digest.toString();
}

// Fungsi untuk memeriksa apakah username sudah ada di database
Future<bool> checkUsernameExists(String username) async {
  DatabaseReference usersRef = database.ref("users");
  DatabaseEvent event = await usersRef.once();

  if (event.snapshot.value != null) {
    Map<dynamic, dynamic> users = event.snapshot.value as Map<dynamic, dynamic>;
    for (var user in users.values) {
      if (user['username'] == username) {
        return true; // Username sudah ada
      }
    }
  }
  return false; // Username tidak ada
}

// Fungsi untuk menambah user baru ke database
void tambahUser(User user) async {
  DatabaseReference usersRef = database.ref("users");

  // Validasi email agar unik
  bool emailExists = await checkEmailExists(user.email);
  if (emailExists) {
    print("Email sudah terdaftar. Gunakan email lain.");
    return;
  }

  // Validasi username agar unik
  bool usernameExists = await checkUsernameExists(user.username);
  if (usernameExists) {
    print("Username sudah terdaftar. Gunakan username lain.");
    return;
  }

  // Hashing password sebelum disimpan
  user.password = hashPassword(user.password);

  // Menambahkan user ke database dengan ID unik yang dihasilkan oleh `push()`
  usersRef.push().set(user.toJson()).then((_) {
    print("User berhasil ditambahkan!");
  }).catchError((error) {
    print("Gagal menambahkan user: $error");
  });
}

// Fungsi untuk memeriksa apakah email sudah ada di database
Future<bool> checkEmailExists(String email) async {
  DatabaseReference usersRef = database.ref("users");
  DatabaseEvent event = await usersRef.once();

  if (event.snapshot.value != null) {
    Map<dynamic, dynamic> users = event.snapshot.value as Map<dynamic, dynamic>;
    for (var user in users.values) {
      if (user['email'] == email) {
        return true;
      }
    }
  }
  return false;
}

// Fungsi untuk memeriksa data login
Future<bool> login(String username, String password) async {
  String hashedPassword = hashPassword(password);
  DatabaseReference usersRef = database.ref("users");
  DatabaseEvent event = await usersRef.once();

  if (event.snapshot.value != null) {
    Map<dynamic, dynamic> users = event.snapshot.value as Map<dynamic, dynamic>;
    for (var user in users.values) {
      if (user['username'] == username && user['password'] == hashedPassword) {
        return true; // Login berhasil
      }
    }
  }
  return false; // Login gagal
}

// Fungsi untuk mendapatkan ID pengguna berdasarkan email
Future<String?> getUserIdByEmail(String email) async {
  DatabaseReference usersRef = database.ref("users");
  DatabaseEvent event = await usersRef.once();

  if (event.snapshot.value != null) {
    Map<dynamic, dynamic> users = event.snapshot.value as Map<dynamic, dynamic>;
    for (var entry in users.entries) {
      if (entry.value['email'] == email) {
        return entry.key;
      }
    }
  }
  return null;
}

// Fungsi untuk mengubah username pengguna
Future<void> changeUsername(String email, String newUsername) async {
  String? userId = await getUserIdByEmail(email);
  if (userId != null) {
    DatabaseReference userRef = database.ref("users/$userId");
    userRef.update({'username': newUsername}).then((_) {
      print("Username berhasil diubah!");
    }).catchError((error) {
      print("Gagal mengubah username: $error");
    });
  } else {
    print("User dengan email tersebut tidak ditemukan.");
  }
}



// Fungsi untuk mengubah email pengguna dengan pengecekan email baru
Future<void> changeEmail(String currentEmail, String newEmail) async {
  String? userId = await getUserIdByEmail(currentEmail);
  if (userId == null) {
    print("User dengan email tersebut tidak ditemukan.");
    return;
  }

  bool newEmailExists = await checkEmailExists(newEmail);
  if (newEmailExists) {
    print("Email baru sudah terdaftar. Gunakan email lain.");
    return;
  }

  DatabaseReference userRef = database.ref("users/$userId");
  userRef.update({'email': newEmail}).then((_) {
    print("Email berhasil diubah!");
  }).catchError((error) {
    print("Gagal mengubah email: $error");
  });
}

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
