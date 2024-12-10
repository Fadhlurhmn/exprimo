//homepage_screen.dart
import 'package:exprimo/constants.dart';
import 'package:exprimo/face_quest/face_quest_screen.dart';
import 'package:exprimo/import_foto/import_foto_screen.dart';
import 'package:flutter/material.dart';
import 'package:exprimo/live_scan/live_scan_screen.dart';
import 'package:exprimo/file_uji_coba/firebase_api.dart';
import 'package:exprimo/file_uji_coba/firebase_model.dart';
import 'package:exprimo/file_uji_coba/image_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exprimo/constants.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<FirebaseFile>> futureFiles;
  String? username;
  String? userId;
  List<FirebaseFile> _allFiles = [];
  int _totalScans = 0;
  int _completedQuests = 0;
  int _totalQuests = 0;

  @override
  void initState() {
    super.initState();
    futureFiles = _loadUserData(); // Initialize with a Future
    _loadQuestData();
  }

  Future<void> _loadQuestData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (userId != null) {
      final DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(userId!);

      try {
        DatabaseEvent event = await userRef.child('expressionItems').once();
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.value != null) {
          Map<dynamic, dynamic> expressionItems =
              Map<dynamic, dynamic>.from(snapshot.value as Map);

          int completedCount = 0;
          int totalGames = 0;

          expressionItems.forEach((key, value) {
            if (value is Map && value.containsKey('isComplete')) {
              totalGames++;
              if (value['isComplete'] == true) {
                completedCount++;
              }
            }
          });

          setState(() {
            _completedQuests = completedCount;
            _totalQuests = totalGames;
          });
        }
      } catch (e) {
        print('Error loading quest data: $e');
      }
    }
  }

  // Modified to also update the total scan count
  Future<List<FirebaseFile>> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (userId != null) {
      List<FirebaseFile> files = await FirebaseApi.listAll('history/$userId/');

      // Sort files by upload time
      await Future.wait(files.map((file) async {
        try {
          final metadata = await file.ref.getMetadata();
          file.uploadTime = metadata.timeCreated;
        } catch (e) {
          print('Error getting upload time: $e');
          file.uploadTime = DateTime(1970); // Default to oldest time if error
        }
      }));

      files.sort((a, b) {
        DateTime timeA = a.uploadTime ?? DateTime(1970);
        DateTime timeB = b.uploadTime ?? DateTime(1970);
        return timeB.compareTo(timeA);
      });

      setState(() {
        _allFiles = files;
        _totalScans = files.length; // Update total scans count
      });
      return files;
    } else {
      throw Exception('User not logged in');
    }
  }

  // Add method to refresh the count
  Future<void> refreshImageCount() async {
    if (userId != null) {
      List<FirebaseFile> files = await FirebaseApi.listAll('history/$userId/');
      setState(() {
        _totalScans = files.length;
      });
    }
  }

  // Modify the statistics card to show the count
  Widget buildStatisticsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: 8.0), // Jarak antar card
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Jumlah Hasil Scan',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$_totalScans',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 8.0), // Jarak antar card
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Quest Terselesaikan',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$_completedQuests/$_totalQuests',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> getUploadTime(String fileUrl) async {
    try {
      final storageRef =
          firebase_storage.FirebaseStorage.instance.refFromURL(fileUrl);
      final metadata =
          await storageRef.getMetadata(); // Mengambil metadata file
      final DateTime uploadTime = metadata.timeCreated!; // Waktu upload

      // Format tanggal sesuai keinginan (misalnya: yyyy-MM-dd HH:mm)
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
      return formatter.format(uploadTime);
    } catch (e) {
      return 'Unknown time'; // Menangani error jika metadata tidak ditemukan
    }
  }

  // Fungsi untuk menghapus file dari Firebase Storage dan UI
  Future<void> _deleteFile(FirebaseFile file) async {
    try {
      // 1. Menghapus file dari Firebase Storage
      final storageRef = FirebaseStorage.instance.refFromURL(file.url);
      await storageRef.delete(); // Menghapus file dari Storage

      // 2. Menghapus file dari daftar tampilan (UI)
      setState(() {
        _allFiles.remove(file); // Hapus file dari daftar semua file
      });

      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('File deleted successfully'),
      ));
    } catch (e) {
      // Menangani error jika penghapusan gagal
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete file: $e'),
      ));
    }
  }

  // Menampilkan dialog konfirmasi sebelum menghapus file
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
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
                _deleteFile(file); // Menghapus file setelah konfirmasi
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      'assets/images/infografis.png', // Ganti dengan path gambar Anda
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 190.0,
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF4F4),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          IconWithLabel(
                            iconPath: 'assets/images/live_scanning_icon.png',
                            label: 'Live Scan',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LiveScanPage(),
                                ),
                              );
                            },
                          ),
                          IconWithLabel(
                            iconPath: 'assets/images/import_foto_icon.png',
                            label: 'Import Photo',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImportFotoScreen(),
                                ),
                              );
                            },
                          ),
                          IconWithLabel(
                            iconPath: 'assets/images/face_quest_icon.png',
                            label: 'Face Quest',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FaceQuestScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: <Widget>[
                  // Container(
                  //   child: Image.asset('assets/images/poster.jpg'),
                  // ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Statistik',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  buildStatisticsCard(),
                  SizedBox(height: 10),
                  // Riwayat Section
                  Align(
                    alignment:
                        Alignment.centerLeft, // Menyelaraskan tulisan ke kiri
                    child: Text(
                      'Riwayat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: FutureBuilder<List<FirebaseFile>>(
                      future: futureFiles,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Text('Tidak ada file untuk ditampilkan');
                        }

                        // Limit to top 5 files
                        List<FirebaseFile> topFiles =
                            _allFiles.take(5).toList();

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: topFiles.length,
                          itemBuilder: (context, index) {
                            final file = topFiles[index];
                            return buildFileItem(file);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFileItem(FirebaseFile file) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          file.url,
          width: 70,
          height: 80,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(file.name),
      subtitle: file.uploadTime != null
          ? Text(DateFormat('yyyy-MM-dd HH:mm').format(file.uploadTime!))
          : Text('Unknown time'),
    );
  }
}

// Custom widget untuk Icon dan Label
class IconWithLabel extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onPressed;

  const IconWithLabel({
    Key? key,
    required this.iconPath,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: <Widget>[
          Image.asset(
            iconPath,
            width: 64,
            height: 64,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
