import 'package:firebase_storage/firebase_storage.dart';

class FirebaseFile {
  final Reference ref;
  final String name;
  final String url;
  DateTime? uploadTime;

  FirebaseFile({
    required this.ref,
    required this.name,
    required this.url,
    this.uploadTime,
  });
}