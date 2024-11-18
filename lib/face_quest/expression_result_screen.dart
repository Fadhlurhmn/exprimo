import 'dart:math';

import 'package:exprimo/face_quest/face_quest_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ExpressionResultScreen extends StatelessWidget {
  final File imageFile;
  final String detectedExpression;
  final String expectedExpression;

  const ExpressionResultScreen({
    Key? key,
    required this.imageFile,
    required this.detectedExpression,
    required this.expectedExpression,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tentukan apakah ekspresi sesuai
    bool isSuccess =
        detectedExpression.toLowerCase() == expectedExpression.toLowerCase();

    return Scaffold(
      appBar: AppBar(title: Text('Hasil Ekspresi')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Menggunakan Transform untuk membalik gambar
            Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.rotationY(pi), // Membalik gambar secara horizontal
              child: Image.file(imageFile),
            ),
            SizedBox(height: 20),
            Text(
              isSuccess ? 'Sukses!' : 'Gagal!',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green : Colors.red),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 20.0), // Tambahkan padding di bawah
              child: ElevatedButton(
                onPressed: isSuccess
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FaceQuestScreen(),
                          ),
                        );
                      }
                    : null, // Nonaktifkan tombol jika gagal
                child: Text('Next'),
              ),
            ),
            if (!isSuccess) // Tampilkan tombol untuk mengambil gambar lagi
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Kembali ke halaman kamera
                },
                child: Text('Ambil Gambar Lagi'),
              ),
          ],
        ),
      ),
    );
  }
}
