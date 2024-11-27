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

class FilesPage extends StatefulWidget {
  @override
  _FilesPageState createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  late Future<List<FirebaseFile>> futureFiles;
  String? username;
  String? userId;
  List<FirebaseFile> _filteredFiles = [];
  List<FirebaseFile> _allFiles = [];
  bool isNewestFirst = true; 

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
        _allFiles = files;
        _filteredFiles =
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
        _filteredFiles.remove(file);  // Hapus file dari daftar yang difilter
        _allFiles.remove(file);       // Hapus file dari daftar semua file
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
                _deleteFile(file);  // Menghapus file setelah konfirmasi
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk memfilter file berdasarkan pencarian
  void _filterFiles(String query) {
    final filtered = _allFiles.where((file) {
      return file.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredFiles = filtered;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: AppBar(
            automaticallyImplyLeading: false, // This removes the back button
            toolbarHeight: 10,
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 40),
            // Search bar
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
                  _filterFiles(value); // Memanggil fungsi pencarian
                },
                decoration: InputDecoration(
                  hintText: "Search files",
                  icon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Konten yang bisa discroll
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
                            onPressed: () {
                              // Sorting functionality can be added here if needed
                            },
                            icon: Icon(Icons.sort),
                          ),
                        ],
                      ),
                      // Daftar hasil pencarian widget file
                      _filteredFiles.isEmpty
                          ? Center(child: Text('No files found'))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _filteredFiles.length,
                              itemBuilder: (context, index) {
                                final file = _filteredFiles[index];
                                return buildFileItem(
                                    file); // Update with the new widget style
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
          // Gambar
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
          // Deskripsi teks
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
                  future: getUploadTime(file
                      .url), // Memanggil fungsi untuk mendapatkan waktu upload
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
                // Tombol share dan view
                Row(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size(50, 30), // Set ukuran minimum
                        padding: EdgeInsets.symmetric(
                            horizontal: 8), // Adjust padding
                      ),
                      child: Text(
                        'Share',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Navigasi ke halaman ImagePage dan meneruskan file
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
                        minimumSize: Size(50, 30), // Set ukuran minimum
                        padding: EdgeInsets.symmetric(
                            horizontal: 8), // Adjust padding
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
          // Tombol delete
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
