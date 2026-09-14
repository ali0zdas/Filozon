import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:filozon_kodfu/app/models/address_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class AddressController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = Uuid();
  
  final RxList<Address> addresses = <Address>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }
  
  // Kullanıcının adreslerini getir
  Future<void> fetchAddresses() async {
    try {
      isLoading(true);
      final user = _auth.currentUser;
      if (user != null) {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('userData')
            .doc('Address')
            .collection('items')
            .get();
        
        final List<Address> fetchedAddresses = querySnapshot.docs
            .map((doc) {
              Map<String, dynamic> data = doc.data();
              data['id'] = doc.id; // Firestore belge ID'sini ekle
              return Address.fromMap(data);
            })
            .toList();
        
        addresses.assignAll(fetchedAddresses);
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Adresler yüklenirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF23243A),
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
  
  // Yeni adres ekle
  Future<void> addAddress(Address address) async {
    try {
      isLoading(true);
      final user = _auth.currentUser;
      if (user != null) {
        // Benzersiz bir ID oluştur
        final String addressId = _uuid.v4();
        address.id = addressId;
        
        // Firestore'a ekle
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('userData')
            .doc('Address')
            .collection('items')
            .doc(addressId)
            .set(address.toMap());
        
        // Lokale ekle
        addresses.add(address);
        
        Get.back(); // Adres ekleme sayfasından çık
        Get.snackbar(
          'Başarılı',
          'Adres başarıyla eklendi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF23243A),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Adres eklenirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF23243A),
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
  
  // Adres güncelle
  Future<void> updateAddress(Address address) async {
    try {
      isLoading(true);
      final user = _auth.currentUser;
      if (user != null && address.id != null) {
        // Firestore'da güncelle
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('userData')
            .doc('Address')
            .collection('items')
            .doc(address.id)
            .update(address.toMap());
        
        // Lokalde güncelle
        final index = addresses.indexWhere((item) => item.id == address.id);
        if (index != -1) {
          addresses[index] = address;
        }
        
        Get.back(); // Adres düzenleme sayfasından çık
        Get.snackbar(
          'Başarılı',
          'Adres başarıyla güncellendi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF23243A),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Adres güncellenirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF23243A),
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
  
  // Adres sil
  Future<void> deleteAddress(String addressId) async {
    try {
      isLoading(true);
      final user = _auth.currentUser;
      if (user != null) {
        // Firestore'dan sil
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('userData')
            .doc('Address')
            .collection('items')
            .doc(addressId)
            .delete();
        
        // Lokalden sil
        addresses.removeWhere((address) => address.id == addressId);
        
        Get.snackbar(
          'Başarılı',
          'Adres başarıyla silindi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF23243A),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Adres silinirken bir hata oluştu: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF23243A),
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
} 