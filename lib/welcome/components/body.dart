// ignore_for_file: prefer_const_constructors

import 'package:exprimo/constants.dart';
import 'package:exprimo/login/login_screen.dart';
import 'package:flutter/material.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            child: Image.asset(
              "assets/images/smile.png",
              width: size.width * 0.6,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 100, // Menempatkan tombol di 100 piksel dari bawah
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
              child: Text('Mulai Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                foregroundColor: primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
