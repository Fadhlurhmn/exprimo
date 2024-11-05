import 'package:firebase_database/firebase_database.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

class LaporanBug {
  String laporan;
  int userid;

  LaporanBug({
    required this.laporan,
    required this.userid,
  });

  Map<String, dynamic> toJson() {
    return {
      "laporan": laporan,
      "userid": userid,
    };
  }
}