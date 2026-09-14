import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ListProductsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxMap<String, List<Map<String, dynamic>>> productsByCategory = <String, List<Map<String, dynamic>>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllProducts();
  }

  // Tüm ürünleri getir
  Future<void> fetchAllProducts() async {
    try {
      isLoading.value = true;
      products.clear();
      productsByCategory.clear();
      
      // Tüm kategorileri al
      final categoriesSnapshot = await _firestore.collection('categories').get();
      
      // Her kategori için ürünleri çek
      for (var categoryDoc in categoriesSnapshot.docs) {
        final categoryId = categoryDoc.id;
        final categoryName = categoryDoc.data()['name'] ?? 'Bilinmeyen Kategori';
        
        // Kategorinin items alt koleksiyonundan ürünleri çek
        final snapshot = await _firestore
            .collection('products')
            .doc(categoryId)
            .collection('items')
            .get();
            
        final categoryProducts = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          data['categoryId'] = categoryId;
          data['categoryName'] = categoryName;
          return data;
        }).toList();
        
        // Tüm ürünler listesine ekle
        products.addAll(categoryProducts);
        
        // Kategoriye göre grupla
        if (!productsByCategory.containsKey(categoryName)) {
          productsByCategory[categoryName] = [];
        }
        productsByCategory[categoryName]!.addAll(categoryProducts);
      }
      
    } catch (e) {
      Get.snackbar('Hata', 'Ürünler yüklenirken bir hata oluştu: $e');
    } finally {
      isLoading.value = false;
    }
  }


  // Ürün sil
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      // Listeyi güncelle
      await fetchAllProducts();
      Get.snackbar('Başarılı', 'Ürün başarıyla silindi');
    } catch (e) {
      Get.snackbar('Hata', 'Ürün silinirken bir hata oluştu: $e');
    }
  }

  // Kategoriye göre ürün getir
  List<Map<String, dynamic>> getProductsByCategory(String category) {
    // Kategori adına göre ara
    if (productsByCategory.containsKey(category)) {
      return productsByCategory[category]!;
    }
    
    // Kategori ID'sine göre ara
    for (var entry in productsByCategory.entries) {
      if (entry.value.isNotEmpty && 
          (entry.value.first['categoryId'] == category || 
           entry.value.first['categoryName'] == category)) {
        return entry.value;
      }
    }
    
    // Bulunamazsa boş liste döndür
    return [];
  }

  // Tüm kategorileri getir
  List<String> get categories => productsByCategory.keys.toList();
  
  // Kategori ID'sine göre ürün getir
  Future<List<Map<String, dynamic>>> getProductsByCategoryId(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .doc(categoryId)
          .collection('items')
          .get();
          
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['categoryId'] = categoryId;
        return data;
      }).toList();
    } catch (e) {
      Get.snackbar('Hata', 'Ürünler yüklenirken bir hata oluştu: $e');
      return [];
    }
  }
}
