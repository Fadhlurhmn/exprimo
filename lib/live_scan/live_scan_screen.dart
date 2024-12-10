// live_scan_screen.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

import 'display.dart';

class LiveScanPage extends StatefulWidget {
  @override
  _LiveScanPageState createState() => _LiveScanPageState();
}

class _LiveScanPageState extends State<LiveScanPage> {
  late List<CameraDescription> cameras;
  CameraController? _controller;
  int _selectedCameraIndex = 1;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String? _tempImagePath; // Added to store temporary image path

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _setCamera(_selectedCameraIndex);
      } else {
        print('No cameras found');
      }
    } catch (e) {
      print('Error initializing camera: $e');
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

  Future<void> _processAndNavigate(String imagePath) async {
    setState(() {
      _isProcessing = true;
      _tempImagePath = imagePath; // Store the temporary image path
    });

    try {
      // Send image to API
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://modelekspresi-production.up.railway.app/detect-expression/'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      final response = await request.send();
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        final tempDir = await getTemporaryDirectory();
        final processedFile = File('${tempDir.path}/processed_image.jpg');
        await processedFile.writeAsBytes(bytes);

        if (!mounted) return;

        // Navigate to display page with both original and processed images
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayPage(
              originalImagePath: imagePath,
              processedImagePath: processedFile.path,
            ),
          ),
        );
      } else {
        throw Exception('Failed to process image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error processing image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memproses gambar: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Controller tidak diinisialisasi');
      return;
    }

    try {
      // Create temporary directory for images
      Directory root = await getTemporaryDirectory();
      String directoryPath = '${root.path}/CapturedImages';
      await Directory(directoryPath).create(recursive: true);

      // Generate unique filename
      String filePath =
          '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Capture and save image
      XFile imageFile = await _controller!.takePicture();
      await File(imageFile.path).copy(filePath);

      // Process and navigate
      await _processAndNavigate(filePath);
    } catch (e) {
      print('Error mengambil gambar: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar.')),
      );
    }
  }

  void _toggleCamera() {
    _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras.length;
    _setCamera(_selectedCameraIndex);
  }

  @override
  void dispose() {
    _controller?.dispose();
    // Clean up temporary images
    if (_tempImagePath != null) {
      File(_tempImagePath!)
          .delete()
          .catchError((e) => print('Error deleting temp file: $e'));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Reset camera when going back
        await _initializeCamera();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              if (_isCameraInitialized)
                Column(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: CameraPreview(_controller!),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.camera,
                            size: 50,
                            color: Colors.white,
                          ),
                          onPressed: _isProcessing ? null : _takePicture,
                        ),
                        IconButton(
                          icon: Icon(
                            _selectedCameraIndex == 0
                                ? Icons.camera_front
                                : Icons.camera_rear,
                            size: 50,
                            color: Colors.white,
                          ),
                          onPressed: _isProcessing ? null : _toggleCamera,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                )
              else
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              if (_isProcessing)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
