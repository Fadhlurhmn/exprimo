import 'dart:io';
import 'package:flutter/material.dart';

class ExpressionResultScreen extends StatelessWidget {
  final File imageFile;
  final String detectedExpression;
  final String expectedExpression;
  final bool isMatched;

  const ExpressionResultScreen({
    Key? key,
    required this.imageFile,
    required this.detectedExpression,
    required this.expectedExpression,
    required this.isMatched,
  }) : super(key: key);

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
                // Navigasi kembali ke layar kamera
                Navigator.of(context).pop();
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
                // Tambahkan logika untuk melanjutkan ke tahap berikutnya
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Great job! Proceeding to the next step.')),
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
