import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'scanfoto.dart'; // Pastikan file ini ada di direktori yang benar

class ImportFotoScreen extends StatefulWidget {
  @override
  _ImportFotoScreenState createState() => _ImportFotoScreenState();
}

class _ImportFotoScreenState extends State<ImportFotoScreen> {
  File? _imageFile;

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk mengirim gambar ke server Flask
  Future<void> _sendImageToFlask(File imageFile) async {
    final String flaskUrl = 'http://192.168.1.9:5000/predict'; // Endpoint Flask

    try {
      // Membuat form data untuk dikirim ke server
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path,
            filename: 'uploaded_image.jpg'),
      });

      // Kirim permintaan POST ke server Flask
      Response response = await Dio().post(flaskUrl, data: formData);

      if (response.statusCode == 200) {
        final detectedExpression = response.data['expression'];
        print("Ekspresi terdeteksi: $detectedExpression");

        // Navigasi ke halaman hasil
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              imageFile: imageFile,
              detectedExpression: detectedExpression,
            ),
          ),
        );
      } else {
        print("Error: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Gagal menganalisis gambar. Coba lagi nanti.")),
        );
      }
    } catch (e) {
      print("Gagal mengirim gambar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan saat mengirim gambar.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Import Foto'),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: _imageFile != null
                  ? () {
                      // Kirim gambar ke Flask
                      _sendImageToFlask(_imageFile!);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Scan'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEFBEBE),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _imageFile == null
                ? Container(
                    height: 200,
                    width: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  )
                : Image.file(
                    _imageFile!,
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height * 0.75,
                    fit: BoxFit.contain,
                  ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: const Color(0xFFEFBEBE),
              ),
              child: const Text(
                'Pilih Foto dari Galeri',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
