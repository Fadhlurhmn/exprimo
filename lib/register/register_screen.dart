import 'package:exprimo/login/login_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:exprimo/login/background.dart';
import 'package:exprimo/constants.dart';

class RegisterScreen extends StatefulWidget {
  final bool isRegisterPressed;

  const RegisterScreen({super.key, this.isRegisterPressed = true});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");

  String? emailError;
  String? usernameError;
  String? passwordError;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Background takes up 60% of the screen
            Container(
              height: size.height * 0.6,  // 60% of the screen height
              child: Background(isLoginActive: false),
            ),
            // Form takes up 40% of the screen
            Expanded(
              child: Container(
                color: secondaryColor,
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.05),
                        _buildTextField(
                          controller: emailController,
                          hintText: 'Masukkan email',
                          icon: "assets/icons/Email.png",
                          validator: _validateEmail,
                          errorText: emailError,
                        ),
                        SizedBox(height: size.height * 0.02),
                        _buildTextField(
                          controller: usernameController,
                          hintText: 'Masukkan username',
                          icon: "assets/icons/Person.png",
                          validator: _validateUsername,
                          errorText: usernameError,
                        ),
                        SizedBox(height: size.height * 0.02),
                        _buildTextField(
                          controller: passwordController,
                          hintText: 'Masukkan password',
                          icon: "assets/icons/Lock.png",
                          isPassword: true,
                          validator: _validatePassword,
                          errorText: passwordError,
                        ),
                        SizedBox(height: size.height * 0.05),
                        _buildRegisterButton(context),
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Silakan masukkan email.';
    }
    if (!value.endsWith('@gmail.com')) {
      return 'Masukkan email anda';
    }
    return null; // Jika valid
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Silakan masukkan username.';
    }
    return null; // Jika valid
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Silakan masukkan password.';
    }
    if (value.length < 8) {
      return 'Password harus terdiri dari minimal 8 karakter.';
    }
    return null; // Jika valid
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String icon,
    required String? Function(String?) validator,
    bool isPassword = false,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,  // Menjamin lebar penuh
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),  // Sesuaikan padding untuk semua kolom
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  icon,
                  width: 30,  // Ukuran ikon 30
                  height: 30, // Ukuran ikon 30
                ),
              ),

            ),
            validator: validator,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Future<bool> checkEmailExists(String email) async {
    DatabaseEvent event = await usersRef.once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> users = event.snapshot.value as Map<dynamic, dynamic>;
      for (var user in users.values) {
        if (user['email'] == email) {
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> checkUsernameExists(String username) async {
    DatabaseEvent event = await usersRef.once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> users = event.snapshot.value as Map<dynamic, dynamic>;
      for (var user in users.values) {
        if (user['username'] == username) {
          return true; // Username sudah ada
        }
      }
    }
    return false; // Username tidak ada
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          setState(() {
            emailError = _validateEmail(emailController.text);
            usernameError = _validateUsername(usernameController.text);
            passwordError = _validatePassword(passwordController.text);
          });

          if (emailError == null && usernameError == null && passwordError == null) {
            bool emailExists = await checkEmailExists(emailController.text);
            if (emailExists) {
              setState(() {
                emailError = 'Email yang Anda masukkan sudah terdaftar.';
              });
              return; // Keluar dari fungsi jika email sudah ada
            }

            bool usernameExists = await checkUsernameExists(usernameController.text);
            if (usernameExists) {
              setState(() {
                usernameError = 'Username yang Anda masukkan sudah terdaftar.';
              });
              return; // Keluar dari fungsi jika username sudah ada
            }

            // Hashing password sebelum disimpan
            String hashedPassword = hashPassword(passwordController.text);

            // Simpan data user ke Firebase Realtime Database jika email belum ada
            await usersRef.push().set({
              "email": emailController.text,
              "username": usernameController.text,
              "password": hashedPassword,
            }).then((_) {
              print("User berhasil ditambahkan!");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            }).catchError((error) {
              print("Gagal menambahkan user: $error");
            });
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
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
