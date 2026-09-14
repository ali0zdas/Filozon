import 'package:get/get.dart';
import 'package:filozon_kodfu/app/controllers/profile_controller.dart';
import 'package:filozon_kodfu/app/services/auth_service.dart';

class AdminBinding implements Bindings {
  @override
  void dependencies() {
    // Ensure AuthService is initialized
    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService(), permanent: true);
    }
    
    // Ensure ProfileController is initialized
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController(), permanent: true);
    }
  }
}
