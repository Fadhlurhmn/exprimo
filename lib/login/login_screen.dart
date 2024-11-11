import 'package:flutter/material.dart';
import 'package:exprimo/model/userdata.dart';
import 'package:exprimo/navigation.dart';
import 'package:exprimo/login/forgot_password.dart';
import 'package:exprimo/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exprimo/login/background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool loginError = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Navigation_menu()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            
            Container(
              height: size.height * 0.59,
              child: Background(isLoginActive: true),
            ),

            // Login form now takes 45% of screen height
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
                        SizedBox(height: size.height * 0.05), // Adjusted height to move down
                        // Username Input Field
                        Container(
                          width: size.width * 0.8,
                          child: TextFormField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              hintText: 'Masukkan username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  "assets/icons/Person.png",
                                  width: size.width * 0.06,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Harap masukkan username.';
                              }
                              if (loginError) {
                                return 'Username salah.';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                        // Password Input Field
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
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  "assets/icons/Lock.png",
                                  width: size.width * 0.06,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Harap masukkan password.';
                              }
                              if (loginError) {
                                return 'Password salah.';
                              }
                              return null;
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(top: size.height * 0.02), // Adjust the value as needed
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
                        ),

                        SizedBox(height: size.height * 0.04),
                        // Login Button
                        Container(
                          width: size.width * 0.8,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                loginError = false;
                              });

                              if (_formKey.currentState!.validate()) {
                                bool success = await login(
                                    usernameController.text,
                                    passwordController.text);
                                if (success) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Navigation_menu()),
                                  );
                                } else {
                                  setState(() {
                                    loginError = true;
                                  });
                                  _formKey.currentState!.validate();
                                }
                              }
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: size.width * 0.05,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: secondaryColor,
                              padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
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
}
