import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class FaceQuestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Face Quest'),
      ),
      body: FaceQuestList(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      '🙂',
                      style: TextStyle(fontSize: 100),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: CameraPreview(_controller),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
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
                onPressed: () async {
                  Navigator.of(context).pop();

                  try {
                    final cameras = await availableCameras();
                    final firstCamera = cameras.first;

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(camera: firstCamera),
                      ),
                    );
                  } catch (e) {
                    print('Error accessing camera: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to access camera')),
                    );
                  }
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
