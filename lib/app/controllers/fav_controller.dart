import 'package:get/get.dart';
import 'package:filozon_kodfu/app/services/firestore_service.dart';
import 'package:filozon_kodfu/app/controllers/isGuest_controller.dart';

class FavController extends GetxController {
  final RxSet<int> favoriteIds = <int>{}.obs;
  final RxBool showFavorites = false.obs;
  final FirestoreService _firestoreService = FirestoreService();
  final IsGuestController _isGuestController = Get.find<IsGuestController>();

  @override
  void onInit() {
    super.onInit();
    // Firebase'den favori verilerini al
    loadFavorites();
    
    // Kullanıcı durumu değiştiğinde favorileri güncelle
    ever(_isGuestController.isGuestUser, (_) => loadFavorites());
  }

  Future<void> loadFavorites() async {
    // Misafir kullanıcı değilse Firebase'den verileri yükle
    if (!_isGuestController.isGuestUser.value && _firestoreService.currentUser != null) {
      final userFavorites = await _firestoreService.getUserFavorites();
      favoriteIds.clear();
      favoriteIds.addAll(userFavorites);
    }
  }

  void addToFavorites(int productId) {
    favoriteIds.add(productId);
    
    // Misafir kullanıcı değilse Firebase'e kaydet
    if (!_isGuestController.isGuestUser.value && _firestoreService.currentUser != null) {
      _firestoreService.addToFavorites(productId);
    }
  }

  void removeFromFavorites(int productId) {
    favoriteIds.remove(productId);
    
    // Misafir kullanıcı değilse Firebase'den kaldır
    if (!_isGuestController.isGuestUser.value && _firestoreService.currentUser != null) {
      _firestoreService.removeFromFavorites(productId);
    }
  }

  bool isFavorite(int productId) => favoriteIds.contains(productId);

  void toggleFavorite(int productId) {
    if (isFavorite(productId)) {
      removeFromFavorites(productId);
    } else {
      addToFavorites(productId);
    }
  }

  void setShowFavorites(bool value) {
    showFavorites.value = value;
  }
}
