import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product_model.dart';

class ProductController extends GetxController {
  var categories = <String>[].obs;
  var products = <Product>[].obs;
  var allProducts = <Product>[].obs;
  var isLoading = false.obs;
  var selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchAllProducts().then((_) {
      // After fetching all products, set products list to show all products by default
      products.value = List.from(allProducts);
    });
  }

  String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final response = await http
          .get(Uri.parse('https://fakestoreapi.com/products/categories'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> rawCategories = json.decode(response.body);
        categories.value = rawCategories.map((category) {
          String cat = category.toString();
          return cat.split(' ').map((word) => _capitalize(word)).join(' ');
        }).toList();
      }
    } catch (e) {
      print('Kategoriler çekilirken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProductsByCategory(String category) async {
    try {
      isLoading.value = true;
      final lowercaseCategory = category.toLowerCase();
      final response = await http
          .get(Uri.parse('https://fakestoreapi.com/products/category/$lowercaseCategory'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        products.value = (json.decode(response.body) as List)
            .map((e) => Product.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Kategori ürünleri çekilirken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllProducts() async {
    try {
      final response = await http
          .get(Uri.parse('https://fakestoreapi.com/products'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        allProducts.value = (json.decode(response.body) as List)
            .map((e) => Product.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Tüm ürünler çekilirken hata: $e');
    }
  }
}
