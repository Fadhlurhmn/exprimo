import 'dart:io';
import 'package:exprimo/constants.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DisplayImagePage extends StatelessWidget {
  final String imagePath;

  DisplayImagePage({required this.imagePath});

  Future<void> requestPermission(BuildContext context) async {
    // Meminta izin untuk penyimpanan
    if (await Permission.storage.request().isGranted) {
      // Izin diberikan
    } else {
      // Tampilkan pesan bahwa izin tidak diberikan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Izin penyimpanan tidak diberikan')),
      );
    }
  }

  Future<void> downloadImage(BuildContext context) async {
    await requestPermission(context);
    if (!await Permission.storage.isGranted) return; // Cek izin

    try {
      // Mendapatkan direktori Downloads
      Directory? directory = await getExternalStorageDirectory();
      String downloadsPath = '${directory!.path}/Download';
      await Directory(downloadsPath).create(recursive: true); // Membuat folder jika belum ada

      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      String filePath = '$downloadsPath/$fileName';

      // Menyalin file gambar ke lokasi baru
      await File(imagePath).copy(filePath);

      // Menampilkan notifikasi atau dialog berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gambar berhasil diunduh: $filePath')),
      );
    } catch (e) {
      // Menampilkan notifikasi atau dialog gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunduh gambar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan lebar layar
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Scan'),
        backgroundColor: secondaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // Membuat border rounded
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18), // Set the rounded corner for the image
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159), // Membalikkan gambar horizontal
                  child: Image.file(
                    File(imagePath), // Display the captured image
                    fit: BoxFit.cover, // Ensure the image fills the container
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 300, // Set the desired width for the button
              child: ElevatedButton(
                onPressed: () {
                  downloadImage(context); // Call the download function
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
