import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:filozon_kodfu/app/controllers/product_panel_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:filozon_kodfu/app/controllers/category_panel_controller.dart';
import 'package:filozon_kodfu/app/ui/widgets/upload_options_modal.dart';

class AddProductPanel extends StatefulWidget {
  const AddProductPanel({Key? key}) : super(key: key);

  @override
  State<AddProductPanel> createState() => _AddProductPanelState();
}

class _AddProductPanelState extends State<AddProductPanel> {
  late final ProductPanelController _productController;
  late final CategoryPanelController _categoryController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _categoryController = Get.put(CategoryPanelController(), permanent: true);
    _productController = Get.put(ProductPanelController(), permanent: true);
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    Get.delete<ProductPanelController>(force: true);
    Get.delete<CategoryPanelController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0125),
        appBar: AppBar(
          title: Text(
            'Ürün Yönetimi',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            ),
            onPressed: () => Get.back(),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.fromARGB(255, 51, 4, 101), Color.fromARGB(255, 48, 11, 70)],
              ),
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Ürün Ekle'),
              Tab(text: 'Kategori Ekle'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAddProductTab(),
            _buildAddCategoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProductTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            _buildImageUploadSection(),
            const SizedBox(height: 20),
            
            // Product Title
            TextFormField(
              controller: _productController.titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Ürün Adı',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen ürün adını giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Product Price
            TextFormField(
              controller: _productController.priceController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Fiyat',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixText: '₺ ',
                prefixStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen fiyat giriniz';
                }
                if (double.tryParse(value) == null) {
                  return 'Lütfen geçerli bir fiyat giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Product Category Dropdown
            Obx(() {
              if (_categoryController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return DropdownButtonFormField<String>(
                value: _productController.selectedCategoryId.value.isEmpty 
                    ? null 
                    : _productController.selectedCategoryId.value,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white30),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
                dropdownColor: const Color(0xFF1E1E2D),
                style: const TextStyle(color: Colors.white),
                hint: const Text('Kategori seçiniz', style: TextStyle(color: Colors.white70)),
                items: _categoryController.categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _productController.selectedCategoryId.value = value;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir kategori seçiniz';
                  }
                  return null;
                },
              );
            }),
            const SizedBox(height: 16),
            
            // Product Description
            TextFormField(
              controller: _productController.descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Açıklama',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen ürün açıklaması giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Add Product Button
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final success = await _productController.addProduct();
                  if (success) {
                    Get.snackbar(
                      'Başarılı',
                      'Ürün başarıyla eklendi',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 56, 20, 113),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Ürün Ekle', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ürün Resmi', 
          style: TextStyle(color: Colors.white70, fontSize: 14)
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => UploadOptionsModal(
                onPickGallery: () {
                  Navigator.pop(context);
                  _productController.pickImage(source: ImageSource.gallery);
                },
                onPickFiles: () {
                  Navigator.pop(context);
                  _productController.pickImage(source: ImageSource.camera);
                },
              ),
            );
          },
          child: Obx(() {
            final hasWebBytes = _productController.selectedImageBytes.value != null;
            final hasMobileFile = _productController.selectedImage.value != null;
            if (hasWebBytes || hasMobileFile) {
              return Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white30, width: 1),
                  image: DecorationImage(
                    image: hasWebBytes
                        ? MemoryImage(_productController.selectedImageBytes.value!) as ImageProvider
                        : FileImage(_productController.selectedImage.value!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white30, width: 1),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 50, color: Colors.white54),
                    SizedBox(height: 8),
                    Text('Resim Ekle', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              );
            }
          }),
        ),
      ],
    );
  }

  Widget _buildAddCategoryTab() {
    final TextEditingController categoryController = TextEditingController();
    final _categoryFormKey = GlobalKey<FormState>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _categoryFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Name
            TextFormField(
              controller: categoryController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Kategori Adı',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen kategori adını giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Category Image (Optional)
            _buildCategoryImageUploadSection(),
            const SizedBox(height: 24),
            
            // Add Category Button
            ElevatedButton(
              onPressed: () async {
                if (_categoryFormKey.currentState?.validate() ?? false) {
                  final success = await _categoryController.addCategory(
                    categoryController.text.trim(),
                    imageUrl: _categoryController.imageUrl.value,
                  );
                  
                  if (success) {
                    categoryController.clear();
                    _categoryController.imageUrl.value = '';
                    Get.snackbar(
                      'Başarılı',
                      'Kategori başarıyla eklendi',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 75, 42, 122),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Obx(() => _categoryController.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Kategori Ekle', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold))),
            ),
            
            // Categories List
            const SizedBox(height: 24),
            const Text('Mevcut Kategoriler:', 
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (_categoryController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (_categoryController.categories.isEmpty) {
                return const Text('Henüz kategori eklenmemiş', 
                  style: TextStyle(color: Colors.white70)
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categoryController.categories.length,
                itemBuilder: (context, index) {
                  final category = _categoryController.categories[index];
                  return ListTile(
                    leading: (category.imageUrl != null && category.imageUrl!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              category.imageUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image, color: Colors.white70, size: 40);
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.category, color: Colors.white70, size: 24),
                          ),
                    title: Text(category.name, style: const TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // TODO: Implement category deletion
                        Get.snackbar(
                          'Bilgi',
                          'Kategori silme özelliği yakında eklenecek',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kategori Resmi (İsteğe Bağlı)', 
          style: TextStyle(color: Colors.white70, fontSize: 14)
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => UploadOptionsModal(
                onPickGallery: () {
                  Navigator.pop(context);
                  _categoryController.pickImage(source: ImageSource.gallery);
                },
                onPickFiles: () {
                  Navigator.pop(context);
                  _categoryController.pickImage(source: ImageSource.camera);
                },
              ),
            );
          },
          child: Obx(() {
            final hasWebBytes = _categoryController.selectedImageBytes.value != null;
            final hasMobileFile = _categoryController.selectedImage.value != null;
            if (hasWebBytes || hasMobileFile) {
              return Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white30, width: 1),
                  image: DecorationImage(
                    image: hasWebBytes
                        ? MemoryImage(_categoryController.selectedImageBytes.value!) as ImageProvider
                        : FileImage(_categoryController.selectedImage.value!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white30, width: 1),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 40, color: Colors.white54),
                    SizedBox(height: 8),
                    Text('Resim Ekle (İsteğe Bağlı)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              );
            }
          }),
        ),
      ],
    );
  }
}
