import 'dart:io';
import 'package:flutter/material.dart';
import 'package:exprimo/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DisplayImagePage extends StatelessWidget {
  final String imagePath;

  const DisplayImagePage({super.key, required this.imagePath});

  Future<void> _requestPermission(BuildContext context) async {
    if (await Permission.storage.request().isGranted) {
      // Izin diberikan
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin penyimpanan tidak diberikan')),
      );
    }
  }

  Future<void> _downloadImage(BuildContext context) async {
    await _requestPermission(context);
    if (!await Permission.storage.isGranted) return;

    try {
      Directory? directory = await getExternalStorageDirectory();
      String downloadsPath = '${directory!.path}/Download';
      await Directory(downloadsPath).create(recursive: true);

      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      String filePath = '$downloadsPath/$fileName';

      await File(imagePath).copy(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gambar berhasil diunduh: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunduh gambar: $e')),
      );
    }
  }

  Future<String> _getDownloadUrl(String path) async {
    try {
      final ref = FirebaseStorage.instance.ref(path);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error getting download URL: $e");
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Gambar'),
        backgroundColor: secondaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  _downloadImage(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5DADA),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Download',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 300,
              child: ElevatedButton(
                onPressed: () async {
                  final username = "test_user"; // Replace with actual username
                  final path = 'history/$username/${imagePath.split('/').last}';
                  String downloadUrl = await _getDownloadUrl(path);
                  if (downloadUrl.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('URL: $downloadUrl')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gagal mendapatkan URL')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5DADA),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Dapatkan URL Download',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
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