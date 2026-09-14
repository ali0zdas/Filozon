import 'package:get/get.dart';
import 'package:filozon_kodfu/app/routes/app_pages.dart';
import 'package:filozon_kodfu/app/services/auth_service.dart';

class AdminMiddleware extends GetMiddleware {
  AuthService get _authService => Get.find<AuthService>();

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    try {
      // Kullanıcının admin olup olmadığını kontrol et
      final isAdmin = await _authService.isAdmin();
      
      if (!isAdmin) {
        // Admin değilse ana sayfaya yönlendir
        return GetNavConfig.fromRoute(Routes.HOME);
      }
      
      // Admin ise işleme devam et
      return await super.redirectDelegate(route);
    } catch (e) {
      // Hata durumunda giriş sayfasına yönlendir
      return GetNavConfig.fromRoute(Routes.LOGIN);
    }
  }
}
