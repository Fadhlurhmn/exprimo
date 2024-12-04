//live_scan_screen.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

import 'display.dart'; // Import halaman display untuk menampilkan gambar

class LiveScanPage extends StatefulWidget {
  @override
  _LiveScanPageState createState() => _LiveScanPageState();
}

class _LiveScanPageState extends State<LiveScanPage> {
  late List<CameraDescription> cameras;
  CameraController? _controller;
  int _selectedCameraIndex = 1;
  bool _isCameraInitialized = false;
  String? capturedImagePath;

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

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Controller not initialized');
      return;
    }

    try {
      Directory root = await getTemporaryDirectory();
      String directoryPath = '${root.path}/CapturedImages';
      await Directory(directoryPath).create(recursive: true);
      String filePath =
          '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

      XFile imageFile = await _controller!.takePicture();
      await File(imageFile.path).copy(filePath);

      setState(() {
        capturedImagePath = filePath;
      });

      // Navigasi ke halaman display untuk menampilkan gambar yang diambil
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayPage(imagePath: capturedImagePath!),
        ),
      );
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  void _toggleCamera() {
    _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras.length;
    _setCamera(_selectedCameraIndex);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.camera,
                            size: 50,
                            color: Colors.black,
                          ),
                          onPressed: _takePicture,
                        ),
                        IconButton(
                          icon: Icon(
                            _selectedCameraIndex == 0
                                ? Icons.camera_front
                                : Icons.camera_rear,
                            size: 50,
                            color: Colors.black,
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
