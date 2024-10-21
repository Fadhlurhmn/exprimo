import 'package:exprimo/face_quest/expression_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:math' as math; // Tambahkan ini untuk transformasi

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
                builder: (context) => FaceQuestScreen(),
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

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<CameraDescription> cameras;
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  File? _capturedImage;

  get isFrontCamera => null;

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

      // After capturing, navigate to the result screen and pass the image
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ExpressionResultScreen(
            imageFile: _capturedImage!,
            detectedExpression:
                'Happy', // Replace this with actual detected expression logic
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
              child: Text(
                '🙂',
                style: TextStyle(fontSize: 50),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _capturedImage == null
                ? Transform(
                    alignment: Alignment.center,
                    transform: isFrontCamera
                        ? Matrix4.rotationY(math.pi)
                        : Matrix4.identity(),
                    child: CameraPreview(_controller!),
                  )
                : Image.file(_capturedImage!),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.switch_camera),
                onPressed: _toggleCamera,
              ),
              IconButton(
                icon: Icon(Icons.camera),
                onPressed: _captureImage,
              ),
            ],
          ),
        ],
      ),
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

  String selectedDifficulty = 'Semua';
  bool showCompleted = false;

  @override
  Widget build(BuildContext context) {
    List<ExpressionItem> filteredExpressions = expressions.where((item) {
      if (selectedDifficulty != 'Semua' &&
          item.difficulty != selectedDifficulty) {
        return false;
      }
      if (!showCompleted && item.isComplete) {
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
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: selectedDifficulty,
                items:
                    <String>['Semua', 'Mudah', 'Menengah'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDifficulty = newValue!;
                  });
                },
              ),
              Row(
                children: [
                  Text('Tampilkan Selesai'),
                  Switch(
                    value: showCompleted,
                    onChanged: (bool value) {
                      setState(() {
                        showCompleted = value;
                      });
                    },
                  ),
                ],
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              ElevatedButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow),
                    Text('PLAY NOW'),
                    SizedBox(width: 15),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD19F9F),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CameraScreen(),
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
