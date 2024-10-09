import 'package:exprimo/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:exprimo/constants.dart';
import 'package:exprimo/register/register_screen.dart';

class Background extends StatefulWidget {
  const Background({Key? key}) : super(key: key);

  @override
  _BackgroundState createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  // Variabel untuk menyimpan status tombol yang aktif
  bool isLoginActive = true; // Default ke login

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.5, // Atur tinggi untuk menghindari unbounded
      child: Column(
        children: [
          // Bagian atas dengan teks dan logo
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Selamat Datang di Exprimo!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: size.width * 0.06,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Image.asset(
                    "assets/images/smile.png",
                    width: size.width * 0.5,
                  ),
                  SizedBox(height: size.height * 0.015),
                  Text(
                    'Yuk, register atau login sekarang untuk akses penuh ke semua fitur menarik di Exprimo!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: blackColor,
                      fontSize: size.width * 0.04,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tombol Login dan Register di atas kotak
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoginActive = true; // Set ke Login
                    });
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
                      color: isLoginActive ? Colors.white : Colors.black, // Ubah warna teks berdasarkan status
                      fontSize: size.width * 0.05,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLoginActive ? secondaryColor : Colors.white, // Ubah warna background
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        bottomLeft: Radius.circular(0),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 0),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoginActive = false; // Set ke Register
                    });
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
                      color: isLoginActive ? Colors.black : Colors.white, // Ubah warna teks berdasarkan status
                      fontSize: size.width * 0.05,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLoginActive ? Colors.white : secondaryColor, // Ubah warna background
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(0),
                        topRight: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

