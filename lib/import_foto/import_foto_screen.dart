import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'scanfoto.dart'; // Make sure to import the ScanningScreen.

class PhotoPickerPage extends StatefulWidget {
  @override
  _PhotoPickerPageState createState() => _PhotoPickerPageState();
}

class _PhotoPickerPageState extends State<PhotoPickerPage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _selectedImages = [];
  List<bool> _selectedFlags = [];

  Future<void> pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages = images;
        _selectedFlags = List<bool>.filled(images.length, false);
      });
    }
  }

  void onImportPressed() {
    // Filter selected images based on selectedFlags
    final selectedImages = _selectedImages!
        .asMap()
        .entries
        .where((entry) => _selectedFlags[entry.key])
        .map((entry) => entry.value)
        .toList();

    if (selectedImages.isNotEmpty) {
      // Navigate to the next screen with the selected image
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanningScreen(imageFile: File(selectedImages[0].path)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFEFBEBE), // Set background color of Scaffold
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight), // Ensure the AppBar height is consistent
        child: AppBar(
          title: const Text("Pilih Foto"),
          backgroundColor: Color(0xFFEFBEBE), // Set the background color of the AppBar
          elevation: 0, // Remove shadow under the AppBar
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Handle back navigation
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.import_export),
              onPressed: pickImages,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _selectedImages == null || _selectedImages!.isEmpty
              ? const Center(child: Text("Tidak ada foto yang dipilih"))
              : Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: _selectedImages!.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: Image.file(
                              File(_selectedImages![index].path),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Checkbox(
                              value: _selectedFlags[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectedFlags[index] = value ?? false;
                                });
                              },
                              activeColor: Colors.pinkAccent,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
          if (_selectedFlags.contains(true)) // Check if any checkbox is selected
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: onImportPressed,
                child: const Text("Import"),
              ),
            ),
        ],
      ),
    );
  }
}
