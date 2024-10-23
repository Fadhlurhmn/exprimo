import 'package:flutter/material.dart';
import 'scanfoto.dart'; // Import halaman ScanningPage

class SelectPhotoPage extends StatefulWidget {
  @override
  _SelectPhotoPageState createState() => _SelectPhotoPageState();
}

class _SelectPhotoPageState extends State<SelectPhotoPage> {
  // Simpan daftar pilihan foto
  List<bool> isSelected = List.generate(9, (index) => false); // Misalkan ada 9 foto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[50],
        title: Text(
          'Pilih Foto',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Fungsi untuk import foto yang dipilih
              List<int> selectedIndexes = [];
              for (int i = 0; i < isSelected.length; i++) {
                if (isSelected[i]) {
                  selectedIndexes.add(i);
                }
              }
              print("Foto yang dipilih: $selectedIndexes");

              // Navigasi ke halaman ScanningPage setelah import foto
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScanningPage()),
              );
            },
            child: Text(
              'Import',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 kolom
            crossAxisSpacing: 10, // Jarak antar kolom
            mainAxisSpacing: 10, // Jarak antar baris
          ),
          itemCount: 9, // Jumlah item, misal 9
          itemBuilder: (context, index) {
            return Stack(
              alignment: Alignment.topLeft,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected[index] = !isSelected[index];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected[index] ? Colors.pink : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Image.network(
                      'https://via.placeholder.com/150', // Ganti dengan URL gambar sebenarnya
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isSelected[index])
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Icon(
                      Icons.check_box,
                      color: Colors.pink,
                    ),
                  )
                else
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Icon(
                      Icons.check_box_outline_blank,
                      color: Colors.white,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SelectPhotoPage(),
  ));
}
