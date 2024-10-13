import 'dart:io';
import 'package:exprimo/constants.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class DisplayImagePage extends StatelessWidget {
  final String imagePath;

  DisplayImagePage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Scan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi), // Mirroring effect
              child: Image.file(File(imagePath)), // Display the captured image
            ),
            SizedBox(height: 20),
            Container(
              width: 300, // Set the desired width for the button
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to the camera page
                },
                child: Text(
                  'Download',
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF5DADA),
                  foregroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
