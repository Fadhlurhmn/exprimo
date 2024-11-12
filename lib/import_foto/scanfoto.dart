import 'package:flutter/material.dart';
import 'dart:io';

class ScanningScreen extends StatelessWidget {
  final File imageFile;

  const ScanningScreen({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFEFBEBE),
      appBar: AppBar(
        title: const Text("Scanning"),
        backgroundColor: Color(0xFFEFBEBE),
        elevation: 0,
      ),
      body: Center( // Center everything in the body
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          children: [
            // Display the selected image in a frame
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
              "Detected Expression:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Loading indicator (could be replaced with actual expression detection result)
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
