import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:exprimo/constants.dart';
import 'package:exprimo/login/login_screen.dart';

class NewPasswordPage extends StatelessWidget {
  final String? userId; // Add userId parameter
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // GlobalKey for form validation

  NewPasswordPage({this.userId}); // Constructor to accept userId

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 50),
              Icon(
                Icons.lock_outline,
                size: 100,
                color: Colors.black,
              ),
              SizedBox(height: 20),
              Text(
                'Set a New Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Text(
                'Please set a new password for your account',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                obscureText: true,
                controller: _newPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                obscureText: true,
                controller: _confirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _newPassword.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Hash the password
                    String hashedPassword = _hashPassword(_newPassword.text);

                    // Update password in the database
                    await updatePassword(userId, hashedPassword);

                    // Show success dialog
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Success'),
                        content: const Text(
                            'Password has been updated successfully.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              ); // Navigate to LoginScreen
                            },
                            child: const Text('Ok'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Text(
                  'Update Password',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // Konversi password ke bytes
    final hashed = sha256.convert(bytes); // Hash menggunakan SHA-256
    return hashed.toString(); // Ubah hasil hash ke format string
  }

  Future<void> updatePassword(String? userId, String hashedPassword) async {
    if (userId != null) {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref("users/$userId");
      try {
        await userRef.update({'password': hashedPassword});
        print("Password updated successfully for user $userId");
      } catch (error) {
        print("Failed to update password: $error");
      }
    }
  }
}
