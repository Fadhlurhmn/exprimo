import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ubahprofile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool isButtonEnabled = false;
  String? userId;
  DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkEmailField);
    _loadUserData();
  }

  @override
  void dispose() {
    _emailController.removeListener(_checkEmailField);
    _emailController.dispose();
    super.dispose();
  }

  // Fungsi untuk memeriksa apakah field email sudah diisi
  void _checkEmailField() {
    setState(() {
      isButtonEnabled = _emailController.text.isNotEmpty;
    });
  }

  // Fungsi untuk memuat userId yang tersimpan di SharedPreferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId != null) {
      // Ambil email saat ini dari database dan tampilkan di TextField
      DatabaseEvent event = await usersRef.child(userId!).once();
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> userData =
            event.snapshot.value as Map<dynamic, dynamic>;
        String currentEmail = userData['email'];
        setState(() {
          _emailController.text = currentEmail;
        });
      }
    }
  }

  // Fungsi untuk memvalidasi email dengan format Gmail
  bool _isValidEmail(String email) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@gmail\.com$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  // Fungsi untuk memperbarui email di Realtime Database dan navigasi ke halaman UbahProfilePage
  Future<void> _updateEmail() async {
    String newEmail = _emailController.text;

    if (!_isValidEmail(newEmail)) {
      // Tampilkan peringatan jika email tidak valid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email tidak valid. Harap gunakan format Gmail')),
      );
      return;
    }

    if (userId != null) {
      try {
        await usersRef.child(userId!).update({'email': newEmail});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email berhasil diubah!')),
        );
        
        // Navigate to UbahProfilePage after email update
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UbahProfilePage(),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah email: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID tidak ditemukan!')),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Email',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email, color: Colors.black),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: isButtonEnabled ? _updateEmail : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isButtonEnabled ? Colors.pink[200] : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Reset Email',
                  style: TextStyle(
                    fontSize: 16,
                    color: isButtonEnabled ? Colors.white : Colors.grey,
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
