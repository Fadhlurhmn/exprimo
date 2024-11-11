import 'package:exprimo/constants.dart';
import 'package:exprimo/face_quest/face_quest_screen.dart';
import 'package:exprimo/import_foto/import_foto_screen.dart';
import 'package:flutter/material.dart';
import 'package:exprimo/live_scan/live_scan_screen.dart';

class Homepage extends StatelessWidget {
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
                    top: 202.0,
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
                                  builder: (context) => importFotoScreen(),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Riwayat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Daftar riwayat
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 5, // Contoh jumlah data
                    itemBuilder: (context, index) {
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
                                    'PrimoScanner...-2024 11.04',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow:
                                        TextOverflow.ellipsis, // Fixed overflow
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
                                          backgroundColor: secondaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          minimumSize: Size(
                                              50, 30), // Set ukuran minimum
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8), // Adjust padding
                                        ),
                                        child: Text(
                                          'Share',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: secondaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          minimumSize: Size(
                                              50, 30), // Set ukuran minimum
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8), // Adjust padding
                                        ),
                                        child: Text(
                                          'View',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
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
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
