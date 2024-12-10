import 'package:exprimo/education/presentation/pages/expression_page.dart';
import 'package:flutter/material.dart';
import 'package:exprimo/homepage_screen.dart';
import 'package:exprimo/files/file_screen.dart';
import 'package:exprimo/profile/profile_screen.dart';

class Navigation_menu extends StatefulWidget {
  @override
  _BottomNavExampleState createState() => _BottomNavExampleState();
}

class _BottomNavExampleState extends State<Navigation_menu> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan berdasarkan item yang dipilih di BottomNavigationBar
  static List<Widget> _pages = <Widget>[
    HomePage(),
    FilesPage(),
    ExpressionsPage(),
    ProfilePage(),
  ];

  // Mengubah halaman ketika item di BottomNavigationBar dipilih
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[
          _selectedIndex], // Menampilkan halaman sesuai index yang dipilih
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Index saat ini
        onTap: _onItemTapped, // Fungsi saat item dipilih
        backgroundColor: Color(0xFFFFF4F4), // Warna latar belakang
        selectedItemColor: Colors.pink[100], // Warna item yang dipilih
        unselectedItemColor: Colors.grey, // Warna item yang tidak dipilih
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Files',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Education',
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
