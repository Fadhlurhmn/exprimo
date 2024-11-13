import 'package:exprimo/model/laporan_bug.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exprimo/login/login_screen.dart';
import 'ubahprofile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userId = "";

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? "";
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Menggunakan StreamBuilder untuk memantau perubahan username dan profileImageUrl
              StreamBuilder(
                stream: FirebaseDatabase.instance.ref("users/$userId").onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data!.snapshot.value != null) {
                    final data = snapshot.data!.snapshot.value as Map;

                    // Mendapatkan username dan URL gambar profil dari Firebase
                    String username = data['username'] ?? "Pengguna";
                    String profileImageUrl = data['profileImageUrl'] ??
                        'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png';

                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundImage: NetworkImage(profileImageUrl),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              const SizedBox(height: 40),
              MenuButton(
                icon: Icons.edit,
                label: 'Ubah Profil',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UbahProfilePage(),
                    ),
                  );
                },
              ),
              MenuButton(
                icon: Icons.bug_report,
                label: 'Laporkan bug',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => BugReportModal(),
                  );
                },
              ),
              MenuButton(
                icon: Icons.logout,
                label: 'Keluar',
                onTap: _logout,
                isLogout: true,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLogout;

  const MenuButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLogout = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isLogout ? Colors.red[50] : Colors.pink[50],
          foregroundColor: isLogout ? Colors.red : Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            children: [
              Icon(icon, color: isLogout ? Colors.red : Colors.black),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 16),
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

class BugReportModal extends StatefulWidget {
  @override
  _BugReportModalState createState() => _BugReportModalState();
}

class _BugReportModalState extends State<BugReportModal> {
  final TextEditingController _reportController = TextEditingController();
  String userId = "";

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Isi laporan mu dibawah ini',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _reportController,
            maxLength: 255,
            decoration: InputDecoration(
              hintText: 'Laporan...',
              filled: true,
              fillColor: Colors.pink[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.cancel, color: Colors.grey),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final report = LaporanBug(
                laporan: _reportController.text,
                userid: userId,
              );

              await FirebaseDatabase.instance
                  .ref("reports")
                  .push()
                  .set(report.toJson());

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Laporan berhasil dikirim!"),
                  backgroundColor: Colors.green,
                ),
              );

              _reportController.clear();
              Navigator.pop(context);
            },
            child: const Text("Kirim Laporan"),
          ),
        ],
      ),
    );
  }
}
