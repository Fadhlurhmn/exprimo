import 'package:exprimo/api/firebase_api.dart';
import 'package:exprimo/file_uji_coba/firebase_model.dart';
import 'package:flutter/material.dart';

class ImagePage extends StatelessWidget {
  final FirebaseFile file;

  const ImagePage({
    super.key,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    // Cek apakah file yang diberikan adalah gambar berdasarkan ekstensi
    final isImage = ['.jpeg', '.jpg', '.png'].any(file.name.contains);

    // Mendapatkan ukuran layar untuk setengah lebar layar
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(file.name), // Nama file ditampilkan di AppBar
        centerTitle: true, // Menyusun judul agar berada di tengah
        // Menghapus bagian actions yang berisi ikon download
      ),
      body: Column(
        children: [
          Spacer(flex: 1),
          isImage
              ? Center(
                  child: Image.network(
                    file.url, // URL gambar dari Firebase
                    width: screenWidth * 0.7, // Lebar gambar 70% dari lebar layar
                    height: screenHeight * 0.7, // Tinggi gambar 70% dari tinggi layar
                    fit: BoxFit.contain, // Gambar akan tetap proporsional
                  ),
                )
              // Jika file bukan gambar, tampilkan pesan
              : Center(
                  child: Text(
                    'Cannot be displayed',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
          SizedBox(height: 10),
          // Tombol untuk mendownload gambar
          Container(
            width: 300,
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseApi.downloadFile(file.ref);

                final snackBar = SnackBar(
                  content: Text('Downloaded ${file.name}'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF5DADA), // Warna latar belakang tombol
                foregroundColor: Colors.black, // Warna teks tombol
                padding: EdgeInsets.symmetric(vertical: 20), // Padding vertikal tombol
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Membuat tombol dengan sudut rounded
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 8),
                  Text(
                    'Download Gambar', // Label tombol
                    style: TextStyle(
                      color: Colors.black, // Warna teks tombol
                      fontSize: 24, // Ukuran font
                      fontFamily: 'Roboto', // Jenis font
                      fontWeight: FontWeight.w700, // Ketebalan font
                    ),
                  ),
                ],
              ),
            ),
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}
