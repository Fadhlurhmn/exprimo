import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'ubahusername.dart';
import 'ubahemail.dart';

class UbahProfilePage extends StatefulWidget {
  const UbahProfilePage({super.key});

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

        // Upload file ke Firebase Storage
        await storageRef.putFile(_imageFile!);

        // Mendapatkan URL gambar setelah diupload
        String downloadUrl = await storageRef.getDownloadURL();

        // Simpan URL gambar di Realtime Database di field `profileImageUrl`
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

  Future<void> _updatePassword(String newPassword) async {
    if (userId != null) {
      // Hash password sebelum disimpan
      String hashedPassword = hashPassword(newPassword);
      await usersRef.child(userId!).update({'password': hashedPassword});
      setState(() {
        currentPassword = '********'; // Display default masked password
      });
    }
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) {
        String username = '';
        String email = '';
        String newPassword = '';
        final usernameController = TextEditingController();
        final emailController = TextEditingController();
        final passwordController = TextEditingController();

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(Icons.lock_reset, size: 40, color: Colors.pink),
              const SizedBox(height: 10),
              const Text(
                'Change Password',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(
                  controller: usernameController,
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  icon: Icons.person,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  icon: Icons.email,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: passwordController,
                  labelText: 'New Password',
                  hintText: 'Enter your new password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () async {
                username = usernameController.text.trim();
                email = emailController.text.trim();
                newPassword = passwordController.text.trim();

                if (username.isEmpty || email.isEmpty || newPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All fields are required!')),
                  );
                  return;
                }

                DatabaseEvent event = await usersRef.child(userId!).once();
                if (event.snapshot.value != null) {
                  Map<dynamic, dynamic> userData = event.snapshot.value as Map<dynamic, dynamic>;
                  if (userData['username'] == username && userData['email'] == email) {
                    await _updatePassword(newPassword);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password updated successfully!')),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid username or email!')),
                    );
                  }
                }
              },
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.pink),
        filled: true,
        fillColor: Colors.pink[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.pink),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Ubah Profil',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Picture with Edit Icon
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : const AssetImage('assets/placeholder_profile.png') as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              'Profile Information',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            const SizedBox(height: 20),

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
                    builder: (context) => const UbahEmailPage(),
                  ),
                );
              },
            ),
            ProfileItem(
              label: 'Password',
              value: currentPassword,
              onTap: _changePassword,
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
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                    const SizedBox(height: 5),
                    Text(
                      value,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// Fungsi hashing password
String hashPassword(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);
  return digest.toString();
}
