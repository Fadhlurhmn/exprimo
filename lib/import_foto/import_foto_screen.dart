import 'dart:io';
import 'package:exprimo/constants.dart';
import 'package:exprimo/import_foto/display.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImportFotoScreen extends StatefulWidget {
  @override
  _ImportFotoScreenState createState() => _ImportFotoScreenState();
}



class _ImportFotoScreenState extends State<ImportFotoScreen> {
  File? _imageFile;

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Function to handle scanning (you can implement your scanning functionality here)
  void _startScan() {
    if (_imageFile != null) {
      // Add your scan logic here (like starting a scan on the image)
      print('Scan started on image: ${_imageFile!.path}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Import Foto'),
            SizedBox(width: 10),
            // Scan Button, only enabled when there is an image
            ElevatedButton(
              onPressed: _imageFile != null 
                  ? () {
                      // Navigate to the DisplayImagePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayImagePage(imagePath: _imageFile!.path),
                        ),
                      );
                    }
                  : null, // Only enable button if an image is selected
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black, // Set text color to black
              ),
              child: Text('Scan'),
            )

          ],
        ),
        backgroundColor: secondaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display the picked image if available, else show placeholder
            _imageFile == null
                ? Container(
                    height: 200,
                    width: 200,
                    color: Colors.grey[300], // Light grey background for placeholder
                    child: Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      // When tapped, show the image in fullscreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(imageFile: _imageFile!),
                        ),
                      );
                    },
                    child: Image.file(
                      _imageFile!,
                      width: MediaQuery.of(context).size.width * 0.75, // Set width to 50% of screen width
                      height: MediaQuery.of(context).size.height * 0.75, // Set height to 50% of screen height
                      fit: BoxFit.contain, // This ensures the image scales properly without overflow
                    ),
                  ),
            SizedBox(height: 10), // Slight space between image and button
            // Button to pick image
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                backgroundColor: secondaryColor,
              ),
              child: Text(
                'Pilih Foto dari Galeri',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final File imageFile;

  FullScreenImage({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('View Image'),
      ),
      body: PhotoViewGallery.builder(
        itemCount: 1,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(imageFile),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(),
      ),
    );
  }
}
