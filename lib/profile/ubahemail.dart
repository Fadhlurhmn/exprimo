import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'resetemail.dart';

class UbahEmailPage extends StatefulWidget {
  const UbahEmailPage({super.key});

  @override
  _UbahEmailPageState createState() => _UbahEmailPageState();
}

class _UbahEmailPageState extends State<UbahEmailPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool isButtonEnabled = false;
  DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");
  String? userId;
  String? currentHashedPassword;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordField);
    _loadUserData();
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPasswordField);
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi untuk memuat data pengguna dari Firebase
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (userId != null) {
      try {
        DatabaseEvent event = await usersRef.child(userId!).once();
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> userData =
              event.snapshot.value as Map<dynamic, dynamic>;

          setState(() {
            currentHashedPassword = userData['password']?.toString();
            isLoading = false;
          });

          print("Password hash dari database: $currentHashedPassword");
        } else {
          print("Data pengguna tidak ditemukan di database.");
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print("Error saat mengambil data dari Firebase: $e");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Fungsi untuk memeriksa apakah password field diisi
  void _checkPasswordField() {
    setState(() {
      isButtonEnabled = _passwordController.text.isNotEmpty;
    });
  }

  // Fungsi untuk hashing password menggunakan SHA-256
  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Fungsi untuk memvalidasi password yang dimasukkan
  void _verifyPasswordAndNavigate() {
    String inputPasswordHash = hashPassword(_passwordController.text);
    print("Password hash yang dimasukkan: $inputPasswordHash");
    print("Password hash yang tersimpan: $currentHashedPassword");

    if (inputPasswordHash == currentHashedPassword) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password salah!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Konfirmasi Password',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Masukkan password untuk mengganti email',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input Field untuk Password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.pink[50],
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Tombol Konfirmasi Password
                  Center(
                    child: ElevatedButton(
                      onPressed:
                          isButtonEnabled ? _verifyPasswordAndNavigate : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isButtonEnabled ? Colors.pink[300] : Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Konfirmasi Password',
                        style: TextStyle(
                          fontSize: 16,
                          color: isButtonEnabled ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
