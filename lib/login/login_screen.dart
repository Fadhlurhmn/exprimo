import 'package:exprimo/files/file_screen.dart';
import 'package:exprimo/login/forgot_password.dart';
import 'package:exprimo/model/userdata.dart';
import 'package:exprimo/navigation.dart';
import 'package:exprimo/register/register_screen.dart';
import 'package:exprimo/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:exprimo/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

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
  bool _obscurePassword = true; // Mengatur visibilitas password

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    print("Retrieved userId: $userId"); // Log nilai yang diambil
    if (userId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Navigation_menu()),
      );
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      DatabaseReference userRef = FirebaseDatabase.instance.ref('users');
      DatabaseEvent event =
          await userRef.orderByChild('username').equalTo(username).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        print('Username ditemukan: $username');
        Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;
        String storedPasswordHash =
            userData.values.first['password']; // Password yang sudah di-hash

        // Hash password yang dimasukkan pengguna
        String hashedPassword = hashPassword(password);

        if (storedPasswordHash == hashedPassword) {
          String userId = userData.keys.first;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);
          print("User ID stored: $userId");

          return true;
        } else {
          print('Password salah');
          return false;
        }
      } else {
        print('Username tidak ditemukan');
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Padding(
              //   padding: EdgeInsets.only(top: size.height * 0.01, left: size.width * 0.05),
              //   child: Align(
              //     alignment: Alignment.topLeft,
              //     child: IconButton(
              //       icon: Icon(Icons.arrow_back, color: Colors.black, size: size.width * 0.06),
              //       onPressed: () {
              //         Navigator.pushReplacement(
              //           context,
              //           MaterialPageRoute(builder: (context) => WelcomeScreen()),
              //         );
              //       },
              //     ),
              //   ),
              // ),

              // Background section
              Container(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: size.height * 0.05),
                      child: Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                              "assets/images/iconic-2.png",
                              width: size.width * 0.45,
                            ),
                            SizedBox(height: size.height * 0.02),
                            Text(
                              'Yuk, register atau login sekarang untuk akses penuh ke semua fitur menarik di Exprimo!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: blackColor,
                                fontSize: size.width * 0.04,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            SizedBox(height: size.height * 0.04),
                          ],
                        ),
                      ),
                    ),
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
                                color: Colors.white,
                                fontSize: size.width * 0.05,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondaryColor,
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.02),
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
                                color: Colors.black,
                                fontSize: size.width * 0.05,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.02),
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
                  ],
                ),
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
                      SizedBox(height: size.height * 0.015),
                      Container(
                        width: size.width * 0.8,
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword, // Gunakan variabel ini
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword; // Toggle visibility
                                });
                              },
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
                          padding: EdgeInsets.only(top: size.height * 0.005),
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
                                passwordController.text,
                              );
                              if (success) {
                                // Arahkan ke menu navigasi setelah login berhasil
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Navigation_menu(),
                                    //builder: (context) => FilesPage(username: usernameController.text), // Pass username
                                  ),
                                );
                              } else {
                                // Jika login gagal, tampilkan error
                                setState(() {
                                  loginError = true;
                                });
                                _formKey.currentState!
                                    .validate(); // Trigger revalidation untuk menampilkan pesan error
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
            ],
          ),
        ),
      ),
    );
  }
}
