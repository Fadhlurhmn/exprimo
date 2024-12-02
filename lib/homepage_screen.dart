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

  @override
  void initState() {
    super.initState();
    futureFiles = _loadUserData(); // Initialize with a Future
  }

  // Memuat data pengguna dan mengatur folder untuk mengambil file
  Future<List<FirebaseFile>> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId'); // Ambil userId dari SharedPreferences

    if (userId != null) {
      // Ambil data pengguna dari Firebase Realtime Database menggunakan userId
      DatabaseEvent event =
          await FirebaseDatabase.instance.ref('users/$userId').once();
      if (event.snapshot.value != null) {
        Map userData = event.snapshot.value as Map;
        setState(() {
          username = userData['username'];
          // Simpan username di SharedPreferences
          prefs.setString('username', username!);
        });
      }
    }

    // Jika username ditemukan, lanjutkan mengambil file berdasarkan username
    if (username != null) {
      List<FirebaseFile> files = await FirebaseApi.listAll(
          'history/$username/'); // Ambil file sesuai dengan username
      setState(() {
        _allFiles =
            files; // Initialize _filteredFiles to be the same as all files
      });
      return files;
    } else {
      throw Exception('User not logged in');
    }
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
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Ayo Lanjutkan Permainanmu🔥🔥',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Image.asset(
                                'assets/images/image_marah.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Ekspresi Marah',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tingkat kesulitan : Mudah',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    fontFamily: 'Nunito',
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFE57373),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Incomplete',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(0xFFD19F9F),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CameraScreen(
                                    expressionItem: ExpressionItem(
                                        'Senang', 'Mudah', false),
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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

                        // Menampilkan daftar file
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: _allFiles.length,
                          itemBuilder: (context, index) {
                            final file = _allFiles[index];
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
        borderRadius: BorderRadius.circular(
            10), // Atur nilai sesuai kebutuhan untuk pembulatan sudut
        child: Image.network(
          file.url,
          width: 70,
          height: 80,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(file.name),

      subtitle: FutureBuilder<String>(
        future: getUploadTime(file.url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...');
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Text('${snapshot.data}');
          }
        },
      ),
      // trailing: IconButton(
      //   icon: Icon(Icons.delete),
      //   onPressed: () => _showDeleteConfirmationDialog(file),
      // ),
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
