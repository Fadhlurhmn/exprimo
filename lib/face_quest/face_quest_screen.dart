import 'package:exprimo/constants.dart';
import 'package:exprimo/face_quest/expression_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
// import 'dart:math' as math;

class FaceQuestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
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
  final List<ExpressionItem> expressions = [
    ExpressionItem('Senang', 'Mudah', true),
    ExpressionItem('Marah', 'Mudah', false),
    ExpressionItem('Kaget', 'Mudah', false),
    ExpressionItem('Kesal', 'Menengah', false),
    ExpressionItem('Mengejek', 'Menengah', false),
    ExpressionItem('Capek', 'Menengah', false),
  ];

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
        backgroundImage:
            AssetImage('assets/images/${item.name.toLowerCase()}.png'),
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
              Text('Apakah yakin ingin memulai?',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD19F9F),
                  foregroundColor: Colors.black,
                ),
                label: Text("Mulai"),
                icon: Icon(
                  Icons.play_arrow,
                  color: Colors.black,
                ),
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

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ExpressionResultScreen(
            imageFile: _capturedImage!,
            detectedExpression: 'Happy',
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
                'assets/images/${widget.expressionItem.name.toLowerCase()}.png', // Gunakan gambar sesuai ekspresi
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
            child: Text("Capture Image"),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCamera,
        child: Icon(Icons.flip_camera_android),
      ),
    );
  }

  void _navigateToResultScreen() async {
    if (!_controller!.value.isInitialized) {
      return;
    }
    try {
      final image = await _controller!.takePicture();
      File capturedImage = File(image.path);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ExpressionResultScreen(
            imageFile: capturedImage,
            detectedExpression: widget.expressionItem.name,
          ),
        ),
      );
    } catch (e) {
      print('Error capturing image: $e');
    }
  }
}