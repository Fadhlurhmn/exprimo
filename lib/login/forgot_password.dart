import 'package:flutter/material.dart';
import 'package:exprimo/login/new_password.dart';
import 'package:exprimo/constants.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

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
      body: Padding(
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
                  fontSize: 16, color: Colors.black54, fontFamily: 'Inter'),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor, // Button color
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                String email = _emailController.text;
                if (email.isEmpty) {
                  // Tampilkan Alert jika email kosong
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please enter your email'),
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
                } else {
                  // Navigate ke NewPasswordPage jika email tidak kosong
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewPasswordPage()),
                  );
                }
              },
              child: Text(
                'Reset Password',
                style: TextStyle(
                    fontSize: 16, color: Colors.white, fontFamily: 'Roboto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
