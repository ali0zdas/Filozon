class FileModel {
  final String name;        // Dosya adı
  final String url;         // Dosyanın indirilebilir URL'i
  final int size;           // Dosya boyutu (byte)
  final String type;        // Dosya tipi (image, video, document, other)
  final DateTime uploadedAt; // Yüklenme tarihi

  FileModel({
    required this.name,
    required this.url,
    required this.size,
    required this.type,
    required this.uploadedAt,
  });

  // Firestore'dan veriyi model'e dönüştürmek için
  factory FileModel.fromMap(Map<String, dynamic> map) {
    return FileModel(
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      size: map['size'] ?? 0,
      type: map['type'] ?? 'other',
      uploadedAt: map['uploadedAt'] != null 
        ? (map['uploadedAt'] as DateTime) 
        : DateTime.now(),
    );
  }

  // Model'i Firestore'a kaydetmek için map'e dönüştür
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'size': size,
      'type': type,
      'uploadedAt': uploadedAt,
    };
  }
} 