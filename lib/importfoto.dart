// import 'package:flutter/material.dart';
// import 'package:photo_manager/photo_manager.dart';

// class SelectPhotoPage extends StatefulWidget {
//   @override
//   _SelectPhotoPageState createState() => _SelectPhotoPageState();
// }

// class _SelectPhotoPageState extends State<SelectPhotoPage> {
//   List<AssetEntity> assets = []; // Daftar aset dari galeri
//   List<bool> isSelected = []; // Status apakah foto dipilih atau tidak

//   @override
//   void initState() {
//     super.initState();
//     _fetchAssets();
//   }

//   // Ambil foto dari galeri
//   Future<void> _fetchAssets() async {
//     final PermissionState result = await PhotoManager.requestPermissionExtend();

//     if (result.isAuth) {
//       List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
//         onlyAll: true,
//         type: RequestType.image, // Hanya ambil gambar
//       );
//       List<AssetEntity> media = await albums[0].getAssetListPaged(0, 100); // Ambil 100 foto pertama
//       setState(() {
//         assets = media;
//         isSelected = List.generate(assets.length, (index) => false); // Atur status isSelected
//       });
//     } else {
//       PhotoManager.openSetting(); // Minta izin jika belum diberikan
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.pink[50],
//         title: Text(
//           'Pilih Foto',
//           style: TextStyle(color: Colors.black),
//         ),
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               // Fungsi untuk import foto yang dipilih
//               List<int> selectedIndexes = [];
//               for (int i = 0; i < isSelected.length; i++) {
//                 if (isSelected[i]) {
//                   selectedIndexes.add(i);
//                 }
//               }
//               print("Foto yang dipilih: $selectedIndexes");
//             },
//             child: Text(
//               'Import',
//               style: TextStyle(color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: GridView.builder(
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3, // 3 kolom
//             crossAxisSpacing: 10, // Jarak antar kolom
//             mainAxisSpacing: 10, // Jarak antar baris
//           ),
//           itemCount: assets.length, // Jumlah item
//           itemBuilder: (context, index) {
//             return FutureBuilder<Widget>(
//               future: _buildImageWidget(assets[index]),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
//                   return Stack(
//                     alignment: Alignment.topLeft,
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             isSelected[index] = !isSelected[index];
//                           });
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(
//                               color: isSelected[index] ? Colors.pink : Colors.grey,
//                               width: 2,
//                             ),
//                           ),
//                           child: snapshot.data,
//                         ),
//                       ),
//                       if (isSelected[index])
//                         Positioned(
//                           top: 5,
//                           left: 5,
//                           child: Icon(
//                             Icons.check_box,
//                             color: Colors.pink,
//                           ),
//                         )
//                       else
//                         Positioned(
//                           top: 5,
//                           left: 5,
//                           child: Icon(
//                             Icons.check_box_outline_blank,
//                             color: Colors.white,
//                           ),
//                         ),
//                     ],
//                   );
//                 }
//                 return Container(); // Placeholder saat gambar belum siap
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // Fungsi untuk membangun widget gambar
//   Future<Widget> _buildImageWidget(AssetEntity asset) async {
//     final thumbnail = await asset.thumbDataWithSize(150, 150); // Ambil thumbnail
//     return Image.memory(thumbnail!, fit: BoxFit.cover); // Tampilkan thumbnail
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: SelectPhotoPage(),
//   ));
// }