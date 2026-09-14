import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:filozon_kodfu/app/models/product_model.dart';
import 'package:filozon_kodfu/app/controllers/category_panel_controller.dart';

class ProductPanelController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  CategoryPanelController? _categoryController;
  
  CategoryPanelController get categoryController {
    _categoryController ??= Get.find<CategoryPanelController>();
    return _categoryController!;
  }
  
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);
  final Rx<XFile?> selectedXFile = Rx<XFile?>(null);
  final RxString selectedCategoryId = ''.obs;
  final RxString imageUrl = ''.obs;

  // Helper method to get category name by ID
  String getCategoryName(String categoryId) {
    if (categoryId.isEmpty) return 'Kategori Yok';
    final category = categoryController.getCategoryById(categoryId);
    return category?.name ?? 'Bilinmeyen Kategori';
  }

  // Form controllers
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  @override
  void onClose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Pick image from gallery or files
  Future<void> pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        selectedXFile.value = image;
        final bytes = await image.readAsBytes();
        selectedImageBytes.value = bytes;
        if (!kIsWeb) {
          selectedImage.value = File(image.path);
        }
      }
    } catch (e) {
      errorMessage.value = 'Resim seçilirken bir hata oluştu: $e';
      Get.snackbar('Hata', errorMessage.value);
    }
  }

  // Upload image to Firebase Storage (supports Web and Mobile)
  Future<String?> uploadProductImage(XFile imageFile, String categoryId) async {
    try {
      isLoading.value = true;
      String extension = path.extension(imageFile.name);
      if (extension.isEmpty) {
        extension = path.extension(imageFile.path);
      }
      if (extension.isEmpty) {
        extension = '.jpg';
      }
      final String fileName = '${const Uuid().v4()}$extension';
      final Reference storageReference = _storage
          .ref()
          .child('products/categories/$categoryId/$fileName');
      
      final String cleanExt = extension.startsWith('.') ? extension.substring(1) : extension;
      final metadata = SettableMetadata(contentType: 'image/$cleanExt');
      
      final UploadTask uploadTask;
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        uploadTask = storageReference.putData(bytes, metadata);
      } else {
        uploadTask = storageReference.putFile(File(imageFile.path), metadata);
      }
      final TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
      final String downloadUrl = await storageSnapshot.ref.getDownloadURL();
      
      imageUrl.value = downloadUrl;
      return downloadUrl;
    } catch (e) {
      errorMessage.value = 'Resim yüklenirken bir hata oluştu: $e';
      Get.snackbar('Hata', errorMessage.value);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new product to Firestore
  Future<bool> addProduct() async {
    try {
      if (selectedXFile.value == null && selectedImage.value == null && selectedImageBytes.value == null) {
        errorMessage.value = 'Lütfen bir resim seçin';
        return false;
      }

      if (selectedCategoryId.value.isEmpty) {
        errorMessage.value = 'Lütfen bir kategori seçin';
        return false;
      }

      final title = titleController.text.trim();
      final priceText = priceController.text.trim();
      final description = descriptionController.text.trim();

      if (title.isEmpty) {
        errorMessage.value = 'Lütfen ürün başlığını girin';
        return false;
      }

      final price = double.tryParse(priceText);
      if (price == null || price <= 0) {
        errorMessage.value = 'Lütfen geçerli bir fiyat girin';
        return false;
      }

      isLoading.value = true;
      errorMessage.value = '';

      // Get category name
      final categoryName = getCategoryName(selectedCategoryId.value);
      if (categoryName == 'Bilinmeyen Kategori') {
        errorMessage.value = 'Geçersiz kategori';
        return false;
      }

      // Upload image to Firebase Storage (supports Web and Mobile)
      final imageXFile = selectedXFile.value;
      String extension = imageXFile != null ? path.extension(imageXFile.name) : '';
      if (extension.isEmpty && selectedImage.value != null) {
        extension = path.extension(selectedImage.value!.path);
      }
      if (extension.isEmpty) {
        extension = '.jpg';
      }
      final String fileName = '${const Uuid().v4()}$extension';
      final Reference storageReference = _storage.ref().child('products/${selectedCategoryId.value}/$fileName');
      
      final String cleanExt = extension.startsWith('.') ? extension.substring(1) : extension;
      final metadata = SettableMetadata(contentType: 'image/$cleanExt');
      
      final UploadTask uploadTask;
      if (kIsWeb && selectedImageBytes.value != null) {
        uploadTask = storageReference.putData(selectedImageBytes.value!, metadata);
      } else if (kIsWeb && imageXFile != null) {
        final bytes = await imageXFile.readAsBytes();
        uploadTask = storageReference.putData(bytes, metadata);
      } else {
        uploadTask = storageReference.putFile(selectedImage.value!, metadata);
      }
      final TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
      final String downloadUrl = await storageSnapshot.ref.getDownloadURL();

      // Create product data
      final productData = {
        'title': title,
        'price': price,
        'description': description,
        'category': selectedCategoryId.value,
        'categoryName': categoryName,
        'image': downloadUrl,
        'rating': 0.0,
        'ratingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add product to Firestore
      await _firestore
          .collection('products')
          .doc(selectedCategoryId.value)
          .collection('items')
          .add(productData);

      // Clear form
      titleController.clear();
      priceController.clear();
      descriptionController.clear();
      selectedImage.value = null;
      selectedCategoryId.value = '';
      imageUrl.value = '';

      Get.snackbar(
        'Başarılı',
        'Ürün başarıyla eklendi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      errorMessage.value = 'Ürün eklenirken bir hata oluştu: $e';
      Get.snackbar(
        'Hata',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch all products
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final categoriesSnapshot = await _firestore.collection('categories').get();
      final List<Product> loadedProducts = [];

      for (var catDoc in categoriesSnapshot.docs) {
        final itemsSnapshot = await _firestore
            .collection('products')
            .doc(catDoc.id)
            .collection('items')
            .get();

        for (var doc in itemsSnapshot.docs) {
          final data = doc.data();
          loadedProducts.add(Product(
            id: int.tryParse(doc.id) ?? doc.id.hashCode,
            title: data['title'] as String? ?? '',
            price: (data['price'] as num?)?.toDouble() ?? 0.0,
            description: data['description'] as String? ?? '',
            category: data['categoryName'] as String? ?? (data['category'] as String? ?? ''),
            image: data['image'] as String?,
          ));
        }
      }

      products.assignAll(loadedProducts);
    } catch (e) {
      errorMessage.value = 'Ürünler yüklenirken bir hata oluştu: $e';
      Get.snackbar('Hata', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Clear form fields
  void clearForm() {
    titleController.clear();
    priceController.clear();
    descriptionController.clear();
    selectedImage.value = null;
    selectedImageBytes.value = null;
    selectedXFile.value = null;
    imageUrl.value = '';
    selectedCategoryId.value = '';
  }
}
