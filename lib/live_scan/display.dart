import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class DisplayImagePage extends StatelessWidget {
  final String imagePath;

  DisplayImagePage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // Mendapatkan lebar layar
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Scan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth,
              decoration: BoxDecoration(
                border: Border.all(
                  // color: Colors.black, // Warna garis (border)
                  // width: 3, // Ketebalan garis
                ),
                borderRadius: BorderRadius.circular(20), // Membuat border rounded
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18), // Set the rounded corner for the image
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi), // Mirroring effect
                  child: Image.file(
                    File(imagePath), // Display the captured image
                    fit: BoxFit.cover, // Ensure the image fills the container
                  ),
                ),
              ),
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
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF5DADA),
                  foregroundColor: Colors.black,
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
