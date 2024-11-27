import 'dart:io';
import 'package:exprimo/model/imageModel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseApi {
  static Future<List<String>> _getDownloadLinks(List<Reference> refs) =>
      Future.wait(refs.map((ref) => ref.getDownloadURL()).toList());

  static Future<List<ImageModel>> listAll(String path) async {
    final ref = FirebaseStorage.instance.ref(path);
    final result = await ref.listAll();

    final urls = await _getDownloadLinks(result.items);

    return urls
        .asMap()
        .map((index, url) {
          final ref = result.items[index];
          final name = ref.name;
          final file = ImageModel(ref: ref, imageUrl: url, imageName: name);

          return MapEntry(index, file);
        })
        .values
        .toList();
  }

  static Future downloadFile(Reference ref) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${ref.name}');

    await ref.writeToFile(file);
  }
  // static Future<File?> downloadFile(String username, String fileName, String path) async {
  //   try {
  //     final ref = FirebaseStorage.instance.ref('$path/$username/$fileName');
  //     final dir = await getApplicationDocumentsDirectory();
  //     final file = File('${dir.path}/$fileName');

  //     await ref.writeToFile(file);
  //     print("File berhasil diunduh ke ${file.path}");
  //     return file;
  //   } catch (e) {
  //     print("Error saat mendownload file: $e");
  //     return null;
  //   }
  // }
}