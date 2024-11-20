import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class DisplayImagePage extends StatelessWidget {
  final String imageURL; // URL gambar dari Firebase

  DisplayImagePage({required this.imageURL});

  /// Meminta izin penyimpanan dari pengguna
  Future<void> requestPermission(BuildContext context) async {
  if (await Permission.storage.request().isGranted || await Permission.manageExternalStorage.request().isGranted) {
    // Izin diberikan
  } else {
    // Izin tidak diberikan, tampilkan snackbar atau alert dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Izin penyimpanan tidak diberikan')),
    );
  }
}

  /// Mengunduh gambar dari Firebase dan menyimpannya ke penyimpanan lokal
  Future<void> downloadImage(BuildContext context) async {
    await requestPermission(context);
    if (!await Permission.storage.isGranted) return; // Pastikan izin diberikan

    try {
      // Menyimpan gambar ke folder Download di perangkat
      Directory? directory = await getExternalStorageDirectory();
      String downloadsPath = '${directory!.path}/Download'; // Ganti dengan lokasi yang benar jika diperlukan
      await Directory(downloadsPath).create(recursive: true); // Membuat folder jika belum ada

      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      String filePath = '$downloadsPath/$fileName';

      // Unduh gambar dari Firebase menggunakan HTTP
      var response = await http.get(Uri.parse(imageURL));
      if (response.statusCode == 200) {
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);  // Simpan gambar ke disk

        // Menampilkan notifikasi berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gambar berhasil diunduh: $filePath')),
        );
      } else {
        throw Exception('Gagal mengunduh gambar, status kode: ${response.statusCode}');
      }
    } catch (e) {
      // Menampilkan pesan gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunduh gambar: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // Mendapatkan lebar layar untuk menyesuaikan tampilan gambar
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Scan'),
        backgroundColor: Colors.blue, // Ganti sesuai dengan warna tema Anda
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tampilkan gambar dari URL
            Container(
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // Membuat border bulat
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18), // Sudut bulat untuk gambar
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159), // Membalikkan gambar horizontal
                  child: Image.network(
                    imageURL, // Tampilkan gambar dari URL Firebase
                    fit: BoxFit.cover, // Sesuaikan gambar agar pas
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(), // Animasi loading
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Text('Gagal memuat gambar'));
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Tombol Unduh
            Container(
              width: 300, // Lebar tombol
              child: ElevatedButton(
                onPressed: () {
                  downloadImage(context); // Fungsi unduh gambar
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
          ],
        ),
      ),
    );
  }
}
