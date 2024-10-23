import 'package:flutter/material.dart';
import 'resetemail.dart'; // Import halaman reset email

class UbahEmailPage extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Text(
              'Konfirmasi Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Masukkan password untuk mengganti email',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            // TextField for Password Input
            TextField(
              controller: _passwordController,
              obscureText: true, // Hide the password
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock), // Add lock icon
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
            SizedBox(height: 50),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Aksi untuk mengkonfirmasi password dan pindah halaman
                  if (_passwordController.text == 'passwordBenar') { // Misalkan passwordnya 'passwordBenar'
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ResetEmailPage()), // Navigasi ke halaman ResetEmailPage
                    );
                  } else {
                    // Tampilkan pesan error jika password salah
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password salah!'))
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[300],
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Konfirmasi Password',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
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

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: UbahEmailPage(),
  ));
}