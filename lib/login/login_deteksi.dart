import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loginUser() async {
    try {
      // Ambil data email dan password dari input pengguna
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      // Login menggunakan Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cek apakah pengguna ada di Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        // Pengguna terdaftar, login berhasil
        print("Login berhasil: Pengguna terdeteksi di database");
        // Arahkan pengguna ke halaman utama atau dashboard
      } else {
        // Pengguna tidak ditemukan di database
        print("Pengguna tidak ditemukan di database");
        // Berikan feedback ke pengguna
      }
    } catch (e) {
      print("Login gagal: $e");
      // Tampilkan pesan kesalahan kepada pengguna
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Masukkan Email",
                prefixIcon: Icon(Icons.email),
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Masukkan Password",
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: loginUser,
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
