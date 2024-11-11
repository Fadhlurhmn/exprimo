import 'package:firebase_database/firebase_database.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Mengubah objek user menjadi map
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }
}

// Fungsi untuk hashing password menggunakan SHA-256
String hashPassword(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);
  return digest.toString();
}

// Fungsi untuk menambahkan user baru ke database
Future<void> tambahUser(User user) async {
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

  // Hash password sebelum disimpan
  user.password = hashPassword(user.password);

  // Menambahkan user ke database dengan ID unik yang dihasilkan oleh `push()`
  await usersRef.push().set(user.toJson());
  print("User berhasil ditambahkan!");
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

// Fungsi untuk memeriksa apakah email sudah ada di database
Future<bool> checkEmailExists(String email) async {
  DatabaseReference usersRef = database.ref("users");
  DatabaseEvent event = await usersRef.once();

  if (event.snapshot.value != null) {
    Map<dynamic, dynamic> users = event.snapshot.value as Map<dynamic, dynamic>;
    for (var user in users.values) {
      if (user['email'] == email) {
        return true; // Email sudah ada
      }
    }
  }
  return false; // Email tidak ada
}

// Fungsi untuk mendapatkan ID user berdasarkan username
Future<String?> getUserIdByUsername(String username) async {
  DatabaseReference usersRef = database.ref("users");
  DatabaseEvent event = await usersRef.once();

  if (event.snapshot.value != null) {
    Map<dynamic, dynamic> users = event.snapshot.value as Map<dynamic, dynamic>;
    for (var entry in users.entries) {
      if (entry.value['username'] == username) {
        return entry.key; // Mengembalikan userId
      }
    }
  }
  return null; // ID tidak ditemukan
}

// Fungsi untuk login dan menyimpan session ID
Future<bool> login(String username, String password) async {
  String hashedPassword = hashPassword(password);
  DatabaseReference usersRef = database.ref("users");
  DatabaseEvent event = await usersRef.once();

  if (event.snapshot.value != null) {
    Map<dynamic, dynamic> users = event.snapshot.value as Map<dynamic, dynamic>;
    for (var entry in users.entries) {
      var user = entry.value;
      if (user['username'] == username && user['password'] == hashedPassword) {
        // Jika login berhasil, simpan userId ke dalam SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', entry.key); // Menyimpan userId

        return true; // Login berhasil
      }
    }
  }
  return false; // Login gagal
}

// Fungsi untuk logout dengan menghapus session ID
Future<void> logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId'); // Menghapus session
  print("User telah logout");
}
