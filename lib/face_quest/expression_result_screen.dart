import 'dart:io';
import 'package:exprimo/face_quest/face_quest_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ExpressionResultScreen extends StatelessWidget {
  final File imageFile;
  final String detectedExpression;
  final String expectedExpression;
  final bool isMatched;
  final VoidCallback onRetry;

  const ExpressionResultScreen({
    Key? key,
    required this.imageFile,
    required this.detectedExpression,
    required this.expectedExpression,
    required this.isMatched,
    required this.onRetry,
  }) : super(key: key);

  Future<void> _updateStatusInDatabase() async {
    String userId = "";
    try {
      final databaseReference = FirebaseDatabase.instance.ref();

      // Assuming the path is something like '/expressions/{userId}'
      String userId = "yourUserId"; // Replace with actual user ID
      databaseReference
          .child('expressions')
          .child(userId)
          .update({'isComplete': true}).then((_) {
        print('Status updated successfully!');
      }).catchError((error) {
        print('Failed to update status: $error');
      });
    } catch (e) {
      print('Error updating status in database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Result')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.file(imageFile, height: 300, width: 300, fit: BoxFit.cover),
          SizedBox(height: 20),
          Text(
            'Detected Expression: $detectedExpression',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Expected Expression: $expectedExpression',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 20),
          Text(
            isMatched ? 'Matched! 🎉' : 'Not Matched 😞',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isMatched ? Colors.green : Colors.red,
            ),
          ),
          SizedBox(height: 30),
          if (!isMatched)
            ElevatedButton(
              onPressed: () {
                // Navigasi ulang ke layar kamera dengan callback
                onRetry();
              },
              child: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange,
              ),
            ),
          if (isMatched)
            ElevatedButton(
              onPressed: () {
                // Navigating to the FaceQuestPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FaceQuestScreen()),
                );
              },
              child: Text('Next'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
            ),
        ],
      ),
    );
  }
}
