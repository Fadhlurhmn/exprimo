import 'dart:io';
import 'package:exprimo/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

class DisplayImagePage extends StatefulWidget {
  final String imagePath;

  const DisplayImagePage({super.key, required this.imagePath});

  @override
  _DisplayImagePageState createState() => _DisplayImagePageState();
}

class _DisplayImagePageState extends State<DisplayImagePage> {
  String? username;
  String? userId;
  DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");
  late String imageName;
  late String downloadUrl = ""; // URL gambar dari Firebase
  bool isLoading = true; // Status loading

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Memuat data pengguna dan mengatur nama file gambar
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (userId != null) {
      DatabaseEvent event = await usersRef.child(userId!).once();
      if (event.snapshot.value != null) {
        Map userData = event.snapshot.value as Map;
        setState(() {
          username = userData['username'];
          if (username != null) {
            String date = DateTime.now().toIso8601String().split("T")[0];
            String time = DateTime.now().toIso8601String().split("T")[1].split(".")[0];
            time = time.replaceAll(":", "-");
            imageName = '$username' + '_' + '$date' + '_' + '$time' + '.jpg';
          }
        });
      }
    }

    // Setelah mendapatkan username, upload gambar ke Firebase
    if (username != null && widget.imagePath.isNotEmpty) {
      await _uploadImageToFirebase();
      await _getImageUrlFromFirebase();
    }
  }

  // Upload gambar ke Firebase
  Future<void> _uploadImageToFirebase() async {
    try {
      // Memastikan username dan imagePath valid
      if (username == null || widget.imagePath.isEmpty) {
        print('Username atau path gambar tidak valid.');
        return;
      }

      final storageRef = FirebaseStorage.instance.ref().child('history/$username/$imageName');
      await storageRef.putFile(File(widget.imagePath));

      print("Gambar berhasil di-upload.");
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal meng-upload gambar.')),
      );
    }
  }

  // Mendapatkan URL gambar dari Firebase
  Future<void> _getImageUrlFromFirebase() async {
    try {
      if (username == null) {
        throw Exception('Username tidak ditemukan.');
      }
      
      final storageRef = FirebaseStorage.instance.ref().child('history/$username/$imageName');
      String url = await storageRef.getDownloadURL();
      setState(() {
        downloadUrl = url;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching image URL: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Meminta izin akses penyimpanan
  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      // Meminta izin jika belum diberikan
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  // Mendownload gambar ke penyimpanan lokal ponsel
  Future<void> _downloadImageToLocal() async {
    if (downloadUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('URL gambar belum tersedia. Coba lagi nanti.')) 
      );
      return;
    }

    // Memastikan izin telah diberikan
    bool isPermissionGranted = await _requestStoragePermission();
    if (!isPermissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Izin penyimpanan diperlukan untuk mendownload gambar.')),
      );
      return;
    }

    try {
      Directory? directory = await getExternalStorageDirectory();
      String newPath = "";
      List<String> paths = directory!.path.split("/");

      for (int i = 1; i < paths.length; i++) {
        String folder = paths[i];
        if (folder != "Android") {
          newPath += "/$folder";
        } else {
          break;
        }
      }
      newPath += "/Download"; // Menyimpan di folder Download
      Directory downloadDir = Directory(newPath);
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      String filePath = '${downloadDir.path}/$imageName';

      Dio dio = Dio();
      await dio.download(downloadUrl, filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gambar berhasil diunduh ke $filePath')),
      );

      print("Gambar berhasil diunduh ke $filePath");
    } catch (e) {
      print("Error downloading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunduh gambar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _downloadImageToLocal,
                    child: Text(
                      'Download Gambar',
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
          Spacer(flex: 2),
        ],
      ),
    );
  }
}
