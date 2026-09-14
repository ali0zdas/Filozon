import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filozon_kodfu/app/models/category_model.dart';

class ListCategoriesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Observable variables
  final RxList<Category> categories = <Category>[].obs;
  final RxMap<String, int> productCounts = <String, int>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  // Fetch all categories and product counts
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Fetch categories from the categories collection
      final categoriesSnapshot = await _firestore
          .collection('categories')
          .orderBy('name')
          .get();
      
      // Count products in each category from products/{categoryId}/items
      final Map<String, int> tempCounts = {};
      for (var categoryDoc in categoriesSnapshot.docs) {
        final categoryId = categoryDoc.id;
        final categoryName = categoryDoc.data()['name'] as String? ?? '';
        final itemsSnapshot = await _firestore
            .collection('products')
            .doc(categoryId)
            .collection('items')
            .get();
        final count = itemsSnapshot.docs.length;
        if (categoryName.isNotEmpty) {
          tempCounts[categoryName] = count;
        }
        tempCounts[categoryId] = count;
      }
      
      // Update the reactive variables
      final List<Category> loadedCategories = [];
      
      for (var doc in categoriesSnapshot.docs) {
        loadedCategories.add(Category.fromJson(doc.data(), doc.id));
      }
      
      categories.assignAll(loadedCategories);
      productCounts.value = tempCounts;
      
    } catch (e) {
      errorMessage.value = 'Kategoriler yüklenirken bir hata oluştu: $e';
      Get.snackbar('Hata', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Get product count for a specific category
  int getProductCount(String categoryName) {
    return productCounts[categoryName] ?? 0;
  }
  
  // Get category by ID
  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Delete a category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Find the category to get its name
      final category = getCategoryById(categoryId);
      if (category == null) {
        throw 'Kategori bulunamadı';
      }
      
      // First, check if there are any products in this category
      final querySnapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category.name)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        throw 'Bu kategoride ürünler bulunmaktadır. Önce bu ürünleri silmeniz veya başka bir kategoriye taşımanız gerekmektedir.';
      }
      
      // Delete the category from Firestore
      await _firestore.collection('categories').doc(categoryId).delete();
      
      // Update local state
      categories.removeWhere((c) => c.id == categoryId);
      productCounts.remove(category.name);
      
      return true;
    } catch (e) {
      errorMessage.value = 'Kategori silinirken bir hata oluştu: $e';
      Get.snackbar('Hata', errorMessage.value);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh categories
  Future<void> refresh() async {
    await fetchCategories();
  }
}
