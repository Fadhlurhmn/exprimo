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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId != null) {
      try {
        final usersRef = FirebaseDatabase.instance.ref('users');
        DatabaseEvent event = await usersRef.child(userId!).once();
        if (event.snapshot.value != null) {
          Map userData = event.snapshot.value as Map;
          setState(() {
            username = userData['username'] ?? 'user-example';
            String date = DateTime.now().toIso8601String().split("T")[0];
            String time = DateTime.now()
                .toIso8601String()
                .split("T")[1]
                .split(".")[0]
                .replaceAll(":", "-");
            imageName = '$username' + '_' + '$date' + '_' + '$time' + '.jpg';
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data pengguna.')),
        );
      }
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (username == null || imageName == null) return;
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('history/$username')
          .child(imageName!);
      await storageRef.putFile(File(widget.imagePath));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gambar berhasil diunggah ke Firebase Storage.')),
      );
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Future<void> _scanImage() async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.73.135:8005/detect-expression/'),
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
          SnackBar(content: Text('Scan berhasil. Gambar ditampilkan.')),
        );
      }
    } catch (e) {
      print("Error scanning image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tinjau Gambar')),
      body: username == null || imageName == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: scannedImage != null
                        ? Image.file(scannedImage!)
                        : Image.file(File(widget.imagePath)),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _uploadImageToFirebase,
                      child: Text('Simpan Gambar'),
                    ),
                    ElevatedButton(
                      onPressed: _scanImage,
                      child: Text('Scan Gambar'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
    );
  }
}
