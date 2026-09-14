import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:filozon_kodfu/app/models/file_model.dart';
import 'package:filozon_kodfu/app/services/firestore_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class UploadController extends GetxController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  final Rx<FileModel?> lastUploadedFile = Rx<FileModel?>(null);
  final RxList<FileModel> userFiles = <FileModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Kullanıcının dosyalarını yükle
    loadUserFiles();
  }

  // Kullanıcının dosyalarını Firestore'dan yükle
  Future<void> loadUserFiles() async {
    try {
      if (_auth.currentUser == null) return;
      
      final files = await _firestoreService.getUserFiles();
      userFiles.assignAll(files);
    } catch (e) {
      print('Kullanıcı dosyaları yüklenirken hata: $e');
    }
  }

  Future<void> pickAndUploadFile({required bool fromGallery}) async {
    try {
      // Kullanıcı girişi yapılmış mı kontrol et
      if (_auth.currentUser == null) {
        Get.snackbar(
          'Giriş Gerekli',
          'Dosya yüklemek için önce giriş yapmalısınız',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      File? pickedFile;
      Uint8List? pickedBytes;
      String fileName = '';
      int fileSize = 0;
      
      if (fromGallery) {
        // Galeriden dosya seçme
        final picker = ImagePicker();
        final pickedImage = await picker.pickImage(source: ImageSource.gallery);
        
        if (pickedImage == null) return;
        fileName = pickedImage.name.isNotEmpty ? pickedImage.name : path.basename(pickedImage.path);
        
        if (kIsWeb) {
          pickedBytes = await pickedImage.readAsBytes();
          fileSize = pickedBytes.length;
        } else {
          pickedFile = File(pickedImage.path);
          fileSize = await pickedFile.length();
        }
      } else {
        // Dosya seçme
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          withData: kIsWeb,
        );
        
        if (result == null || result.files.isEmpty) return;
        final platformFile = result.files.single;
        fileName = platformFile.name;
        fileSize = platformFile.size;

        if (kIsWeb) {
          pickedBytes = platformFile.bytes;
          if (pickedBytes == null) return;
        } else {
          if (platformFile.path == null) return;
          pickedFile = File(platformFile.path!);
        }
      }

      if (kIsWeb && pickedBytes != null) {
        await uploadBytes(pickedBytes, fileName, fileSize);
      } else if (pickedFile != null) {
        await uploadFile(pickedFile, fileName);
      }
    } catch (e) {
      isUploading.value = false;
      Get.snackbar(
        'Hata',
        'Dosya yükleme sırasında bir hata oluştu: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> uploadBytes(Uint8List bytes, String fileName, int fileSize) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Giriş Gerekli',
          'Dosya yüklemek için önce giriş yapmalısınız',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      isUploading.value = true;
      uploadProgress.value = 0.0;

      String extension = path.extension(fileName).toLowerCase();
      String userId = user.uid;
      String storagePath = 'users/$userId/files/$fileName';
      
      final uploadTask = _storage.ref().child(storagePath).putData(
        bytes,
        SettableMetadata(contentType: _getContentType(extension)),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          uploadProgress.value = snapshot.bytesTransferred / snapshot.totalBytes;
        }
      });

      await uploadTask.whenComplete(() => null);
      String downloadUrl = await _storage.ref(storagePath).getDownloadURL();
      
      final fileModel = FileModel(
        name: fileName,
        url: downloadUrl,
        size: fileSize,
        type: _getFileType(extension),
        uploadedAt: DateTime.now(),
      );
      
      await _firestoreService.saveFileInfo(fileModel);
      
      lastUploadedFile.value = fileModel;
      userFiles.insert(0, fileModel);
      
      isUploading.value = false;
      
      Get.snackbar(
        'Başarılı',
        'Dosya başarıyla yüklendi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      isUploading.value = false;
      Get.snackbar(
        'Hata',
        'Dosya yükleme sırasında bir hata oluştu: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> uploadFile(File file, String fileName) async {
    try {
      // Kullanıcı girişi yapılmış mı kontrol et
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Giriş Gerekli',
          'Dosya yüklemek için önce giriş yapmalısınız',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      isUploading.value = true;
      uploadProgress.value = 0.0;

      // Dosya uzantısını ve boyutunu al
      String extension = path.extension(fileName).toLowerCase();
      int fileSize = await file.length();
      
      // Kullanıcı ID'sini kullanarak dosya yolu oluştur
      String userId = user.uid;
      String storagePath = 'users/$userId/files/$fileName';
      
      // Firebase Storage'a dosyayı yükle
      final uploadTask = _storage.ref().child(storagePath).putFile(
        file,
        SettableMetadata(contentType: _getContentType(extension)),
      );

      // İlerleme durumunu takip et
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          uploadProgress.value = snapshot.bytesTransferred / snapshot.totalBytes;
        }
      });

      // Yükleme tamamlandığında download URL'i al
      await uploadTask.whenComplete(() => null);
      String downloadUrl = await _storage.ref(storagePath).getDownloadURL();
      
      // Dosya modelini oluştur
      final fileModel = FileModel(
        name: fileName,
        url: downloadUrl,
        size: fileSize,
        type: _getFileType(extension),
        uploadedAt: DateTime.now(),
      );
      
      // Firestore'a dosya bilgisini kaydet
      await _firestoreService.saveFileInfo(fileModel);
      
      // Son yüklenen dosyayı güncelle ve dosya listesine ekle
      lastUploadedFile.value = fileModel;
      userFiles.insert(0, fileModel); // En başa ekle
      
      isUploading.value = false;
      
      Get.snackbar(
        'Başarılı',
        'Dosya başarıyla yüklendi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      isUploading.value = false;
      Get.snackbar(
        'Hata',
        'Dosya yükleme sırasında bir hata oluştu: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Dosya silme işlemi
  Future<void> deleteFile(FileModel file) async {
    try {
      await _firestoreService.deleteFile(file.url);
      
      // Dosyayı listeden kaldır
      userFiles.removeWhere((f) => f.url == file.url);
      
      // Son yüklenen dosya bu ise onu da temizle
      if (lastUploadedFile.value?.url == file.url) {
        lastUploadedFile.value = null;
      }
      
      Get.snackbar(
        'Başarılı',
        'Dosya başarıyla silindi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Dosya silinirken bir hata oluştu: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _getContentType(String extension) {
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls':
        return 'application/vnd.ms-excel';
      case '.xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return 'application/octet-stream';
    }
  }

  String _getFileType(String extension) {
    extension = extension.toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.gif', '.bmp'].contains(extension)) {
      return 'image';
    } else if (['.mp4', '.mov', '.avi', '.mkv'].contains(extension)) {
      return 'video';
    } else if (['.pdf', '.doc', '.docx', '.txt', '.rtf'].contains(extension)) {
      return 'document';
    } else {
      return 'other';
    }
  }
} 