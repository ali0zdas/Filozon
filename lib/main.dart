import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:filozon_kodfu/firebase_options.dart';

import 'package:get/get.dart';
import 'package:filozon_kodfu/app/controllers/isGuest_controller.dart';
import 'package:filozon_kodfu/app/controllers/cart_controller.dart';
import 'package:filozon_kodfu/app/controllers/fav_controller.dart';
import 'package:filozon_kodfu/app/controllers/profile_controller.dart';
import 'package:filozon_kodfu/app/services/auth_service.dart';
import 'package:filozon_kodfu/app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Uygulama her başlatıldığında oturum bilgilerini sıfırla
    await resetAuth();
    
  } catch (e) {
    if (e.toString().contains('A Firebase App named "[DEFAULT]" already exists')) {
      // Duplicate app hatasını yoksay
      print('Firebase zaten başlatılmış.');
      // Yine de auth'u resetle
      await resetAuth();
    } else {
      rethrow;
    }
  }
  // Firebase Storage'ı test et
  try {
    final FirebaseStorage storage = FirebaseStorage.instance;
    print('Firebase Storage Bucket: ${storage.bucket}');
    
    // Root reference'ı test et
    final rootRef = storage.ref();
    print('Firebase Storage Root Path: ${rootRef.fullPath}');
    
    // Profile_images klasörünü oluştur (yoksa)
    final profileRef = storage.ref('profile_images');
    print('Firebase Storage Profile Path: ${profileRef.fullPath}');
    
    // Test bitti
    print('Firebase Storage bağlantısı başarılı!');
  } catch (e) {
    print('Firebase Storage başlatma hatası: $e');
  }
  
  // Guest controller'ı oluştur
  final guestController = Get.put(IsGuestController());
  guestController.checkGuestStatus();
  
  runApp(const MyApp());
}

// Uygulama her başladığında oturum bilgilerini sıfırlayan fonksiyon
Future<void> resetAuth() async {
  try {
    // Kalıcı oturum depolaması yalnızca web üzerinde desteklenir
    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.NONE);
    }
    
    // Mevcut oturumu sonlandır
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }
    
    print('Oturum bilgileri sıfırlandı');
  } catch (e) {
    print('Oturum bilgileri sıfırlanırken hata: $e');
  }
}

// Controller'ları başlangıçta bağlamak için bir Binding sınıfı
class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // Servisleri lazy olarak başlat
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    
    // Controller'ları lazy olarak başlat
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    
    // Önce IsGuestController'ı başlat, çünkü diğer kontrolcüler buna bağlı
    Get.lazyPut<IsGuestController>(() => IsGuestController(), fenix: true);
    
    // Sepet ve favori kontrolcülerini başlat
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
    Get.lazyPut<FavController>(() => FavController(), fenix: true);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Filozon',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF181A20),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          surface: const Color(0xFF181A20),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      getPages: AppPages.routes,
    );
  }
}