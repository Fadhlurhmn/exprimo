import 'dart:io';
import 'package:exprimo/api/firebase_api.dart';
import 'package:exprimo/file_uji_coba/firebase_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImagePage extends StatelessWidget {
  final FirebaseFile file;

  const ImagePage({
    super.key,
    required this.file,
  });

  Future<void> downloadImage(
      BuildContext context, String url, String fileName) async {
    try {
      // Unduh gambar dari URL
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Dapatkan direktori eksternal (biasanya untuk akses ke folder Download)
        final directory = Directory('/storage/emulated/0/Download');
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }
        final filePath = '${directory.path}/$fileName';

        // Simpan file ke folder Download
        final localFile = File(filePath);
        await localFile.writeAsBytes(response.bodyBytes);

        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded $fileName to ${directory.path}')),
        );
      } else {
        // Tampilkan pesan error jika gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download image')),
        );
      }
    } catch (e) {
      // Tangani error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah file yang diberikan adalah gambar berdasarkan ekstensi
    final isImage = ['.jpeg', '.jpg', '.png'].any(file.name.contains);

    return Scaffold(
      appBar: AppBar(
        title: Text(file.name), // Nama file ditampilkan di AppBar
        centerTitle: true, // Menyusun judul agar berada di tengah
      ),
      body: Column(
        children: [
          Spacer(flex: 1),
          isImage
              ? Center(
                  child: Image.network(
                    file.url, // URL gambar dari Firebase
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height *
                        0.7, // Tinggi gambar 70% dari tinggi layar
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
          // Tombol untuk mendownload gambar (Firebase API)
          // Container(
          //   width: 300,
          //   child: ElevatedButton(
          //     onPressed: () async {
          //       await FirebaseApi.downloadFile(file.ref);

          //       final snackBar = SnackBar(
          //         content: Text('Downloaded ${file.name}'),
          //       );
          //       ScaffoldMessenger.of(context).showSnackBar(snackBar);
          //     },
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Color(0xFFF5DADA), // Warna latar belakang tombol
          //       foregroundColor: Colors.black, // Warna teks tombol
          //       padding: EdgeInsets.symmetric(vertical: 20), // Padding vertikal tombol
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(20), // Membuat tombol dengan sudut rounded
          //       ),
          //     ),
          //     child: Row(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         SizedBox(width: 8),
          //         Text(
          //           'Download Gambar', // Label tombol
          //           style: TextStyle(
          //             color: Colors.black, // Warna teks tombol
          //             fontSize: 24, // Ukuran font
          //             fontFamily: 'Roboto', // Jenis font
          //             fontWeight: FontWeight.w700, // Ketebalan font
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          SizedBox(height: 10),
          // Tombol untuk mendownload gambar (Custom API)
          ElevatedButton(
            onPressed: () => downloadImage(context, file.url, file.name),
            child: Text('Download Image'),
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}
