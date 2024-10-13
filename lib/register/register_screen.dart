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
  final _formKey = GlobalKey<FormState>(); // Membuat GlobalKey untuk form

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
                  child: Form( // Menggunakan Form untuk validasi
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.05), // Jarak atas
                        Container(
                          width: double.infinity,
                          child: TextFormField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              hintText: 'Masukkan username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset("assets/icons/Person.png"),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Silakan masukkan username.';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Container(
                          width: double.infinity,
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Masukkan password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset("assets/icons/Lock.png"),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Silakan masukkan password.';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Container(
                          width: double.infinity,
                          child: TextFormField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Konfirmasi password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset("assets/icons/Lock.png"),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Silakan konfirmasi password.';
                              } else if (value != passwordController.text) {
                                return 'Password tidak cocok.';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: size.height * 0.05),

                        // Tombol Register di bagian bawah
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Jika validasi berhasil, navigasi ke homepage
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Homepage()),
                                );
                              }
                              // Tidak perlu menampilkan pop-up jika validasi gagal, karena 
                              // pesan kesalahan sudah ditampilkan di bawah TextFormField
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
