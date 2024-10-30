Future<void> loginUser() async {
  try {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (userDoc.exists) {
      UserModel user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>, userDoc.id);
      print("Login berhasil: ${user.username} terdeteksi di database");

      // Lakukan navigasi atau fungsi lainnya setelah login
    } else {
      print("Pengguna tidak ditemukan di database");
    }
  } catch (e) {
    print("Login gagal: $e");
  }
}
