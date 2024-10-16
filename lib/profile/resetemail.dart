import 'package:flutter/material.dart';

class ResetEmailPage extends StatefulWidget {
  @override
  _ResetEmailPageState createState() => _ResetEmailPageState();
}

class _ResetEmailPageState extends State<ResetEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  bool isButtonEnabled = false; // Untuk mengatur state tombol aktif atau tidak

  // Fungsi untuk mengecek apakah email sudah diisi
  void _checkEmailInput() {
    setState(() {
      isButtonEnabled = _emailController.text.isNotEmpty;
    });
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            // TextField untuk input email baru
            TextField(
              controller: _emailController,
              onChanged: (text) => _checkEmailInput(), // Pantau inputan
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email), // Ikon amplop
                hintText: 'Enter your new email',
                filled: true,
                fillColor: Colors.pink[50], // Warna latar belakang merah muda
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
            SizedBox(height: 30),
            // Tombol Reset Email
            Center(
              child: ElevatedButton(
                onPressed: isButtonEnabled
                    ? () {
                        // Aksi ketika tombol ditekan dan aktif
                        print('Email direset: ${_emailController.text}');
                      }
                    : null, // Tombol disable jika email kosong
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[300],
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Reset Email',
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
    home: ResetEmailPage(),
  ));
}