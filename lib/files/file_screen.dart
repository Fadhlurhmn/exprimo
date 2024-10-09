import 'package:flutter/material.dart';

class FilesPage extends StatefulWidget {
  @override
  _FilesPageState createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  // Daftar semua widget file
  List<Widget> _allFiles = [];
  List<Widget> _filteredFiles = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar widget file
    _allFiles =
        List.generate(5, (index) => buildFileItem('PrimoScanner-${index + 1}'));
    _filteredFiles = _allFiles;
  }

  // Fungsi untuk membangun setiap item dalam daftar file
  Widget buildFileItem(String fileName) {
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
              child: Image.asset(
                'assets/images/image_happy.jpeg', // Contoh gambar
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
                  fileName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '2024-09-16 10:54',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                // Tombol share dan view
                Row(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[100],
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[100],
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
            onPressed: () {},
            icon: Icon(Icons.delete_outline),
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mem-filter widget berdasarkan input pencarian
  void _filterFiles(String query) {
    List<Widget> _results = [];
    if (query.isEmpty) {
      _results = _allFiles;
    } else {
      _results = _allFiles.where((widget) {
        if (widget is Padding) {
          final row = widget.child as Row;
          final expanded = row.children[2] as Expanded;
          final column = expanded.child as Column;
          final fileNameText = column.children[0] as Text;
          final fileName = fileNameText.data ?? ''; // Pastikan nilai tidak null
          return fileName.toLowerCase().contains(query.toLowerCase());
        }
        return false;
      }).toList();
    }

    setState(() {
      _filteredFiles = _results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
        child: Column(
          children: <Widget>[
            // Search bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
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
            SizedBox(height: 20),

            // Daftar hasil pencarian widget file
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _filteredFiles.length,
              itemBuilder: (context, index) {
                return _filteredFiles[index];
              },
            ),
          ],
        ),
      ),
    );
  }
}
