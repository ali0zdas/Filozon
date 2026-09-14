import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'dart:io' show File;

class ProfileController extends GetxController {
  Rx<UserProfile> userProfile = UserProfile().obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  // Firestore'dan kullanıcı profilini yükle
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      
      // Eğer kullanıcı yoksa ya da anonym kullanıcı ise profil bilgilerini temizle
      if (user == null || user.isAnonymous) {
        userProfile.update((val) {
          val?.email = null;
          val?.name = null;
          val?.surname = null;
          val?.photoUrl = null;
          val?.avatarPath = null;
        });
        isLoading.value = false;
        return;
      }
      
      // Kullanıcı email bilgisi kontrol edilir
      if (user.email != null && user.email!.isNotEmpty) {
        try {
          final docSnapshot = await _firestore.collection('users').doc(user.uid).get();

          if (docSnapshot.exists) {
            final data = docSnapshot.data() as Map<String, dynamic>;
            // Firestore'dan gelen verileri kullanarak UserProfile oluştur
            final profile = UserProfile.fromMap(data);
            userProfile.update((val) {
              val?.email = user.email;
              val?.name = profile.name;
              val?.surname = profile.surname;
              val?.email = user.email;
              val?.photoUrl = profile.photoUrl;
              val?.isAdmin = profile.isAdmin;
              val?.avatarPath = null; // Reset local path when loading from Firestore
            });
            
            print('Profil bilgileri başarıyla yüklendi: ${user.email}');
          } else {
            // Kullanıcı belgesi yoksa temel bilgilerle oluştur
            await _firestore.collection('users').doc(user.uid).set({
              'email': user.email,
              'isAdmin': false, // Varsayılan olarak admin değil
              'createdAt': FieldValue.serverTimestamp(),
            });
            
            userProfile.update((val) {
              val?.email = user.email;
              val?.name = '';
              val?.surname = '';
              val?.photoUrl = '';
              val?.isAdmin = false; // Varsayılan olarak admin değil
            });
            
            print('Yeni kullanıcı profili oluşturuldu: ${user.email}');
          }
        } catch (e) {
          print('Firestore veri yükleme hatası: $e');
          // Firestore hatası olsa bile temel email bilgisini ayarla
          userProfile.update((val) {
            val?.email = user.email;
          });
        }
      } else {
        // Email yoksa kullanıcı bilgilerini temizle
        userProfile.update((val) {
          val?.email = null;
          val?.name = null;
          val?.surname = null;
          val?.photoUrl = null;
          val?.avatarPath = null;
        });
        
        print('Kullanıcının email bilgisi olmadığı için profil temizlendi');
      }
    } catch (e) {
      print('Profil yükleme hatası: $e');
      Get.snackbar(
        'Hata',
        'Kullanıcı profili yüklenirken bir hata oluştu: $e',
        backgroundColor: const Color(0xFF23243A),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Profil fotoğrafını galeriden seçer ve Firebase Storage'a yükler
  Future<void> pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await _uploadImageToStorage(pickedFile);
      } else {
        Get.snackbar(
          'Bilgi',
          'Fotoğraf seçilmedi.',
          backgroundColor: const Color(0xFF23243A),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Resim seçilirken bir hata oluştu: $e',
        backgroundColor: const Color(0xFF23243A),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  /// Seçilen resmi Firebase Storage'a yükler ve URL'sini Firestore'a kaydeder
  Future<void> _uploadImageToStorage(XFile imageFile) async {
    isLoading.value = true;
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Hata',
          'Profil fotoğrafı yüklemek için giriş yapmalısınız.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      // 1. Referans Yolu Oluşturma
      String fileExtension = p.extension(imageFile.name);
      if (fileExtension.isEmpty) {
        fileExtension = p.extension(imageFile.path);
      }
      if (fileExtension.isEmpty) {
        fileExtension = '.jpg';
      }
      final cleanExt = fileExtension.startsWith('.') ? fileExtension.substring(1) : fileExtension;
      final fileName = '${user.uid}$fileExtension';
      final Reference storageRef =
          _storage.ref().child('profile_images').child(fileName);

      // 2. Dosyayı Yükleme (Web için putData, mobil için putFile)
      final metadata = SettableMetadata(contentType: 'image/$cleanExt');
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        await storageRef.putData(bytes, metadata);
      } else {
        await storageRef.putFile(File(imageFile.path), metadata);
      }

      // 3. İndirme URL'sini Alma
      final downloadUrl = await storageRef.getDownloadURL();

      // 4. URL'yi Firestore'a Kaydetme
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 5. Lokal profili güncelle
      userProfile.update((val) {
        val?.photoUrl = downloadUrl;
      });

      Get.snackbar(
        'Başarılı',
        'Profil fotoğrafı başarıyla güncellendi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseException catch (e) {
      Get.snackbar(
        'Hata',
        'Fotoğraf yüklenemedi: ${e.message ?? "Bilinmeyen bir Firebase hatası."}',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Beklenmedik bir hata oluştu: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setEmail(String? email) {
    userProfile.update((val) {
      val?.email = email;
    });
  }

  void setAvatarPath(String? path) {
    userProfile.update((val) {
      val?.avatarPath = path;
    });
  }

  void setPhotoUrl(String url) {
    userProfile.update((val) {
      val?.photoUrl = url;
    });
  }
}