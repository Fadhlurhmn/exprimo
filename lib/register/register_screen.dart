import 'package:firebase_database/firebase_database.dart';
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Background(isLoginActive: false),
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
                          validatorMessage: 'Silakan masukkan email.',
                        ),
                        SizedBox(height: size.height * 0.01),
                        _buildTextField(
                          controller: usernameController,
                          hintText: 'Masukkan username',
                          icon: "assets/icons/Person.png",
                          validatorMessage: 'Silakan masukkan username.',
                        ),
                        SizedBox(height: size.height * 0.01),
                        _buildTextField(
                          controller: passwordController,
                          hintText: 'Masukkan password',
                          icon: "assets/icons/Lock.png",
                          isPassword: true,
                          validatorMessage: 'Silakan masukkan password.',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String icon,
    required String validatorMessage,
    bool isPassword = false,
    String? Function(String?)? additionalValidator,
  }) {
    return Container(
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(icon),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validatorMessage;
          }
          if (additionalValidator != null) {
            return additionalValidator(value);
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // Simpan data user ke Firebase Realtime Database
            await usersRef.push().set({
              "email": emailController.text,
              "username": usernameController.text,
              "password": passwordController.text,
            }).then((_) {
              print("User berhasil ditambahkan!");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Homepage()),
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
