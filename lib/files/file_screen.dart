import 'dart:io';

import 'package:exprimo/file_uji_coba/firebase_api.dart';
import 'package:exprimo/file_uji_coba/firebase_model.dart';
import 'package:exprimo/file_uji_coba/image_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exprimo/constants.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  _FilesPageState createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  late Future<List<FirebaseFile>> futureFiles;
  String? username;
  String? userId;
  List<FirebaseFile> _filteredFiles = [];
  List<FirebaseFile> _allFiles = [];
  bool isNewestFirst = true; // Default: sorting data terbaru

  @override
  void initState() {
    super.initState();
    futureFiles = _loadUserData();
  }

  Future<List<FirebaseFile>> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (userId != null) {
      List<FirebaseFile> files = await FirebaseApi.listAll('history/$userId/');
      setState(() {
        _allFiles = files;
        _filteredFiles = files;
      });
      return files;
    } else {
      throw Exception('User not loggedin');
    }
  }

  Future<String> getUploadTime(String fileUrl) async {
    try {
      final storageRef =
          firebase_storage.FirebaseStorage.instance.refFromURL(fileUrl);
      final metadata = await storageRef.getMetadata();
      final DateTime uploadTime = metadata.timeCreated!;

      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
      return formatter.format(uploadTime);
    } catch (e) {
      return 'Unknown time';
    }
  }

  Future<void> _deleteFile(FirebaseFile file) async {
    try {
      final storageRef = FirebaseStorage.instance.refFromURL(file.url);
      await storageRef.delete();

      setState(() {
        _filteredFiles.remove(file);
        _allFiles.remove(file);
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('File deleted successfully'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete file: $e'),
      ));
    }
  }

  Future<void> _showDeleteConfirmationDialog(FirebaseFile file) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Apakah anda yakin untuk menghapus file ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteFile(file);
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _filterFiles(String query) {
    final filtered = _allFiles.where((file) {
      return file.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredFiles = filtered;
    });
  }

  Future<void> _sortFiles() async {
    // Mendapatkan metadata untuk semua file
    List<Map<String, dynamic>> filesWithTime =
        await Future.wait(_filteredFiles.map((file) async {
      String uploadTimeStr = await getUploadTime(file.url);
      DateTime uploadTime = DateFormat('yyyy-MM-dd HH:mm').parse(uploadTimeStr);
      return {'file': file, 'time': uploadTime};
    }));

    // Sorting berdasarkan waktu upload
    filesWithTime.sort((a, b) {
      DateTime timeA = a['time'];
      DateTime timeB = b['time'];
      return isNewestFirst ? timeB.compareTo(timeA) : timeA.compareTo(timeB);
    });

    // Perbarui daftar file
    setState(() {
      _filteredFiles =
          filesWithTime.map((entry) => entry['file'] as FirebaseFile).toList();
      isNewestFirst = !isNewestFirst; // Toggle mode sorting
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 10,
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              width: MediaQuery.of(context).size.width * 0.9,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 232, 154, 154)
                        .withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  _filterFiles(value);
                },
                decoration: InputDecoration(
                  hintText: "Search files",
                  icon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'All(${_filteredFiles.length})',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                          IconButton(
                            onPressed: _sortFiles, // Tambahkan fungsi sorting
                            icon: Icon(Icons.sort),
                          ),
                        ],
                      ),
                      _filteredFiles.isEmpty
                          ? Center(child: Text('No files found'))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _filteredFiles.length,
                              itemBuilder: (context, index) {
                                final file = _filteredFiles[index];
                                return buildFileItem(file);
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget buildFileItem(FirebaseFile file) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 64,
              height: 64,
              child: Image.network(
                file.url,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  file.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                FutureBuilder<String>(
                  future: getUploadTime(file.url),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        'Loading...',
                        style: TextStyle(color: Colors.grey[600]),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error loading time',
                        style: TextStyle(color: Colors.grey[600]),
                      );
                    } else {
                      return Text(
                        snapshot.data ?? 'Unknown time',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      );
                    }
                  },
                ),
                Row(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          // Unduh file dari Firebase Storage
                          final tempDir = await getTemporaryDirectory();
                          final filePath =
                              '${tempDir.path}/${file.name}'; // Simpan sementara
                          final ref =
                              FirebaseStorage.instance.refFromURL(file.url);
                          final fileLocal = File(filePath);

                          // Unduh data ke file lokal
                          await ref.writeToFile(fileLocal);

                          // Gunakan Share Plus untuk berbagi
                          await Share.shareXFiles(
                            [XFile(fileLocal.path)],
                            text: 'Hasil scan Exprimo Kelompok 4: ${file.name}',
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to share file: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size(50, 30),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(
                        'Share',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePage(file: file),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size(50, 30),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(
                        'View',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showDeleteConfirmationDialog(file);
            },
            icon: Icon(Icons.delete_outline),
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }
}
