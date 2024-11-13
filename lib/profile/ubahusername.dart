import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditUsernamePage extends StatefulWidget {
  final String username;

  EditUsernamePage({required this.username});

  @override
  _EditUsernamePageState createState() => _EditUsernamePageState();
}

class _EditUsernamePageState extends State<EditUsernamePage> {
  late TextEditingController _usernameController;
  bool _isButtonEnabled = false;
  DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);

    // Listener untuk mendeteksi perubahan pada TextField
    _usernameController.addListener(() {
      setState(() {
        _isButtonEnabled = _usernameController.text != widget.username;
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // Fungsi untuk memperbarui username di Firebase dan SharedPreferences
  Future<void> _updateUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      // Validasi apakah username baru sudah digunakan
      bool usernameExists = await checkUsernameExists(_usernameController.text);
      if (usernameExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username sudah digunakan')),
        );
        return;
      }

      try {
        // Update username di Firebase
        await usersRef
            .child(userId)
            .update({'username': _usernameController.text});

        // Update username di SharedPreferences
        await prefs.setString('username', _usernameController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username berhasil diperbarui')),
        );
        Navigator.pop(context, _usernameController.text);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui username')),
        );
      }
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
        title:
            const Text('Edit Username', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text('Username',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
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
            Center(
              child: ElevatedButton(
                onPressed: _isButtonEnabled ? _updateUsername : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isButtonEnabled ? Colors.pink[300] : Colors.grey,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Reset Username',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk mengecek apakah username sudah ada di database
  Future<bool> checkUsernameExists(String username) async {
    DatabaseEvent event = await usersRef.once();

    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> users =
          event.snapshot.value as Map<dynamic, dynamic>;
      for (var user in users.values) {
        if (user['username'] == username) {
          return true; // Username sudah ada
        }
      }
    }
    return false; // Username tidak ada
  }
}
