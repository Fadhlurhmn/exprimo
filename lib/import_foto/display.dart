import 'dart:io';
import 'package:exprimo/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

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
  late String downloadUrl = "";
  bool isLoading = true;
  File? processedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

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
            String time =
                DateTime.now().toIso8601String().split("T")[1].split(".")[0];
            time = time.replaceAll(":", "-");
            imageName = '$username' + '_' + '$date' + '_' + '$time' + '.jpg';
          }
        });
      }
    }

    // Upload gambar asli dan mulai deteksi ekspresi
    if (username != null && widget.imagePath.isNotEmpty) {
      await _uploadImageToFirebase();
      await _detectExpression(); // Memanggil fungsi deteksi ekspresi
    }
  }

  Future<void> _uploadImageToFirebase() async {
    try {
      if (username == null || widget.imagePath.isEmpty) {
        print('Username atau path gambar tidak valid.');
        return;
      }

      final storageRef =
          FirebaseStorage.instance.ref().child('history/$username/$imageName');
      await storageRef.putFile(File(widget.imagePath));

      print("Gambar asli berhasil di-upload.");
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal meng-upload gambar.')),
      );
    }
  }

  Future<void> _uploadProcessedImageToFirebase() async {
    try {
      if (username == null || processedImage == null) {
        print('Username atau processedImage tidak valid.');
        return;
      }

      final storageRef =
          FirebaseStorage.instance.ref().child('history/$username/$imageName');
      await storageRef.putFile(processedImage!);

      print("Gambar hasil bounding box berhasil di-upload.");
    } catch (e) {
      print("Error uploading processed image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal meng-upload gambar hasil bounding box.')),
      );
    }
  }

  Future<void> _detectExpression() async {
    try {
      setState(() {
        isLoading = true;
      });

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://192.168.1.13:8000/detect-expression/'), // URL API Anda
      );
      request.files
          .add(await http.MultipartFile.fromPath('file', widget.imagePath));

      final response = await request.send();
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        final directory = await getApplicationDocumentsDirectory();
        final resultPath = '${directory.path}/processed_${imageName}';
        final file = File(resultPath);
        await file.writeAsBytes(bytes);

        setState(() {
          processedImage = file;
          isLoading = false;
        });

        // Setelah gambar diproses, upload ke Firebase
        await _uploadProcessedImageToFirebase();
      } else {
        print("Error from API: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal mendeteksi ekspresi. Coba lagi nanti.')),
        );
      }
    } catch (e) {
      print("Error during expression detection: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat memproses gambar.')),
      );
    }
  }

  Future<void> _downloadImageToLocal() async {
    try {
      if (processedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gambar tidak tersedia untuk diunduh.')),
        );
        return;
      }

      // Meminta izin penyimpanan
      var status = await Permission.storage.request();
      if (status.isGranted) {
        final directory = await getExternalStorageDirectory();
        final path =
            '${directory?.path}/${processedImage!.path.split('/').last}';
        final fileToSave = File(path);
        await processedImage!.copy(fileToSave.path);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gambar berhasil diunduh ke $path')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izin penyimpanan tidak diberikan.')),
        );
      }
    } catch (e) {
      print("Error downloading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat mengunduh gambar.')),
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
            child: isLoading
                ? CircularProgressIndicator()
                : processedImage != null
                    ? Image.file(
                        processedImage!,
                        width: screenWidth * 0.75,
                        height: MediaQuery.of(context).size.height * 0.75,
                        fit: BoxFit.contain,
                      )
                    : Image.file(
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
                    onPressed:
                        processedImage != null ? _downloadImageToLocal : null,
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
