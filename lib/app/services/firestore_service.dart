import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:filozon_kodfu/app/models/file_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcı bilgilerini kontrol eder
  User? get currentUser => _auth.currentUser;
  
  // Kullanıcının sepet referansını alır
  DocumentReference get userCartRef => 
      _firestore.collection('users').doc(currentUser!.uid).collection('userData').doc('cart');
  
  // Kullanıcının favori referansını alır
  DocumentReference get userFavoriteRef => 
      _firestore.collection('users').doc(currentUser!.uid).collection('userData').doc('favorites');

  // Kullanıcının dosyalar koleksiyonunu alır
  CollectionReference get userFilesRef =>
      _firestore.collection('users').doc(currentUser!.uid).collection('files');

  // Sepet verilerini getirir
  Future<Set<int>> getUserCart() async {
    try {
      if (currentUser == null) return {};
      
      final docSnapshot = await userCartRef.get();
      
      if (!docSnapshot.exists) {
        return {};
      }
      
      final data = docSnapshot.data() as Map<String, dynamic>;
      final List<dynamic> cartItems = data['productIds'] ?? [];
      return cartItems.map((item) => item as int).toSet();
    } catch (e) {
      print('Sepet verileri alınırken hata: $e');
      return {};
    }
  }

  // Favori verilerini getirir
  Future<Set<int>> getUserFavorites() async {
    try {
      if (currentUser == null) return {};
      
      final docSnapshot = await userFavoriteRef.get();
      
      if (!docSnapshot.exists) {
        return {};
      }
      
      final data = docSnapshot.data() as Map<String, dynamic>;
      final List<dynamic> favoriteItems = data['productIds'] ?? [];
      return favoriteItems.map((item) => item as int).toSet();
    } catch (e) {
      print('Favori verileri alınırken hata: $e');
      return {};
    }
  }

  // Sepete ürün ekler
  Future<void> addToCart(int productId) async {
    try {
      if (currentUser == null) return;
      
      await userCartRef.set({
        'productIds': FieldValue.arrayUnion([productId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Sepete ürün eklerken hata: $e');
    }
  }

  // Sepetten ürün kaldırır
  Future<void> removeFromCart(int productId) async {
    try {
      if (currentUser == null) return;
      
      await userCartRef.update({
        'productIds': FieldValue.arrayRemove([productId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Sepetten ürün kaldırırken hata: $e');
    }
  }

  // Favorilere ürün ekler
  Future<void> addToFavorites(int productId) async {
    try {
      if (currentUser == null) return;
      
      await userFavoriteRef.set({
        'productIds': FieldValue.arrayUnion([productId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Favorilere ürün eklerken hata: $e');
    }
  }

  // Favorilerden ürün kaldırır
  Future<void> removeFromFavorites(int productId) async {
    try {
      if (currentUser == null) return;
      
      await userFavoriteRef.update({
        'productIds': FieldValue.arrayRemove([productId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Favorilerden ürün kaldırırken hata: $e');
    }
  }

  // Dosya bilgisini Firestore'a kaydeder
  Future<void> saveFileInfo(FileModel file) async {
    try {
      if (currentUser == null) return;
      
      await userFilesRef.add(file.toMap());
    } catch (e) {
      print('Dosya bilgisi kaydedilirken hata: $e');
      throw e;
    }
  }

  // Kullanıcının dosyalarını getirir
  Future<List<FileModel>> getUserFiles() async {
    try {
      if (currentUser == null) return [];
      
      final snapshot = await userFilesRef.orderBy('uploadedAt', descending: true).get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Timestamp'i DateTime'a dönüştür
        if (data['uploadedAt'] is Timestamp) {
          data['uploadedAt'] = (data['uploadedAt'] as Timestamp).toDate();
        }
        
        return FileModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Dosya verileri alınırken hata: $e');
      return [];
    }
  }

  // Dosyayı Firestore'dan siler
  Future<void> deleteFile(String fileUrl) async {
    try {
      if (currentUser == null) return;
      
      // Dosya bilgisini Firestore'dan bul ve sil
      final snapshot = await userFilesRef.where('url', isEqualTo: fileUrl).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      
      // Firebase Storage'dan da silmek istiyorsak:
      // NOT: Bu işlem dikkatli yapılmalı, URL'den referans oluşturmak her zaman doğru çalışmaz
      try {
        final storage = FirebaseStorage.instance;
        final ref = storage.refFromURL(fileUrl);
        await ref.delete();
      } catch (storageError) {
        print('Storage\'dan dosya silinirken hata: $storageError');
        // Storage'dan silinmese bile Firestore'dan silindiği için hatayı yutabilir veya raporlayabilirsiniz
      }
    } catch (e) {
      print('Dosya silinirken hata: $e');
      throw e;
    }
  }
} 