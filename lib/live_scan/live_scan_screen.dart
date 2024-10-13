import 'dart:io';
import 'package:camera/camera.dart';
import 'package:exprimo/constants.dart';
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

  Future<File?> takePicture() async {
    Directory root = await getTemporaryDirectory();
    String directoryPath = '${root.path}/Guided_Camera';
    await Directory(directoryPath).create(recursive: true);
    String filePath = '$directoryPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      await controller.takePicture();
    } catch (e) {
      return null;
    }

    return File(filePath);
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * controller.value.aspectRatio,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi), // Balik tampilan kamera depan
                        child: CameraPreview(controller),
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 120,
                      margin: EdgeInsets.only(top: 80),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5DADA), // Warna tombol
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Center(
                        child: Container(
                          width: 90, // Diameter lingkaran putih
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white, // Warna lingkaran putih
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              await takePicture();
                            },
                            
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(), backgroundColor: Colors.transparent, // Membuat latar belakang tombol transparan
                              shadowColor: Colors.transparent, // Menghilangkan bayangan tombol
                            ),
                            child: null, // Anda bisa menambahkan ikon di sini
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
