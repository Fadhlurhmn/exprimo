// display.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exprimo/navigation.dart';

class DisplayPage extends StatefulWidget {
  final String originalImagePath;
  final String processedImagePath;

  const DisplayPage({
    Key? key,
    required this.originalImagePath,
    required this.processedImagePath,
  }) : super(key: key);

  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  String? userId;
  String? imageName;
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
      final file = File(widget.processedImagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found');
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('history/$userId')
          .child(imageName!);

      await storageRef.putFile(file);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Gambar berhasil diunggah ke Firebase Storage.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunggah gambar: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Navigation_menu(), // Ganti dengan widget Navigation_menu
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hasil Scan'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Navigation_menu(), // Ganti dengan widget Navigation_menu
                ),
              );
            },
          ),
        ),
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.file(
                      File(widget.processedImagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _uploadImageToFirebase,
                    child: const Text('Simpan Gambar'),
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
      ),
    );
  }
}
