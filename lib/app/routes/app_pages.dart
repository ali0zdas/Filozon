import 'package:flutter/material.dart';
import 'package:filozon_kodfu/app/ui/pages/payment/cart_page.dart';
import 'package:filozon_kodfu/app/ui/pages/payment/credit_card_page.dart';
import 'package:filozon_kodfu/app/ui/pages/user_panel/filozonCloud_page.dart';
import 'package:filozon_kodfu/app/ui/pages/home/home_page.dart';
import 'package:filozon_kodfu/app/ui/pages/login_register/login_page.dart';
import 'package:filozon_kodfu/app/ui/pages/onboarding_page.dart';
import 'package:filozon_kodfu/app/ui/pages/payment/payment_page.dart';
import 'package:filozon_kodfu/app/ui/pages/home/product_detail_page.dart';
import 'package:filozon_kodfu/app/ui/pages/user_panel/profile_page.dart';
import 'package:filozon_kodfu/app/ui/pages/login_register/register_page.dart';
import 'package:filozon_kodfu/app/ui/pages/splash_page.dart';
import 'package:filozon_kodfu/app/ui/pages/user_panel/addresses_page.dart';
import 'package:filozon_kodfu/app/ui/pages/user_panel/orders_page.dart';
import 'package:filozon_kodfu/app/models/product_model.dart';
import 'package:filozon_kodfu/app/ui/pages/admin_control_panels/admin_dashboard.dart';
import 'package:filozon_kodfu/app/middlewares/admin_middleware.dart';
import 'package:filozon_kodfu/app/bindings/admin_binding.dart';
import 'package:filozon_kodfu/app/ui/pages/admin_control_panels/orders_panel.dart';
import 'package:filozon_kodfu/app/ui/pages/admin_control_panels/users_panel.dart';
import 'package:filozon_kodfu/app/ui/pages/admin_control_panels/products_panel.dart';
import 'package:filozon_kodfu/app/ui/pages/admin_control_panels/add_product_panel.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => OnboardingPage(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomePage(),
    ),
    GetPage(
      name: Routes.PRODUCT_DETAIL,
      page: () {
        final Product product = Get.arguments['product'] as Product;
        return ProductDetailPage(product: product);
      },
    ),
    GetPage(
      name: Routes.CART,
      page: () => CartPage(),
    ),
    GetPage(
      name: Routes.PAYMENT,
      page: () {
        final List<Product> cartProducts = Get.arguments['cartProducts'] as List<Product>;
        final double totalAmount = Get.arguments['totalAmount'] as double;
        return PaymentPage(cartProducts: cartProducts, totalAmount: totalAmount);
      },
    ),
    GetPage(
      name: Routes.CREDIT_CARD,
      page: () {
        final List<Product>? cartProducts = Get.arguments['cartProducts'] as List<Product>?;
        final double? totalAmount = Get.arguments['totalAmount'] as double?;
        final selectedAddress = Get.arguments['selectedAddress'];
        if (cartProducts != null && totalAmount != null && selectedAddress != null) {
          return CreditCardPage(
            cartProducts: cartProducts,
            totalAmount: totalAmount,
            selectedAddress: selectedAddress,
          );
        } else {
          return const Scaffold(
            body: Center(child: Text('Gerekli bilgiler eksik')), 
          );
        }
      },
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfilePage(),
    ),
    GetPage(
      name: Routes.FILOZON_CLOUD,
      page: () => const FilozonCloudPage(),
    ),
    GetPage(
      name: Routes.ADDRESSES,
      page: () => AddressesPage(),
    ),
    GetPage(
      name: Routes.ORDERS,
      page: () => OrdersPage(),
    ),
    GetPage(
      name: Routes.ADMIN_ORDERS,
      page: () => const OrdersPanel(),
      middlewares: [AdminMiddleware()],
      binding: AdminBinding(),
    ),
    GetPage(
      name: Routes.ADMIN_USERS,
      page: () => const UsersPanel(),
      middlewares: [AdminMiddleware()],
      binding: AdminBinding(),
    ),
    GetPage(
      name: Routes.ADMIN_PRODUCTS,
      page: () => ProductsPanel(),
      middlewares: [AdminMiddleware()],
      binding: AdminBinding(),
    ),
    GetPage(
      name: Routes.ADMIN_ADD_PRODUCT,
      page: () => AddProductPanel(),
      middlewares: [AdminMiddleware()],
      binding: AdminBinding(),
    ),
    GetPage(
      name: Routes.ADMIN_DASHBOARD,
      page: () => AdminDashboard(),
      middlewares: [AdminMiddleware()],
      binding: AdminBinding(),
    ),
  ];
} 