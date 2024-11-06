import 'package:flutter/material.dart';
import 'package:exprimo/model/userdata.dart';
import 'package:exprimo/navigation.dart';
import 'package:exprimo/login/forgot_password.dart';
import 'package:exprimo/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk TextField
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Mengecek status login saat inisialisasi
  }

  // Fungsi untuk mengecek apakah user sudah login
  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      // Jika userId ada, langsung navigasi ke menu utama
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
                        SizedBox(height: size.height * 0.05),
                        Container(
                          width: size.width * 0.8,
                          child: ElevatedButton(
                            onPressed: () async {
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
                                  _showErrorDialog(
                                      "Username atau password salah.");
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
                              padding: EdgeInsets.symmetric(vertical: 10),
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

  // Menampilkan dialog error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
