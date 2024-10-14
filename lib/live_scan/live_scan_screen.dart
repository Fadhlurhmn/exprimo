import 'dart:io';
import 'package:camera/camera.dart';
import 'package:exprimo/live_scan/display.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

class LiveScanPage extends StatefulWidget {
  @override
  _LiveScanPageState createState() => _LiveScanPageState();
}

class _LiveScanPageState extends State<LiveScanPage> {
  late CameraController controller;

  Future<void> initializeCamera() async {
    var cameras = await availableCameras();
    controller = CameraController(cameras[1], ResolutionPreset.medium);
    await controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<String?> takePicture() async {
    Directory root = await getTemporaryDirectory();
    String directoryPath = '${root.path}/Guided_Camera';
    await Directory(directoryPath).create(recursive: true); // Ensure directory exists

    String filePath = '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      XFile imageFile = await controller.takePicture();
      await File(imageFile.path).copy(filePath); // Copy image to desired path
      return filePath; // Return the new file path
    } catch (e) {
      print('Error taking picture: $e'); // Log any errors
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: initializeCamera(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: 40),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20), // Set rounded corners
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * controller.value.aspectRatio,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi), // Flip front camera preview
                          child: CameraPreview(controller),
                        ),
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 120,
                      margin: EdgeInsets.only(top: 65),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5DADA), // Button color
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Center(
                        child: Container(
                          width: 90, // Inner white circle diameter
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white, // White inner circle color
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              String? imagePath = await takePicture();
                              if (imagePath != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DisplayImagePage(imagePath: imagePath),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              backgroundColor: Colors.transparent, // Transparent background
                              shadowColor: Colors.transparent, // No shadow
                            ),
                            child: null, // Optional: Add an icon here
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
