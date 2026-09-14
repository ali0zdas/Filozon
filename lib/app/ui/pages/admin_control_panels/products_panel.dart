import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:filozon_kodfu/app/controllers/list_categories_controller.dart';
import 'package:filozon_kodfu/app/controllers/list_products_controller.dart';
import 'package:filozon_kodfu/app/models/category_model.dart';
import 'package:filozon_kodfu/app/ui/pages/admin_control_panels/list_by_category_page.dart';
import 'package:filozon_kodfu/app/routes/app_pages.dart';

class ProductsPanel extends StatefulWidget {
  const ProductsPanel({Key? key}) : super(key: key);

  @override
  State<ProductsPanel> createState() => _ProductsPanelState();
}

class _ProductsPanelState extends State<ProductsPanel> {
  late final ListCategoriesController _categoriesController;

@override
void initState() {
  super.initState();
  _categoriesController = Get.put(ListCategoriesController(), permanent: true);
  Get.put(ListProductsController(), permanent: true);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0125),
      floatingActionButton: Obx(() => FloatingActionButton(
        onPressed: _categoriesController.isLoading.value
            ? null
            : () {
                Get.toNamed(Routes.ADMIN_ADD_PRODUCT);
              },
        backgroundColor: const Color.fromARGB(255, 73, 48, 135),
        child: _categoriesController.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add, color: Colors.white),
      )),
      appBar: AppBar(
        title: Text(
          'Kategoriler',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromARGB(255, 37, 17, 72), Color(0xFF0F0125)],
            ),
          ),
        ),
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
        actions: [
          Obx(() => IconButton(
            icon: _categoriesController.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
            onPressed: _categoriesController.isLoading.value
                ? null
                : () => _categoriesController.refresh(),
          )),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromARGB(255, 33, 15, 62), Color.fromARGB(255, 0, 0, 0)],
          ),
        ),
        child: Obx(() {
          if (_categoriesController.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _categoriesController.errorMessage.value,
                    style: GoogleFonts.poppins(color: Colors.red[300]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _categoriesController.refresh,
                    child: const Text('Yenile'),
                  ),
                ],
              ),
            );
          }
          if (_categoriesController.isLoading.value) {
            return _buildLoadingShimmer();
          }
          return _buildCategoryGrid();
        }),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Ürünler yükleniyor...',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    if (_categoriesController.categories.isEmpty) {
      return Center(
        child: Text(
          'Henüz kategori bulunmuyor',
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: _categoriesController.categories.length,
        itemBuilder: (context, index) {
          final category = _categoriesController.categories[index];
          final listProductsController = Get.find<ListProductsController>();
          final productCount = listProductsController.products
              .where((p) => p['categoryId'] == category.id)
              .length;
          return _buildCategoryCard(category.name, productCount, category: category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(String categoryName, int productCount, {Category? category}) {
    final hasImage = category?.imageUrl != null && category!.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (category != null) {
          Get.to(
            () => ListByCategoryPage(
              category: category.name,
              categoryId: category.id,
            ),
            transition: Transition.rightToLeft,
          );
        } else {
          Get.to(
            () => ListByCategoryPage(category: categoryName),
            transition: Transition.rightToLeft,
          );
        }
      },
      onLongPress: () {
        if (category != null) {
          _showDeleteConfirmationDialog(category);
        }
      },
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 208,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    if (hasImage)
      Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16), // köşeleri yumuşatır
            child: Image.network(
              category.imageUrl!,
              height: 110,
              width: 110,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8), // resim ile başlık arasında boşluk
        ],
      ),
            const SizedBox(height: 8),
            Text(
              categoryName,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$productCount ürün',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<ListCategoriesController>();
    super.dispose();
  }

  void _showDeleteConfirmationDialog(Category category) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Text(
          'Kategoriyi Sil',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '${category.name} kategorisini silmek istediğinize emin misiniz?\nBu işlem geri alınamaz!',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red[900]!.withOpacity(0.3),
              foregroundColor: Colors.red[300],
            ),
            child: Text(
              'Sil',
              style: GoogleFonts.poppins(
                color: Colors.red[300],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _categoriesController.deleteCategory(category.id);
        Get.snackbar(
          'Başarılı',
          '${category.name} kategorisi başarıyla silindi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Hata',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
