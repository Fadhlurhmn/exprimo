import 'package:flutter/material.dart';
import 'ubahusername.dart';  // Import halaman ubahusername
import 'ubahemail.dart';  // Import halaman ubahemail

class UbahProfilePage extends StatelessWidget {
  final String currentUsername = 'Azka Kasmito Putra';  // Username yang ada di halaman profil

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);  // Kembali ke halaman sebelumnya
          },
        ),
        title: Text(
          'Ubah Profil',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          
          // Profile Picture with Edit Icon
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  'https://media.licdn.com/dms/image/v2/D5603AQEh91D9scCDiw/profile-displayphoto-shrink_200_200/profile-displayphoto-shrink_200_200/0/1721730196006?e=1732752000&v=beta&t=2sLe8Tg8FJulTxBI_90T1V4GEcDhVqnPPrdwtTAyH9k',
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              )
            ],
          ),
          
          SizedBox(height: 20),
          
          // Profile Information Label
          Text(
            'Profile Information',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          
          SizedBox(height: 20),
          
          // Username, Email, Password
          ProfileItem(
            label: 'Username',
            value: currentUsername,  // Gunakan currentUsername untuk ditampilkan
            onTap: () {
              // Pindah ke halaman ubahusername dengan data username
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUsernamePage(username: currentUsername),
                ),
              );
            },
          ),
          ProfileItem(
            label: 'Email',
            value: 'kelompok4uhuy@gmail.com',
            onTap: () {
              // Navigasi ke halaman ResetEmailPage (ubahemail.dart)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KonfirmasiPasswordPage(),  // Pindah ke halaman ubahemail.dart
                ),
              );
            },
          ),
          ProfileItem(
            label: 'Password',
            value: '********',
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

// Reusable Widget for Profile Information
class ProfileItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const ProfileItem({
    Key? key,
    required this.label,
    required this.value,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,  // Aksi ketika item diklik
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.pink[50], // Warna background sesuai desain
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
