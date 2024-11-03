import 'package:exprimo/homepage_screen.dart';
import 'package:exprimo/model/userdata.dart';
import 'package:flutter/material.dart';
import 'package:exprimo/login/background.dart';
import 'package:exprimo/constants.dart';
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
  final _formKey = GlobalKey<FormState>(); // Membuat GlobalKey untuk form

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Background Widget
            Background(isLoginActive: true),

            // Kotak berwarna secondaryColor di bagian bawah
            Expanded(
              child: Container(
                color: secondaryColor,
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey, // Menggunakan form key untuk validasi
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.05), // Jarak atas
                        Container(
                          width: size.width * 0.8,
                          child: TextFormField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              hintText: 'Masukkan username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset("assets/icons/Person.png"),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Harap masukkan username.';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                        Container(
                          width: size.width * 0.8,
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Masukkan password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset("assets/icons/Lock.png"),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Harap masukkan password.';
                              }
                              return null;
                            },
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
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // Memanggil fungsi login
                                bool success = await login(usernameController.text, passwordController.text);
                                if (success) {
                                  // Aksi untuk tombol Login berhasil
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Homepage()),
                                  );
                                } else {
                                  // Menampilkan alert dialog jika login gagal
                                  _showErrorDialog("Username atau password salah.");
                                }
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
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan dialog kesalahan
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Menutup dialog
            },
            child: Text("OK"),
          ),
        ],
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
