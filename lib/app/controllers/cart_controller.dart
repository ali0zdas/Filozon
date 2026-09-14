import 'package:get/get.dart';
import 'package:filozon_kodfu/app/services/firestore_service.dart';
import 'package:filozon_kodfu/app/controllers/isGuest_controller.dart';

class CartController extends GetxController {
  final RxSet<int> cartIds = <int>{}.obs;
  final RxBool showCart = false.obs;
  final FirestoreService _firestoreService = FirestoreService();
  final IsGuestController _isGuestController = Get.find<IsGuestController>();

  @override
  void onInit() {
    super.onInit();
    // Firebase'den sepet verilerini al
    loadCart();
    
    // Kullanıcı durumu değiştiğinde sepeti güncelle
    ever(_isGuestController.isGuestUser, (_) => loadCart());
  }

  Future<void> loadCart() async {
    // Misafir kullanıcı değilse Firebase'den verileri yükle
    if (!_isGuestController.isGuestUser.value && _firestoreService.currentUser != null) {
      final userCart = await _firestoreService.getUserCart();
      cartIds.clear();
      cartIds.addAll(userCart);
    }
  }

  void addToCart(int productId) {
    cartIds.add(productId);
    
    // Misafir kullanıcı değilse Firebase'e kaydet
    if (!_isGuestController.isGuestUser.value && _firestoreService.currentUser != null) {
      _firestoreService.addToCart(productId);
    }
  }

  void removeFromCart(int productId) {
    cartIds.remove(productId);
    
    // Misafir kullanıcı değilse Firebase'den kaldır
    if (!_isGuestController.isGuestUser.value && _firestoreService.currentUser != null) {
      _firestoreService.removeFromCart(productId);
    }
  }

  bool isInCart(int productId) => cartIds.contains(productId);

  void toggleCart(int productId) {
    if (isInCart(productId)) {
      removeFromCart(productId);
    } else {
      addToCart(productId);
    }
  }

  void setShowCart(bool value) {
    showCart.value = value;
  }
}
