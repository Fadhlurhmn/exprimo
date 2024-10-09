import 'package:flutter/material.dart';
import 'package:exprimo/login/background.dart';
import 'package:exprimo/constants.dart';
import 'package:exprimo/homepage_screen.dart';

class RegisterScreen extends StatefulWidget {
  final bool isRegisterPressed;

  const RegisterScreen({super.key, this.isRegisterPressed = true});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

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
                        width: double.infinity,
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
                      SizedBox(height: size.height * 0.02),
                      Container(
                        width: double.infinity,
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
                      SizedBox(height: size.height * 0.02),
                      Container(
                        width: double.infinity,
                        child: TextField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Konfirmasi password',
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
                      SizedBox(height: size.height * 0.05),

                      // Tombol Register di bagian bawah
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            String username = usernameController.text.trim();
                            String password = passwordController.text.trim();
                            String confirmPassword = confirmPasswordController.text.trim();
                            String alertMessage = '';

                            if (username.isEmpty && password.isEmpty) {
                              alertMessage = "Silakan masukkan username dan password.";
                            } else if (username.isEmpty) {
                              alertMessage = "Silakan masukkan username.";
                            } else if (password.isEmpty) {
                              alertMessage = "Silakan masukkan password.";
                            } else if (password != confirmPassword) {
                              alertMessage = "Password tidak cocok.";
                            }

                            if (alertMessage.isNotEmpty) {
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Homepage()),
                              );
                            }
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 20,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
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
    confirmPasswordController.dispose();
    super.dispose();
  }
}
