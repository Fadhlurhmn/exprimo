import 'dart:io';
import 'package:exprimo/constants.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'package:exprimo/live_scan/display.dart';
import 'package:http/http.dart' as http;

class LiveScanPage extends StatefulWidget {
  @override
  _LiveScanPageState createState() => _LiveScanPageState();
}

class _LiveScanPageState extends State<LiveScanPage> {
  late List<CameraDescription> cameras;
  CameraController? _controller;
  int _selectedCameraIndex = 1;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _setCamera(_selectedCameraIndex);
    } else {
      print('No cameras found');
    }
  }

  void _setCamera(int cameraIndex) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.high,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _uploadImageToFirebase(String filePath, String username) async {
    try {
      final imageName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('history/$username/$imageName');

      await storageRef.putFile(File(filePath));

      print("Gambar berhasil di-upload ke Firebase Storage.");
    } catch (e) {
      print("Gagal meng-upload gambar ke Firebase: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal meng-upload gambar.')),
      );
    }
  }

  Future<File?> _processImage(String imagePath) async {
    try {
      // Kode yang berhubungan dengan API dikomentari
      /*
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.x.x:8000/detect-expression/'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      final response = await request.send();
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        final directory = await getApplicationDocumentsDirectory();
        final processedImagePath =
            '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File(processedImagePath);
        await file.writeAsBytes(bytes);
        return file;
      } else {
        print("Error from API: ${response.statusCode}");
      }
      */

      // Untuk sementara, gunakan gambar asli sebagai hasil pemrosesan
      print("Simulating processed image using the original file path.");
      return File(imagePath);
    } catch (e) {
      print("Error processing image: $e");
    }
    return null;
  }

  Future<void> _takeAndProcessPicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Controller tidak diinisialisasi');
      return;
    }

    try {
      // Ambil gambar
      Directory root = await getTemporaryDirectory();
      String directoryPath = '${root.path}/Guided_Camera';
      await Directory(directoryPath).create(recursive: true);
      String filePath =
          '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

      XFile imageFile = await _controller!.takePicture();
      await File(imageFile.path).copy(filePath);

      // Ambil username dari SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString('username');

      if (username != null) {
        // Upload gambar ke Firebase
        await _uploadImageToFirebase(filePath, username);

        // Proses gambar (API sementara dikomentari)
        File? processedImage = await _processImage(filePath);

        if (processedImage != null) {
          // Navigasi ke halaman hasil dengan gambar asli
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DisplayImagePage(imagePath: processedImage.path),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memproses gambar.')),
          );
        }
      } else {
        print('Username tidak ditemukan. Pastikan pengguna telah login.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: Username tidak ditemukan.')),
        );
      }
    } catch (e) {
      print('Error mengambil gambar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar.')),
      );
    }
  }

  void _toggleCamera() {
    _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras.length;
    _setCamera(_selectedCameraIndex);
  }

  void _goBack() {
    Navigator.pop(context); // Navigasi kembali ke halaman sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isCameraInitialized
          ? Stack(
              children: [
                Column(
                  children: [
                    // SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width *
                              _controller!.value.aspectRatio,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: CameraPreview(_controller!),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30), // Spacing for the camera buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Tombol Kembali
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 50,
                            color: secondaryColor,
                          ),
                          onPressed: _goBack,
                        ),
                        // Tombol Ambil Gambar
                        Container(
                          width: 120,
                          height: 120,
                          margin: EdgeInsets.only(top: 20),
                          decoration: BoxDecoration(
                            color: Color(0xFFF5DADA),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Center(
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.black, width: 1),
                              ),
                              child: ElevatedButton(
                                onPressed: _takeAndProcessPicture,
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: null,
                              ),
                            ),
                          ),
                        ),
                        // Tombol Ganti Kamera
                        IconButton(
                          icon: Icon(
                            _selectedCameraIndex == 0
                                ? Icons.camera_front
                                : Icons.camera_rear,
                            size: 50,
                            color: secondaryColor,
                          ),
                          onPressed: _toggleCamera,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
