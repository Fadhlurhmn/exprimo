class ImageModel {
  final String imageUrl;
  final String username; 
  final String imageName;
  final DateTime uploadDate;

  ImageModel({
    required this.imageUrl,
    required this.username, 
    required this.imageName,
    required this.uploadDate,
  });

  // Fungsi untuk mengubah data menjadi Map (untuk Firestore)
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'username': username,
      'imageName': imageName,
      'uploadDate': uploadDate.toIso8601String(),
    };
  }

  // Fungsi untuk membuat objek dari Map
  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      imageUrl: map['imageUrl'] ?? '',
      username: map['username'] ?? '', 
      imageName: map['imageName'] ?? '',
      uploadDate: DateTime.parse(map['uploadDate']),
    );
  }
}
