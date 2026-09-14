part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  
  static const SPLASH = '/splash';
  static const ONBOARDING = '/onboarding';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const PRODUCT_DETAIL = '/product-detail';
  static const CART = '/cart';
  static const PAYMENT = '/payment';
  static const CREDIT_CARD = '/credit-card';
  static const PROFILE = '/profile';
  static const FILOZON_CLOUD = '/filozon-cloud';
  static const ADDRESSES = '/addresses';
  static const ORDERS = '/orders';
  static const ADMIN_ORDERS = '/admin/orders';
  static const ADMIN_USERS = '/admin/users';
  static const ADMIN_PRODUCTS = '/admin/products';
  static const ADMIN_ADD_PRODUCT = '/admin/products/add';
  static const ADMIN_DASHBOARD = '/admin/dashboard';
} 