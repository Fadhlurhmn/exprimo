import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:exprimo/constants.dart'; // pastikan ini adalah import yang sesuai untuk variabel warna

class DisplayImagePage extends StatelessWidget {
  final String imagePath;

  DisplayImagePage({required this.imagePath});

  // Fungsi untuk mendownload gambar
  Future<void> downloadImage(String imagePath) async {
    try {
      final directory = await getExternalStorageDirectory();
      final fileName = imagePath.split('/').last;
      final newFile = File('${directory?.path}/$fileName');
      final imageBytes = await File(imagePath).readAsBytes();
      await newFile.writeAsBytes(imageBytes);
      print("Gambar berhasil didownload ke: ${newFile.path}");
    } catch (e) {
      print("Terjadi kesalahan saat mendownload gambar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan lebar layar
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tampilkan Gambar'),
        backgroundColor: secondaryColor, // Sesuaikan warna app bar
      ),
      body: Column(
        children: [
          // Menambahkan Spacer untuk mendorong gambar lebih ke atas
          Spacer(flex: 1), 
          // Menampilkan gambar dengan ukuran setengah layar
          Center(
            child: Image.file(
              File(imagePath),
              width: MediaQuery.of(context).size.width * 0.75, // Setel lebar gambar menjadi 75% lebar layar
              height: MediaQuery.of(context).size.height * 0.75, // Setel tinggi gambar menjadi 60% tinggi layar
              fit: BoxFit.contain, // Menjaga rasio aspek gambar tetap utuh
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: 300, 
            child: ElevatedButton(
              onPressed: () {
                downloadImage(imagePath); 
              },
              child: Text(
                'Download',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF5DADA),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Spacer(flex: 2), // Memberikan ruang di bawah tombol untuk mendorong elemen lebih ke atas
        ],
      ),
    );
  }
}
