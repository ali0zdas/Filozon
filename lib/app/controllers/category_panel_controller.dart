import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:filozon_kodfu/app/models/category_model.dart';

class CategoryPanelController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);
  final RxString imageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  // Fetch all categories from Firestore
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final querySnapshot = await _firestore
          .collection('categories')
          .orderBy('name')
          .get();
      
      final List<Category> loadedCategories = [];
      
      for (var doc in querySnapshot.docs) {
        loadedCategories.add(Category.fromJson(doc.data(), doc.id));
      }
      
      categories.assignAll(loadedCategories);
    } catch (e) {
      errorMessage.value = 'Kategoriler yüklenirken bir hata oluştu: $e';
      Get.snackbar('Hata', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Pick image from gallery or files
  Future<void> pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        selectedImageBytes.value = await image.readAsBytes();
        if (!kIsWeb) {
          selectedImage.value = File(image.path);
        }
        // Upload image and get URL
        final uploadedUrl = await _uploadCategoryImage(image);
        if (uploadedUrl != null) {
          imageUrl.value = uploadedUrl;
        }
      }
    } catch (e) {
      errorMessage.value = 'Resim seçilirken bir hata oluştu: $e';
      Get.snackbar('Hata', errorMessage.value);
    }
  }

  // Upload category image to Firebase Storage (supports both Web and Mobile)
  Future<String?> _uploadCategoryImage(XFile imageFile) async {
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
      final Reference storageReference = _storage.ref().child('categories/$fileName');
      
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
      
      return downloadUrl;
    } catch (e) {
      errorMessage.value = 'Resim yüklenirken bir hata oluştu: $e';
      Get.snackbar('Hata', errorMessage.value);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new category to Firestore
  Future<bool> addCategory(String name, {String? imageUrl}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Check if category already exists
      final existingCategory = categories.firstWhereOrNull(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
      
      if (existingCategory != null) {
        errorMessage.value = 'Bu isimde bir kategori zaten mevcut';
        return false;
      }
      
      // Get a reference to the top-level categories collection
      final categoriesRef = _firestore.collection('categories');
      
      final now = Timestamp.now();
      
      // Create a new document in the categories collection
      await categoriesRef.add({
        'name': name.trim(),
        'imageUrl': imageUrl,
        'createdAt': now,
        'updatedAt': now,
      });
      
      // Refresh the categories list
      await fetchCategories();
      return true;
    } catch (e) {
      errorMessage.value = 'Kategori eklenirken bir hata oluştu: $e';
      Get.snackbar('Hata', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get category by ID
  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}
