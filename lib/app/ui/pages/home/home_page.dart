import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../../models/product_model.dart';
import '../../../services/fakestoreAPI_service.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/fav_controller.dart';
import '../../widgets/custom_drawer.dart';
import 'product_detail_page.dart';
import '../payment/cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CartController cartController = Get.isRegistered<CartController>() ? Get.find<CartController>() : Get.put(CartController());
  final FavController favController = Get.isRegistered<FavController>() ? Get.find<FavController>() : Get.put(FavController());
  String guestEmail = "";

  List<List<Product>> _chunkProducts(List<Product> products, int chunkSize) {
    List<List<Product>> chunks = [];
    for (var i = 0; i < products.length; i += chunkSize) {
      chunks.add(products.sublist(i, i + chunkSize > products.length ? products.length : i + chunkSize));
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.put(ProductController());
    
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  'Filozon',
                  textStyle: const TextStyle(
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.bold,
                    fontSize: 34,
                    letterSpacing: 1.4,
                  ),
                  colors: [
                    Colors.white,
                    Colors.blueAccent,
                    Colors.indigo,
                    Colors.white ,
                    Colors.white,
                    Colors.white,
                  ],
                  speed: const Duration(milliseconds: 2000),
                ),
              ],
              isRepeatingAnimation: true,
              repeatForever: true,          
              displayFullTextOnTap: true,
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/icons/filo-icon2.png',
              width: 34,
              height: 34,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Sepet ikonu
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Obx(() {
                    final count = cartController.cartIds.length;
                    if (count == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$count',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                ),
              ],
            ),
            onPressed: () => Get.to(() => CartPage()),
            tooltip: 'Sepetim',
          ),
          if (favController.showFavorites.value || cartController.showCart.value)
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                setState(() {
                  favController.setShowFavorites(false);
                  cartController.setShowCart(false);
                });
              },
            ),
        ],
      ),
      drawer: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: CustomDrawer(
          onFavoritesTap: () {
            setState(() {
              favController.setShowFavorites(!favController.showFavorites.value);
              cartController.setShowCart(false);
            });
            Navigator.of(context).pop();
          },
          onCartTap: () {
            Navigator.of(context).pop();
            Get.to(() => CartPage());
          },
          userEmail: FirebaseAuth.instance.currentUser?.email ?? guestEmail,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color.fromARGB(255, 0, 0, 0),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          
          List<Product> displayProducts;
          if (favController.showFavorites.value) {
            displayProducts = controller.allProducts.where((p) => favController.isFavorite(p.id)).toList();
          } else if (cartController.showCart.value) {
            displayProducts = controller.allProducts.where((p) => cartController.isInCart(p.id)).toList();
          } else if (controller.selectedCategory.value.isNotEmpty) {
            // Filter by selected category
            displayProducts = controller.products;
          } else {
            // Show all products by default
            displayProducts = List.from(controller.allProducts);
          }
          
          return Column(
            children: [
              // Kategori seçim çubuğu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SizedBox(
                  height: 45,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = controller.categories[index];
                      final isSelected = controller.selectedCategory.value == category;
                      return GlassmorphicContainer(
                        width: 100,
                        height: 40,
                        borderRadius: 20,
                        blur: 20,
                        alignment: Alignment.center,
                        border: 2,
                        linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isSelected
                              ? [
                                  const Color(0xFF6C63FF).withOpacity(0.7),
                                  const Color(0xFF4834D4).withOpacity(0.7),
                                ]
                              : [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.5),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              if (controller.selectedCategory.value == category) {
                                // If clicking the same category, clear the filter
                                controller.selectedCategory.value = '';
                                controller.products.value = List.from(controller.allProducts);
                              } else {
                                // Filter by the selected category
                                controller.selectedCategory.value = category;
                                controller.fetchProductsByCategory(category);
                              }
                            },
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Ürünler grid'i
              Expanded(
                child: displayProducts.isEmpty
                    ? Center(
                        child: GlassmorphicContainer(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 200,
                          borderRadius: 20,
                          blur: 20,
                          alignment: Alignment.center,
                          border: 2,
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
                              Colors.white.withOpacity(0.5),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                favController.showFavorites.value
                                    ? Icons.favorite_border
                                    : cartController.showCart.value
                                        ? Icons.shopping_cart_outlined
                                        : Icons.search_off,
                                size: 48,
                                color: Colors.white54,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                favController.showFavorites.value
                                    ? 'Favori ürününüz bulunmamaktadır.'
                                    : cartController.showCart.value
                                        ? 'Sepetiniz boş'
                                        : 'Ürün bulunamadı',
                                style: const TextStyle(color: Colors.white70, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: displayProducts.length,
                        itemBuilder: (context, index) {
                          final product = displayProducts[index];
                          final isFavorite = favController.isFavorite(product.id);
                          final isInCart = cartController.isInCart(product.id);
                          
                          return GestureDetector(
                            onTap: () => Get.to(() => ProductDetailPage(product: product)),
                            child: GlassmorphicContainer(
                              width: double.infinity,
                              height: double.infinity,
                              borderRadius: 16,
                              blur: 20,
                              alignment: Alignment.center,
                              border: 2,
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
                                  Colors.white.withOpacity(0.5),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Ürün resmi
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                          child: CachedNetworkImage(
                                            imageUrl: product.image ?? '',
                                            fit: BoxFit.contain,
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey[800],
                                              child: const Center(child: CircularProgressIndicator()),
                                            ),
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      // Ürün bilgileri
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.title.length > 20
                                                  ? '${product.title.substring(0, 20)}...'
                                                  : product.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '\$${product.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Colors.blueAccent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Favori butonu
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          isFavorite ? Icons.favorite : Icons.favorite_border,
                                          color: isFavorite ? Colors.redAccent : Colors.white,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          favController.toggleFavorite(product.id);
                                          setState(() {});
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                  ),
                                  // Sepete ekle butonu
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                                          color: isInCart ? Colors.greenAccent : Colors.white,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          cartController.toggleCart(product.id);
                                          setState(() {});
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(cartController.isInCart(product.id) 
                                                  ? 'Ürün sepete eklendi!' 
                                                  : 'Ürün sepetten çıkarıldı!'),
                                              duration: const Duration(seconds: 1),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }),
        ),
      ),
    );
  }
}
