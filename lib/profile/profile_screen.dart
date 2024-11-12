import 'package:exprimo/model/laporan_bug.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exprimo/login/login_screen.dart';
import 'ubahprofile.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "";
  String userId = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? "";

    if (userId.isNotEmpty) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref("users/$userId");
      userRef.once().then((DatabaseEvent event) {
        final dataSnapshot = event.snapshot;
        if (dataSnapshot.exists) {
          setState(() {
            username = dataSnapshot.child("username").value.toString();
          });
        }
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
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
              CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(
                  'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpixabay.com%2Fid%2Fimages%2Fsearch%2Fgambar%2520profil%2520kosong%2F&psig=AOvVaw0pGloVsAvX9-N_UmqNMZ2Y&ust=1731479094828000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCLC-sMiU1okDFQAAAAAdAAAAABAE',
                ),
              ),
              SizedBox(height: 20),
              Text(
                username,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              MenuButton(
                icon: Icons.edit,
                label: 'Ubah Profil',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UbahProfilePage(),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              SizedBox(height: 40),
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
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                  ),
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
          SizedBox(height: 20),
          Text(
            'Isi laporan mu dibawah ini',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
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
              icon: Icon(Icons.cancel, color: Colors.grey),
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
                SnackBar(
                  content: Text("Laporan berhasil dikirim!"),
                  backgroundColor: Colors.green,
                ),
              );

              _reportController.clear();
              Navigator.pop(context);
            },
            child: Text("Kirim Laporan"),
          ),
        ],
      ),
    );
  }
}