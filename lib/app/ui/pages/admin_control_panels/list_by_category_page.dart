import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filozon_kodfu/app/controllers/list_products_controller.dart';

class ListByCategoryPage extends StatefulWidget {
  final String category;
  final String? categoryId;
  
  const ListByCategoryPage({
    Key? key, 
    required this.category,
    this.categoryId,
  }) : super(key: key);

  @override
  State<ListByCategoryPage> createState() => _ListByCategoryPageState();
}

class _ListByCategoryPageState extends State<ListByCategoryPage> {
  final ListProductsController _controller = Get.put(ListProductsController());
  final RxList<Map<String, dynamic>> _products = <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = true.obs;
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }
  
  Future<void> _loadProducts() async {
    try {
      _isLoading.value = true;
      if (widget.categoryId != null) {
        // Kategori ID'si verilmişse, doğrudan o kategorinin ürünlerini yükle
        final products = await _controller.getProductsByCategoryId(widget.categoryId!);
        _products.assignAll(products);
      } else {
        // Kategori ID'si yoksa, kategori adına göre ara
        await _controller.fetchAllProducts();
        final products = _controller.getProductsByCategory(widget.category);
        _products.assignAll(products);
      }
    } catch (e) {
      Get.snackbar('Hata', 'Ürünler yüklenirken bir hata oluştu: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0125),
      appBar: AppBar(
        title: Text(
          widget.category,
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
              colors: [Color(0xFF3B2168), Color(0xFF0F0125)],
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
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (_products.isEmpty) {
          return Center(
            child: Text(
              'Bu kategoride ürün bulunamadı.',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            return _buildProductCard(product);
          },
        );
      }),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      height: 150,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: CachedNetworkImage(
              imageUrl: product['image'] ?? '',
              width: 150,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[800],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.error, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'] ?? 'İsimsiz Ürün',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product['description'] != null && product['description'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        product['description'],
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '${product['price'] ?? '0'} ₺',
                    style: GoogleFonts.poppins(
                      color: Colors.lightBlue  ,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // TODO: Implement edit functionality
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmation(product['id']);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String productId) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF22123B),
        title: Text(
          'Ürünü Sil',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'Bu ürünü silmek istediğinize emin misiniz?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _controller.deleteProduct(productId);
            },
            child: Text(
              'Sil',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
