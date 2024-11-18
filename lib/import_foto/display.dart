import 'dart:io';
import 'package:exprimo/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisplayImagePage extends StatefulWidget {
  final String imagePath;

  const DisplayImagePage({super.key, required this.imagePath});

  @override
  _DisplayImagePageState createState() => _DisplayImagePageState();
}

class _DisplayImagePageState extends State<DisplayImagePage> {
  String? username;
  String? userId; // ID pengguna yang sedang login
  DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");
  late String imageName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fungsi untuk memuat userId dan username dari SharedPreferences dan Firebase
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId'); // Ambil userId dari SharedPreferences

    if (userId != null) {
      // Ambil username dari Firebase menggunakan userId
      DatabaseEvent event = await usersRef.child(userId!).once();
      if (event.snapshot.value != null) {
        Map userData = event.snapshot.value as Map;
        setState(() {
          username = userData['username']; // Ambil username dari data pengguna
          // Membuat nama file dengan format: username_tanggal_jam.jpg
          if (username != null) {
            String date = DateTime.now().toIso8601String().split("T")[0]; // Format yyyy-MM-dd
            String time = DateTime.now().toIso8601String().split("T")[1].split(".")[0]; // Format HH:mm:ss
            time = time.replaceAll(":", "-"); // Ganti ':' dengan '-' agar aman untuk nama file
            imageName = '$username' + '_' + '$date' + '_' + '$time' + '.jpg';
          }
        });
      }
    }

    // Panggil fungsi upload gambar setelah username diambil
    if (username != null) {
      _uploadImageToFirebase();
    }
  }

  // Fungsi untuk meng-upload gambar ke Firebase Storage
  Future<void> _uploadImageToFirebase() async {
    if (username != null && userId != null) {
      try {
        // Ambil referensi Firebase Storage untuk upload gambar
        final storageRef = FirebaseStorage.instance.ref().child('import/$username/$imageName');
        
        // Upload file gambar
        await storageRef.putFile(File(widget.imagePath));

        // Ambil URL gambar setelah di-upload
        String downloadUrl = await storageRef.getDownloadURL();

        // Simpan URL gambar di Firebase Realtime Database
        await usersRef.child(userId!).update({
          'profileImageUrl': downloadUrl,
        });

        print("Gambar berhasil di-upload ke Firebase: $downloadUrl");
      } catch (e) {
        print("Error uploading image: $e");
      }
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
      body: Column(
        children: [
          Spacer(flex: 1),
          Center(
            child: Image.file(
              File(widget.imagePath),
              width: screenWidth * 0.75,
              height: MediaQuery.of(context).size.height * 0.75,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: 300,
            child: ElevatedButton(
              onPressed: () {
                _uploadImageToFirebase();
              },
              child: Text(
                'Upload Gambar',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
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
          Spacer(flex: 2),
        ],
      ),
    );
  }
}
