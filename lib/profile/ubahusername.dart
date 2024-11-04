import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EditUsernamePage extends StatefulWidget {
  final String username;

  EditUsernamePage({required this.username});

  @override
  _EditUsernamePageState createState() => _EditUsernamePageState();
}

class _EditUsernamePageState extends State<EditUsernamePage> {
  late TextEditingController _usernameController;
  bool _isButtonEnabled = false;
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);

    // Add listener to detect changes in the TextField
    _usernameController.addListener(() {
      setState(() {
        _isButtonEnabled = _usernameController.text != widget.username;
      });
    });
  }

  Future<bool> checkUsernameExists(String username) async {
    DatabaseEvent event = await usersRef.once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> users = event.snapshot.value as Map<dynamic, dynamic>;
      for (var user in users.values) {
        if (user['username'] == username) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> updateUsername(String newUsername) async {
    // Get the user ID (assuming you have it stored or passed along)
    String userId = ""; // Replace with actual user ID
    await usersRef.child(userId).update({"username": newUsername});
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Text(
              'Username',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.pink[50],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 50),
            Center(
              child: ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () async {
                        String newUsername = _usernameController.text;
                        bool usernameExists = await checkUsernameExists(newUsername);

                        if (!usernameExists) {
                          await updateUsername(newUsername);
                          print("Username updated successfully!");
                          Navigator.pop(context);
                        } else {
                          print("Username already exists!");
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonEnabled ? Colors.pink[300] : Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Update Username',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
