import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/product_model.dart';
import '../../../controllers/fav_controller.dart';
import '../../../controllers/cart_controller.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final List<Product>? products;
  final int? initialIndex;

  const ProductDetailPage({
    Key? key,
    required this.product,
    this.products,
    this.initialIndex,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late int currentIndex;
  late Product currentProduct;
  late final FavController _favController = Get.find<FavController>();
  late final CartController _cartController = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    currentProduct = widget.product;
    currentIndex = widget.initialIndex ?? 0;
  }

  void goToPreviousProduct() {
    if (widget.products != null && currentIndex > 0) {
      setState(() {
        currentIndex--;
        currentProduct = widget.products![currentIndex];
      });
    }
  }

  void goToNextProduct() {
    if (widget.products != null && currentIndex < widget.products!.length - 1) {
      setState(() {
        currentIndex++;
        currentProduct = widget.products![currentIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Ürün Detayı', style: TextStyle(color: Colors.white, fontFamily: 'Kanit')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 22, 21, 75), Color.fromARGB(255, 0, 0, 0)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'product-${currentProduct.id}',
                  child: GlassmorphicContainer(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 250,
                    borderRadius: 20,
                    blur: 20,
                    alignment: Alignment.bottomCenter,
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
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CachedNetworkImage(
                        imageUrl: currentProduct.image!,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GlassmorphicContainer(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 200,
                  padding: EdgeInsets.all(16),
                  borderRadius: 15,
                  blur: 20,
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
                    children: [
                      Text(
                        currentProduct.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          fontFamily: 'Kanit',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.withOpacity(0.3), Colors.blue.withOpacity(0.3)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          currentProduct.category.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassmorphicContainer(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 200,
                  padding: EdgeInsets.all(16),
                  borderRadius: 15,
                  blur: 20,
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
                    children: [
                      Text(
                        '\$${currentProduct.price}',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          fontFamily: 'Kanit',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            currentProduct.rating?.toStringAsFixed(1) ?? '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '(${currentProduct.ratingCount ?? 0} değerlendirme)',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GlassmorphicContainer(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 150,
                  padding: EdgeInsets.all(16),
                  borderRadius: 15,
                  blur: 20,
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
                  child: SingleChildScrollView(
                    child: Text(
                      currentProduct.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (widget.products != null && widget.products!.length > 1)
                  GlassmorphicContainer(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 70,
                    borderRadius: 15,
                    blur: 20,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GlassmorphicContainer(
                          width: 140,
                          height: 50,
                          borderRadius: 12,
                          blur: 20,
                          border: 2,
                          linearGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: currentIndex > 0
                                ? [
                                    Colors.blue.withOpacity(0.3),
                                    Colors.blue.withOpacity(0.1),
                                  ]
                                : [
                                    Colors.grey.withOpacity(0.2),
                                    Colors.grey.withOpacity(0.1),
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
                              onTap: currentIndex > 0 ? goToPreviousProduct : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios,
                                    color: currentIndex > 0 ? Colors.white : Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Önceki',
                                    style: TextStyle(
                                      color: currentIndex > 0 ? Colors.white : Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GlassmorphicContainer(
                          width: 140,
                          height: 50,
                          borderRadius: 12,
                          blur: 20,
                          border: 2,
                          linearGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: (widget.products != null && currentIndex < widget.products!.length - 1)
                                ? [
                                    Colors.blue.withOpacity(0.3),
                                    Colors.blue.withOpacity(0.1),
                                  ]
                                : [
                                    Colors.grey.withOpacity(0.2),
                                    Colors.grey.withOpacity(0.1),
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
                              onTap: (widget.products != null && currentIndex < widget.products!.length - 1)
                                  ? goToNextProduct
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sonraki',
                                    style: TextStyle(
                                      color: (widget.products != null && currentIndex < widget.products!.length - 1)
                                          ? Colors.white
                                          : Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: (widget.products != null && currentIndex < widget.products!.length - 1)
                                        ? Colors.white
                                        : Colors.grey,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: GlassmorphicContainer(
        width: double.infinity,
        height: 90,
        borderRadius: 0,
        blur: 20,
        alignment: Alignment.bottomCenter,
        border: 0,
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Obx(() {
                final isFavorite = _favController.isFavorite(currentProduct.id);
                return GlassmorphicContainer(
                  width: 160,
                  height: 50,
                  borderRadius: 15,
                  blur: 20,
                  border: 2,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isFavorite 
                        ? [
                            Colors.red.withOpacity(0.3),
                            Colors.red.withOpacity(0.1),
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
                      onTap: () => _favController.toggleFavorite(currentProduct.id),
                      borderRadius: BorderRadius.circular(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.redAccent : Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 10),
              Obx(() {
                final isInCart = _cartController.isInCart(currentProduct.id);
                return GlassmorphicContainer(
                  width: 160,
                  height: 50,
                  borderRadius: 15,
                  blur: 20,
                  border: 2,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isInCart
                        ? [
                            Colors.green.withOpacity(0.3),
                            Colors.green.withOpacity(0.1),
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
                      onTap: () => _cartController.toggleCart(currentProduct.id),
                      borderRadius: BorderRadius.circular(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isInCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                            color: isInCart ? Colors.greenAccent : Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isInCart ? 'Sepetten Çıkar' : 'Sepete Ekle',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// Eski popup fonksiyonu yerine doğrudan sayfa açmak için:
void navigateToProductDetail(
  BuildContext context,
  Product product, {
  List<Product>? products,
  int? initialIndex,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ProductDetailPage(
        product: product,
        products: products,
        initialIndex: initialIndex,
      ),
    ),
  );
}
