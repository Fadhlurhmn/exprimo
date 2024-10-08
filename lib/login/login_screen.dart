// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:exprimo/constants.dart';
import 'package:exprimo/homepage_screen.dart';
import 'package:exprimo/login/forgot_password.dart';
import 'package:exprimo/register/register_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: size.height,
        child: Stack(
          children: <Widget>[
            // Menampilkan gambar
            Positioned(
              top: 90, // Jarak atas untuk gambar
              left: (size.width * 0.5) -
                  (size.width * 0.6 / 2), // Pusatkan gambar
              child: Image.asset(
                "assets/images/smile.png",
                width: size.width * 0.6, // Mengatur lebar gambar
              ),
            ),
            // Menambahkan teks "Selamat Datang di Exprimo!"
            Positioned(
              top: 90, // Menentukan posisi teks
              left: 0,
              right: 0,
              child: Text(
                'Selamat Datang di Exprimo!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  height: 0.06,
                  letterSpacing: 0.72,
                ),
              ),
            ),
            // Menambahkan teks deskripsi
            Positioned(
              top: 310, // Jarak dari teks selamat datang
              left: 30,
              right: 30,
              child: Text(
                'Yuk, register atau login sekarang untuk akses penuh \n ke semua fitur menarik di Exprimo!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: blackColor,
                  fontSize: 13,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w400,
                  height: 0.0,
                ),
              ),
            ),
            // Menambahkan dua tombol bersebelahan
            Positioned(
              top: 400, // Menempatkan tombol
              left: -10, // Jarak dari sisi kiri
              right: -10, // Jarak dari sisi kanan
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ), // Mengatur ukuran font
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        foregroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Membuat sudut kotak
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Color(0xFFD19F9F),
                          fontSize: 20,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: secondaryColor,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Membuat sudut kotak
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Menambahkan Container untuk kotak
            Positioned(
              bottom: 0, // Menempatkan kotak di bagian bawah
              left: 0, // Jarak dari sisi kiri
              right: 0, // Jarak dari sisi kanan
              child: Container(
                height: 400, // Mengatur tinggi kotak sesuai kebutuhan
                padding: EdgeInsets.all(30), // Padding di dalam kotak
                decoration: BoxDecoration(
                  color: secondaryColor, // Warna kotak
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 50), // Jarak antara kolom username dan password
                    // Mengatur ukuran kotak teks
                    Container(
                      width: size.width * 0.8, // Mengatur lebar kolom input
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Masukkan username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Sudut membulat pada border
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          filled: true,
                          fillColor: Colors.white, // Warna latar belakang kolom
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0), // Jarak ikon
                            child: Image.asset(
                                "assets/icons/Person.png"), // Ganti dengan path ikon yang sesuai
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: 30), // Jarak antara kolom username dan password

                    Container(
                      width: size.width * 0.8, // Mengatur lebar kolom input
                      child: TextField(
                        obscureText: true, // Agar input password tersembunyi
                        decoration: InputDecoration(
                          hintText: 'Masukkan password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Sudut membulat pada border
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0), // Jarak ikon
                            child: Image.asset(
                                "assets/icons/Lock.png"), // Ganti dengan path ikon yang sesuai
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10), // Jarak sebelum tombol lupa password
                    // Tautan Lupa Password
                    Align(
                      alignment: Alignment
                          .centerRight, // Menyusun agar tombol berada di kanan
                      child: TextButton(
                        onPressed: () {
                          // Aksi untuk menavigasi ke halaman lupa password
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ForgotPasswordScreen(), // Ganti dengan layar lupa password Anda
                            ),
                          );
                        },
                        child: Text(
                          'Lupa Password?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: size.width * 0.8, // Mengatur lebar tombol
                      child: ElevatedButton(
                        onPressed: () {
                          // Aksi untuk tombol Login
                          // print('Login Pressed');
                          // masuk ke homepage
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Homepage()));
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 20,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: secondaryColor,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20), // Membuat sudut kotak
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
