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

  // Fungsi untuk memuat data pengguna berdasarkan userId dari Firebase
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? "";

    if (userId.isNotEmpty) {
      // Ambil data user dari Firebase
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref("users/$userId");
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

  // Fungsi untuk logout dan hapus session
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
      body: Column(
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              'https://media.licdn.com/dms/image/v2/D5603AQEh91D9scCDiw/profile-displayphoto-shrink_200_200/profile-displayphoto-shrink_200_200/0/1721730196006?e=1732752000&v=beta&t=2sLe8Tg8FJulTxBI_90T1V4GEcDhVqnPPrdwtTAyH9k',
            ),
          ),
          SizedBox(height: 20),
          Text(
            username, // Nama dinamis dari Firebase
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
                builder: (context) =>
                    BugReportModal(), // Tidak perlu kirim userId
              );
            },
          ),
          MenuButton(
            icon: Icons.logout,
            label: 'Keluar',
            onTap: _logout,
            isLogout: true,
          ),
        ],
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

  // Fungsi untuk memuat userId dari SharedPreferences
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
                userid: userId, // Gunakan userId yang dimuat dari sesi
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
