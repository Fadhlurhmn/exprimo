import 'package:exprimo/constants.dart';
import 'package:exprimo/face_quest/expression_result_screen.dart';
import 'package:exprimo/homepage_screen.dart';
import 'package:exprimo/navigation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:math' as math;

class FaceQuestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Navigation_menu(),
              ),
            );
          },
        ),
        title: Text('Face Quest'),
      ),
      body: FaceQuestList(),
    );
  }
}

class FaceQuestList extends StatefulWidget {
  @override
  _FaceQuestListState createState() => _FaceQuestListState();
}

class _FaceQuestListState extends State<FaceQuestList> {
  String userId = "";
  List<ExpressionItem> expressions = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? "";
    });

    if (userId.isNotEmpty) {
      _loadExpressionItems();
    }
  }

  Future<void> _loadExpressionItems() async {
    // Ambil data ekspresi berdasarkan userId dari Firebase
    final userRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(userId)
        .child('expressionItems');

    // Menggunakan get() untuk mengambil data
    DataSnapshot snapshot = await userRef.get();

    final data = snapshot.value;

    if (data != null) {
      // Memastikan data adalah Map dan mengonversinya ke list ExpressionItem
      setState(() {
        expressions = (data as Map).values.map((item) {
          return ExpressionItem(
            item['name'] ?? '', // Pastikan properti ada
            item['difficulty'] ?? '', // Pastikan properti ada
            item['isComplete'] ?? false, // Pastikan properti ada
          );
        }).toList();
      });
    }
  }

  String selectedFilter = 'Semua';

  void _setSelectedFilter(String filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<ExpressionItem> filteredExpressions = expressions.where((item) {
      if (selectedFilter == 'Completed') {
        return item.isComplete;
      } else if (selectedFilter != 'Semua' &&
          item.difficulty != selectedFilter) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Ayo latih dan asah ekspresimu di Face Quest sekarang!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => _setSelectedFilter('Semua'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  backgroundColor: selectedFilter == 'Semua'
                      ? secondaryColor
                      : const Color.fromARGB(255, 255, 255, 255),
                  textStyle: TextStyle(fontSize: 12),
                ),
                child: Text('Semua'),
              ),
              ElevatedButton(
                onPressed: () => _setSelectedFilter('Mudah'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  backgroundColor: selectedFilter == 'Mudah'
                      ? secondaryColor
                      : const Color.fromARGB(255, 255, 254, 254),
                  textStyle: TextStyle(fontSize: 12),
                ),
                child: Text('Mudah'),
              ),
              ElevatedButton(
                onPressed: () => _setSelectedFilter('Menengah'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  backgroundColor: selectedFilter == 'Menengah'
                      ? secondaryColor
                      : const Color.fromARGB(255, 255, 255, 255),
                  textStyle: TextStyle(fontSize: 12),
                ),
                child: Text('Menengah'),
              ),
              ElevatedButton(
                onPressed: () => _setSelectedFilter('Completed'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  backgroundColor: selectedFilter == 'Completed'
                      ? secondaryColor
                      : const Color.fromARGB(255, 255, 255, 255),
                  textStyle: TextStyle(fontSize: 12),
                ),
                child: Text('Completed'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: filteredExpressions
                .map((item) => ExpressionListItem(item: item))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class ExpressionListItem extends StatelessWidget {
  final ExpressionItem item;

  const ExpressionListItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: AssetImage('assets/images/${item.name}.jpg'),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
      title: Text(
        'Ekspresi ${item.name}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tingkat kesulitan: ${item.difficulty}'),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.isComplete ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.isComplete ? 'Complete' : 'Incomplete',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
      trailing: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFD19F9F),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            IconButton(
              icon: Icon(Icons.play_arrow, color: Colors.white, size: 18),
              onPressed: () => _showPlayDialog(context),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  void _showPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Apakah yakin ingin memulai?'),
              SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD19F9F),
                  foregroundColor: Colors.black,
                ),
                label: Text("Mulai"),
                icon: Icon(Icons.play_arrow, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraScreen(
                        expressionItem: item, // Kirim item ekspresi
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ExpressionItem {
  final String name;
  final String difficulty;
  final bool isComplete;

  ExpressionItem(this.name, this.difficulty, this.isComplete);
}

class CameraScreen extends StatefulWidget {
  final ExpressionItem expressionItem; // Tambahkan parameter ini

  const CameraScreen({Key? key, required this.expressionItem})
      : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<CameraDescription> cameras;
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _setCamera(_selectedCameraIndex);
  }

  void _setCamera(int cameraIndex) {
    if (_controller != null) {
      _controller!.dispose();
    }
    _controller = CameraController(
      cameras[cameraIndex],
      ResolutionPreset.medium,
    );

    _controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleCamera() {
    _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras.length;
    _setCamera(_selectedCameraIndex);
  }

  Future<void> _captureImage() async {
    if (!_controller!.value.isInitialized) {
      return;
    }
    try {
      final image = await _controller!.takePicture();
      setState(() {
        _capturedImage = File(image.path);
      });

      // Mengirim gambar ke server untuk deteksi
      String? detectedExpression = await _detectExpression(_capturedImage!);

      if (detectedExpression == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to detect expression')),
        );
        return;
      }

      // Bandingkan ekspresi yang dideteksi dengan ekspresi yang diharapkan
      bool isExpressionMatched = detectedExpression.toLowerCase() ==
          widget.expressionItem.name.toLowerCase();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ExpressionResultScreen(
            imageFile: _capturedImage!,
            detectedExpression: detectedExpression,
            expectedExpression: widget.expressionItem.name,
            isMatched:
                isExpressionMatched, // Kirim hasil evaluasi ke layar berikutnya
          ),
        ),
      );
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    bool isFrontCamera = cameras[_selectedCameraIndex].lensDirection ==
        CameraLensDirection.front;

    return Scaffold(
      appBar: AppBar(title: Text('Camera')),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Image.asset(
                'assets/images/${widget.expressionItem.name}.jpg', // Gunakan gambar sesuai ekspresi
                width: 100,
                height: 100,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AspectRatio(
                  aspectRatio: 9 / 16,
                  child: _capturedImage == null
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..scale(
                              isFrontCamera ? -1.0 : 1.0,
                              1.0,
                            ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CameraPreview(_controller!),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            _capturedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _captureImage,
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding:
                  EdgeInsets.all(0), // Tidak ada jarak tambahan untuk padding
              backgroundColor: Colors.transparent, // Latar belakang transparan
              shadowColor: Colors.transparent, // Tanpa bayangan
            ),
            child: Container(
              width: 80, // Ukuran total lingkaran
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.pink.shade100,
                    Colors.white
                  ], // Efek gradien warna
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                    color: Colors.black, width: 1), // Garis lingkaran luar
              ),
              child: Center(
                child: Container(
                  width: 60, // Ukuran lingkaran dalam
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white, // Warna lingkaran dalam
                    border: Border.all(
                        color: Colors.black, width: 1), // Garis lingkaran dalam
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCamera,
        child: Icon(Icons.flip_camera_android),
      ),
    );
  }

  Future<String?> _detectExpression(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.62.249:8006/get-expression-label/'),
      );
      request.files.add(await http.MultipartFile.fromPath(
        'file', // Sesuaikan dengan parameter file yang diterima server
        imageFile.path,
      ));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);
        return jsonResponse['detected_expression']
            as String; // Pastikan key sesuai dengan API Anda
      } else {
        print('Failed to detect expression: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error detecting expression: $e');
      return null;
    }
  }

  // void _navigateToResultScreen() async {
  //   if (!_controller!.value.isInitialized) {
  //     return;
  //   }
  //   try {
  //     final image = await _controller!.takePicture();
  //     File capturedImage = File(image.path);

  //     // Menggunakan nama ekspresi yang diharapkan dari item ekspresi yang dipilih
  //     String expectedExpression = widget.expressionItem.name;

  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (context) => ExpressionResultScreen(
  //           imageFile: capturedImage,
  //           detectedExpression:
  //               expectedExpression, // Anda mungkin ingin mengganti ini dengan hasil deteksi ekspresi yang sebenarnya
  //           expectedExpression:
  //               expectedExpression, // Kirimkan ekspresi yang diharapkan
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     print('Error capturing image: $e');
  //   }
  // }
}
