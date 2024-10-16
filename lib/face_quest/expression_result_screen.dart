import 'dart:io';
import 'package:exprimo/face_quest/face_quest_screen.dart';
import 'package:flutter/material.dart';

class ExpressionResultScreen extends StatelessWidget {
  final File imageFile;
  final String detectedExpression;

  ExpressionResultScreen(
      {required this.imageFile, required this.detectedExpression});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ekspresi $detectedExpression'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Detected Expression: $detectedExpression',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      Image.file(imageFile), // Display the captured image
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Icon(
                          Icons.emoji_emotions,
                          color: Colors.orange,
                          size: 80, // Emoji to represent the expression
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Successfully', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FaceQuestScreen(),
                  ),
                );
              },
              child: Text('Next'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
