import 'package:exprimo/model/userdata.dart';
import 'package:flutter/material.dart';
import 'package:exprimo/login/new_password.dart';
import 'package:exprimo/constants.dart';
import 'package:firebase_database/firebase_database.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

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
        // Wrap the body with SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
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
              'Forgot Password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Please enter your email to reset the password',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Your Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _resetPassword,
                    child: Text(
                      'Reset Password',
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
    );
  }

  void _resetPassword() async {
    String email = _emailController.text;

    if (email.isEmpty) {
      _showAlert('Error', 'Please enter your email');
      return;
    }

    // Optional: Simple email format validation
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showAlert('Error', 'Please enter a valid email');
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    var result = await checkUserID(email);
    bool emailExists = result['exists'];
    String? userId = result['userId'];

    setState(() {
      _isLoading = false; // Hide loading indicator
    });

    if (emailExists) {
      // Navigate to NewPasswordPage if email exists
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewPasswordPage(userId: userId)),
      );
    } else {
      _showAlert('Error', 'Email not registered');
    }
  }

  void _showAlert(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> checkUserID(String email) async {
    DatabaseReference usersRef = database.ref("users");

    try {
      DatabaseEvent event = await usersRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;

        for (var entry in users.entries) {
          var user = entry.value;
          if (user['email'] == email) {
            return {
              'exists': true,
              'userId': entry.key,
            };
          }
        }
      }
    } catch (error) {
      print("Error retrieving users: $error");
    }
    return {'exists': false, 'userId': null};
  }
}
