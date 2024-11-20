import 'dart:io';
import 'package:camera/camera.dart';
import 'package:exprimo/constants.dart';
import 'package:exprimo/live_scan/display.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage
import 'dart:math' as math;

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
      ResolutionPreset.medium,
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

  Future<String?> takePictureAndUpload() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Controller not initialized');
      return null;
    }

    try {
      XFile imageFile = await _controller!.takePicture();

      // Simpan sementara ke lokal
      Directory root = await getTemporaryDirectory();
      String directoryPath = '${root.path}/Guided_Camera';
      await Directory(directoryPath).create(recursive: true);
      String localFilePath = '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.jpg';
      File localFile = await File(imageFile.path).copy(localFilePath);

      // Upload ke Firebase
      String firebasePath = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref(firebasePath);
      await storageRef.putFile(localFile);

      // Ambil URL publik untuk unduhan
      String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error taking or uploading picture: $e');
      return null;
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
                    SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width * _controller!.value.aspectRatio,
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
                                border: Border.all(color: Colors.black, width: 1),
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  String? imageURL = await takePictureAndUpload();
                                  if (imageURL != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DisplayImagePage(imageURL: imageURL),
                                      ),
                                    );
                                  }
                                },
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
                            _selectedCameraIndex == 0 ? Icons.camera_front : Icons.camera_rear,
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
