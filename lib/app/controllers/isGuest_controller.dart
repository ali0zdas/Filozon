import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:filozon_kodfu/app/controllers/profile_controller.dart';

class IsGuestController extends GetxController {
  // Misafir kullanıcı durumu için reaktif değişken
  final RxBool isGuestUser = false.obs;
  final RxString userDisplayName = "".obs;

  @override
  void onInit() {
    super.onInit();
    checkGuestStatus();
  }

  // Misafir kullanıcı kontrolü yapar
  void checkGuestStatus([String? providedEmail]) {
    isGuestUser.value = false;
    
    if (providedEmail != null) {
      if (providedEmail == "guest") {
        isGuestUser.value = true;
        userDisplayName.value = "Misafir";
      } else {
        isGuestUser.value = false;
        userDisplayName.value = providedEmail;
      }
    } else {
      // FirebaseAuth'dan mevcut kullanıcıyı kontrol et
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null && user.email!.isNotEmpty) {
        isGuestUser.value = false;
        userDisplayName.value = user.email!;
      } else {
        // Kullanıcı giriş yapmamış veya email yok
        isGuestUser.value = true;
        userDisplayName.value = "Giriş yapılmadı";
      }
    }
  }
  
  // Misafir giriş yapmak için çağrılır
  Future<void> setGuestLogin() async {
    // Önce mevcut oturumu sonlandır
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }
    
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
      print('Misafir girişinde profil temizlenirken hata: $e');
    }
    
    // Misafir olarak işaretle
    isGuestUser.value = true;
    userDisplayName.value = "Misafir";
  }
  
  // Normal kullanıcı girişi için çağrılır
  void setUserLogin(String email) {
    isGuestUser.value = false;
    userDisplayName.value = email;
  }
  
  // Çıkış yapıldığında çağrılır
  void resetUser() {
    isGuestUser.value = false;
    userDisplayName.value = "Giriş yapılmadı";
  }
} 