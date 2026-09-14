import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:filozon_kodfu/app/models/order_model.dart' as local;

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final orders = <local.Order>[].obs;
  final isLoading = false.obs;

  Future<bool> addOrder(local.Order order) async {
    try {
      isLoading(true);
      final user = _auth.currentUser;
      if (user != null) {
        // Benzersiz bir orderId oluştur
        final orderId = _firestore.collection('dummy').doc().id;
        order = order.copyWith(orderId: orderId);
        
        print('Sipariş ekleniyor: userId=${user.uid}, orderId=$orderId, data=${order.toMap()}');
        
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('userData')
            .doc('Orders')
            .collection('items')
            .doc(orderId)
            .set(order.toMap());
            
        orders.add(order);
        
        Get.snackbar(
          'Başarılı',
          'Siparişiniz başarıyla oluşturuldu!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF23243A),
          colorText: Colors.white,
        );
        
        return true;
      }
      return false;
    } catch (e) {
      print('Sipariş eklenirken hata: $e');
      Get.snackbar(
        'Hata',
        'Sipariş eklenirken bir hata oluştu: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF23243A),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchOrders() async {
    try {
      isLoading(true);
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('userData')
            .doc('Orders')
            .collection('items')
            .orderBy('orderDate', descending: true)
            .get();
            
        orders.value = snapshot.docs
            .map((doc) => local.Order.fromMap(doc.data()))
            .toList();
      }
    } catch (e) {
      print('Siparişler yüklenirken hata: $e');
      Get.snackbar(
        'Hata',
        'Siparişler yüklenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF23243A),
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
}
