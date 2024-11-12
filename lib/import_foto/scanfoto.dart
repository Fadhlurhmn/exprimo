import 'package:flutter/material.dart';
import 'dart:io';

class ScanningScreen extends StatelessWidget {
  final File imageFile;

  const ScanningScreen({required this.imageFile});

  void _navigateToResultScreen(BuildContext context) {
    // Navigate to the result screen after detection (for now we'll simulate it)
    Future.delayed(Duration(seconds: 2), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(imageFile: imageFile),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _navigateToResultScreen(context); // Automatically navigate after a delay

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanning"),
        backgroundColor: Color(0xFFEFBEBE),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(imageFile, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Detecting Expression...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final File imageFile;

  const ResultScreen({required this.imageFile});

  void _downloadImage(BuildContext context) {
    // Code for downloading the image can be added here
    // For example, using the `path_provider` package to save the image locally
    print("Download clicked! Implement download functionality.");

    // Show success message after download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Download successfully!"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detection Result"),
        backgroundColor: Color(0xFFEFBEBE),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(imageFile, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Detected Expression: Happy", // Replace with dynamic result
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _downloadImage(context),
              child: const Text("Download"),
            ),
          ],
        ),
      ),
    );
  }
}
