//live_scan/display.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DisplayPage extends StatefulWidget {
  final String imagePath;

  const DisplayPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  String? userId;
  String? username;
  String? imageName;
  File? scannedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        userId = prefs.getString('userId');
        if (userId != null) {
          String date = DateTime.now().toIso8601String().split("T")[0];
          String time = DateTime.now()
              .toIso8601String()
              .split("T")[1]
              .split(".")[0]
              .replaceAll(":", "-");
          imageName = '${date}_${time}.jpg';
        }
      });
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (userId == null || imageName == null) return;

    setState(() => isLoading = true);
    try {
      final file = File(widget.imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found');
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('history/$userId')
          .child(imageName!);

      await storageRef.putFile(file);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Gambar berhasil diunggah ke Firebase Storage.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunggah gambar: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _scanImage() async {
    setState(() => isLoading = true);
    try {
      final file = File(widget.imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://modelekspresi-production.up.railway.app/detect-expression/'),
      );

      request.files
          .add(await http.MultipartFile.fromPath('file', widget.imagePath));

      final response = await request.send();
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/scanned_image.jpg');
        await file.writeAsBytes(bytes);

        setState(() {
          scannedImage = file;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scan berhasil. Gambar ditampilkan.')),
        );
      } else {
        throw Exception('Failed to scan image: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memindai gambar: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Tinjau Gambar')),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder<bool>(
                    future: File(widget.imagePath).exists(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError || snapshot.data == false) {
                        return const Center(
                            child: Text('Gambar tidak ditemukan'));
                      }

                      return Image.file(
                        scannedImage ?? File(widget.imagePath),
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: isLoading ? null : _uploadImageToFirebase,
                      child: const Text('Simpan Gambar'),
                    ),
                    ElevatedButton(
                      onPressed: isLoading ? null : _scanImage,
                      child: const Text('Scan Gambar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
