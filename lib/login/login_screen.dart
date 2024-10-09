import 'package:flutter/material.dart';
import 'package:exprimo/login/background.dart';
import 'package:exprimo/constants.dart';
import 'package:exprimo/homepage_screen.dart';
import 'package:exprimo/login/forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk TextField
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Background Widget
            const Background(),

            // Kotak berwarna secondaryColor di bagian bawah
            Expanded(
              child: Container(
                color: secondaryColor,
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.05), // Jarak atas
                      Container(
                        width: size.width * 0.8,
                        child: TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            hintText: 'Masukkan username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset("assets/icons/Person.png"),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      Container(
                        width: size.width * 0.8,
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Masukkan password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset("assets/icons/Lock.png"),
                            ),
                          ),
                        ),
                      ),

                      // Tautan Lupa Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Lupa Password?',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.05), // Jarak sebelum tombol Login

                      // Tombol Login di bagian bawah
                      Container(
                        width: size.width * 0.8,
                        child: ElevatedButton(
                          onPressed: () {
                            // Cek apakah username dan password diisi
                            String username = usernameController.text.trim();
                            String password = passwordController.text.trim();
                            String alertMessage = '';

                            if (username.isEmpty && password.isEmpty) {
                              alertMessage = "Silakan masukkan username dan password.";
                            } else if (username.isEmpty) {
                              alertMessage = "Silakan masukkan username.";
                            } else if (password.isEmpty) {
                              alertMessage = "Silakan masukkan password.";
                            }

                            if (alertMessage.isNotEmpty) {
                              // Tampilkan dialog jika username atau password belum diisi
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Peringatan"),
                                    content: Text(alertMessage),
                                    actions: [
                                      TextButton(
                                        child: Text("OK"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              // Aksi untuk tombol Login
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Homepage()),
                              );
                            }
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 20,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: secondaryColor,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.03), // Jarak bawah
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}


