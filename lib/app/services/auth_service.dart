import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:filozon_kodfu/app/controllers/isGuest_controller.dart';
import 'package:filozon_kodfu/app/controllers/cart_controller.dart';
import 'package:filozon_kodfu/app/controllers/fav_controller.dart';
import 'package:filozon_kodfu/app/controllers/profile_controller.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    
    // Kullanıcı durumunu güncelle
    final isGuestController = Get.find<IsGuestController>();
    isGuestController.setUserLogin(email);
    
    // Profil bilgilerini yükle
    await _loadProfileData();
    
    // Sepet ve favorileri yükle
    await _loadUserData();
    
    return result;
  }

  Future<UserCredential> signUp(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    
    // Kullanıcı durumunu güncelle
    final isGuestController = Get.find<IsGuestController>();
    isGuestController.setUserLogin(email);
    
    // Profil bilgilerini yükle
    await _loadProfileData();
    
    // Sepet ve favorileri yükle (yeni kullanıcı olduğu için boş olacak)
    await _loadUserData();
    
    return result;
  }

  // Kullanıcının admin olup olmadığını kontrol et
  Future<bool> isAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.isAnonymous) return false;
      
      final profileController = Get.find<ProfileController>();
      
      // Eğer profil yüklenmemişse yükle
      if (profileController.userProfile.value.email == null) {
        await profileController.loadUserProfile();
      }
      
      // Profil yüklendikten sonra admin kontrolü yap
      return profileController.userProfile.value.isAdmin;
    } catch (e) {
      print('Admin kontrolü sırasında hata: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    
    // Firebase Auth'un kalıcı oturum bilgisini temizle
    await clearPersistedUser();
    
    // Kullanıcı durumunu güncelle
    final isGuestController = Get.find<IsGuestController>();
    isGuestController.resetUser();
    
    // Profil verilerini temizle
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        profileController.userProfile.update((val) {
          val?.email = null;
          val?.name = null;
          val?.surname = null;
          val?.photoUrl = null;
          val?.avatarPath = null;
        });
      }
    } catch (e) {
      print('Profil verileri temizlenirken hata: $e');
    }
    
    // Sepet ve favorileri temizle
    _clearUserData();
  }

  // Firebase Auth'un kalıcı oturum bilgilerini temizler
  Future<void> clearPersistedUser() async {
    try {
      if (kIsWeb) {
        await _auth.setPersistence(Persistence.NONE);
      }
    } catch (e) {
      print('Kalıcı oturum bilgileri temizlenirken hata: $e');
    }
  }

  // Kullanıcının profil verilerini yükler
  Future<void> _loadProfileData() async {
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        await profileController.loadUserProfile();
      } else {
        final profileController = Get.put(ProfileController());
        await profileController.loadUserProfile();
      }
    } catch (e) {
      print('Profil verileri yüklenirken hata: $e');
    }
  }

  // Kullanıcının sepet ve favori verilerini yükler
  Future<void> _loadUserData() async {
    try {
      final cartController = Get.isRegistered<CartController>()
          ? Get.find<CartController>()
          : Get.put(CartController());
      final favController = Get.isRegistered<FavController>()
          ? Get.find<FavController>()
          : Get.put(FavController());
      
      // Sepet ve favori verilerini güncelle
      await cartController.loadCart();
      await favController.loadFavorites();
    } catch (e) {
      print('Kullanıcı verileri yüklenirken hata: $e');
    }
  }

  // Kullanıcının sepet ve favori verilerini temizler
  void _clearUserData() {
    try {
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().cartIds.clear();
      }
      if (Get.isRegistered<FavController>()) {
        Get.find<FavController>().favoriteIds.clear();
      }
    } catch (e) {
      print('Kullanıcı verileri temizlenirken hata: $e');
    }
  }

  User? get currentUser => _auth.currentUser;
}
