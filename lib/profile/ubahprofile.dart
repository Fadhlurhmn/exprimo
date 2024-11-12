import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ubahusername.dart';
import 'ubahemail.dart';

class UbahProfilePage extends StatefulWidget {
  @override
  _UbahProfilePageState createState() => _UbahProfilePageState();
}

class _UbahProfilePageState extends State<UbahProfilePage> {
  String currentUsername = 'Loading...';
  String currentEmail = 'Loading...';
  String currentPassword = '********';
  String profileImageUrl = '';
  File? _imageFile;
  DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (userId != null) {
      DatabaseEvent event = await usersRef.child(userId!).once();
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> userData = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          currentUsername = userData['username'] ?? 'Unknown';
          currentEmail = userData['email'] ?? 'Unknown';
          profileImageUrl = userData['profileImageUrl'] ?? '';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImageToFirebase();
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (_imageFile != null && userId != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
        await storageRef.putFile(_imageFile!);

        String downloadUrl = await storageRef.getDownloadURL();
        await usersRef.child(userId!).update({'profileImageUrl': downloadUrl});

        setState(() {
          profileImageUrl = downloadUrl;
        });
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  Future<void> _updateUsername(String newUsername) async {
    if (userId != null) {
      await usersRef.child(userId!).update({'username': newUsername});
      setState(() {
        currentUsername = newUsername;
      });
    }
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
          'Ubah Profil',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            // Profile Picture with Edit Icon
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : AssetImage('assets/placeholder_profile.png') as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            Text(
              'Profile Information',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            SizedBox(height: 20),

            // Username, Email, Password
            ProfileItem(
              label: 'Username',
              value: currentUsername,
              onTap: () async {
                final updatedUsername = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditUsernamePage(username: currentUsername),
                  ),
                );
                if (updatedUsername != null && updatedUsername is String) {
                  await _updateUsername(updatedUsername);
                }
              },
            ),

            ProfileItem(
              label: 'Email',
              value: currentEmail,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UbahEmailPage(),
                  ),
                );
              },
            ),
            ProfileItem(
              label: 'Password',
              value: currentPassword,
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Widget for Profile Information
class ProfileItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const ProfileItem({
    Key? key,
    required this.label,
    required this.value,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.pink[50],
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 5),
                    Text(
                      value,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
