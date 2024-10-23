import 'package:flutter/material.dart';
import 'ubahprofile.dart'; // Import halaman Ubah Profil

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              'https://media.licdn.com/dms/image/v2/D5603AQEh91D9scCDiw/profile-displayphoto-shrink_200_200/profile-displayphoto-shrink_200_200/0/1721730196006?e=1732752000&v=beta&t=2sLe8Tg8FJulTxBI_90T1V4GEcDhVqnPPrdwtTAyH9k',
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Azka Kasmito Putra',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 40),
          
          // Navigasi ke halaman ubah profil
          MenuButton(
            icon: Icons.edit,
            label: 'Ubah Profil',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UbahProfilePage(), // Navigasi ke halaman Ubah Profil
                ),
              );
            },
          ),
          MenuButton(
            icon: Icons.bug_report,
            label: 'Laporkan bug',
            onTap: () {
              // Tampilkan modal untuk laporan bug
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // Untuk memungkinkan modal scroll ketika keyboard muncul
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => BugReportModal(), // Modal lapor bug
              );
            },
          ),
          MenuButton(
            icon: Icons.logout,
            label: 'Keluar',
            onTap: () {},
            isLogout: true,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Files',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLogout;

  const MenuButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLogout = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isLogout ? Colors.red[50] : Colors.pink[50],
          foregroundColor: isLogout ? Colors.red : Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            children: [
              Icon(icon, color: isLogout ? Colors.red : Colors.black),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class BugReportModal extends StatelessWidget {
  final TextEditingController _reportController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20, // Menyelaraskan modal dengan keyboard
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Agar modal mengikuti tinggi konten
        children: [
          SizedBox(height: 20),
          Text(
            'Isi laporan mu dibawah ini',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _reportController,
            maxLength: 255, // Batas maksimum karakter
            decoration: InputDecoration(
              hintText: 'laporan...',
              filled: true,
              fillColor: Colors.pink[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.cancel, color: Colors.grey),
              onPressed: () {
                Navigator.pop(context); // Tutup modal ketika ikon cancel ditekan
              },
            ),
          ),
        ],
      ),
    );
  }
}
