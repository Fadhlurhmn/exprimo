import 'package:exprimo/welcome/welcome_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:exprimo/login/login_screen.dart';
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

  bool isRegisterButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,  
                child: Padding(
                  padding: EdgeInsets.only(left: size.width * 0.05),  
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: size.width * 0.06,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => WelcomeScreen()),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.001),
              Text(
                'Selamat Datang di Exprimo!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * 0.065,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Image.asset(
                "assets/images/smile.png",
                width: size.width * 0.5,
              ),
              
              SizedBox(height: size.height * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05), // Adjusted padding here
                child: Text(
                  'Yuk, register atau login sekarang untuk akses penuh ke semua fitur menarik di Exprimo!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: blackColor,
                    fontSize: size.width * 0.04,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              // Row dengan tombol Login dan Register
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          color: Colors.black,
                          fontSize: size.width * 0.05,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                          ),
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
                          color: primaryColor,
                          fontSize: size.width * 0.05,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Form section
              Container(
                height: size.height * 0.48,
                color: secondaryColor,
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.04),
                      _buildTextField(
                        controller: emailController,
                        hintText: 'Masukkan email',
                        icon: "assets/icons/Email.png",
                        validator: _validateEmail,
                        errorText: emailError,
                      ),
                      SizedBox(height: size.height * 0.015),
                      _buildTextField(
                        controller: usernameController,
                        hintText: 'Masukkan username',
                        icon: "assets/icons/Person.png",
                        validator: _validateUsername,
                        errorText: usernameError,
                      ),
                      SizedBox(height: size.height * 0.015),
                      _buildTextField(
                        controller: passwordController,
                        hintText: 'Masukkan password',
                        icon: "assets/icons/Lock.png",
                        isPassword: true,
                        validator: _validatePassword,
                        errorText: passwordError,
                      ),
                      SizedBox(height: size.height * 0.04),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            String email = emailController.text;
                            String username = usernameController.text;
                            String password = passwordController.text;

                            bool emailExists = await checkEmailExists(email);
                            bool usernameExists = await checkUsernameExists(username);

                            if (emailExists) {
                              setState(() {
                                emailError = 'Email sudah terdaftar';
                              });
                            } else if (usernameExists) {
                              setState(() {
                                usernameError = 'Username sudah terdaftar';
                              });
                            } else {
                              String hashedPassword = hashPassword(password);

                              await usersRef.push().set({
                                'email': email,
                                'username': username,
                                'password': hashedPassword,
                              });

                              Navigator.pop(context);
                            }
                          }
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: size.width * 0.05,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size(size.width * 0.8, size.height * 0.07),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harap masukkan email.';
    }
    if (!value.endsWith('@gmail.com')) {
      return 'Masukkan email anda';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harap masukkan username.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harap masukkan password.';
    }
    if (value.length < 8) {
      return 'Password harus terdiri dari minimal 8 karakter.';
    }
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String icon,
    required String? Function(String?) validator,
    bool isPassword = false,
    String? errorText,
  }) {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  icon,
                  width: 30,
                  height: 30,
                ),
              ),
            ),
            validator: validator,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              errorText,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Future<bool> checkEmailExists(String email) async {
    DataSnapshot snapshot = await usersRef.orderByChild('email').equalTo(email).get();
    return snapshot.exists;
  }

  Future<bool> checkUsernameExists(String username) async {
    DataSnapshot snapshot = await usersRef.orderByChild('username').equalTo(username).get();
    return snapshot.exists;
  }

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
