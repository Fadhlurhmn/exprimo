import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expression Scanner',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: ScanningPage(),
    );
  }
}

class ScanningPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanning'),
        backgroundColor: Colors.pink[100],
        leading: Icon(Icons.arrow_back),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Scanning area
          Container(
            width: 200,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 3),
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage('assets/sample_image.jpg'), // Image placeholder
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 20),
          // Detected Expression label
          Text(
            'Detected Expression:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          // Loading indicator
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
          ),
        ],
      ),
    );
  }
}
