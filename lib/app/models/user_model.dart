class UserProfile {
  String? name;
  String? surname;
  String? email;
  String? avatarPath; // Local image path
  String? photoUrl; // Firebase Storage'da saklanan profil fotoğrafının URL'si
  bool isAdmin; // Admin kontrolü için

  UserProfile({
    this.email,
    this.avatarPath,
    this.name,
    this.surname,
    this.photoUrl,
    this.isAdmin = false, // Varsayılan olarak false
  });

  // Firestore'dan gelen verileri UserProfile'a dönüştürme
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'],
      surname: map['surname'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      isAdmin: map['isAdmin'] ?? false,
    );
  }

  // UserProfile'dan Map'e dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'email': email,
      'photoUrl': photoUrl,
      'isAdmin': isAdmin,
    };
  }
}
