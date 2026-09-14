import 'package:filozon_kodfu/app/models/file_model.dart';
import 'package:filozon_kodfu/app/ui/pages/file_viewer/photo_viewer_page.dart';
import 'package:filozon_kodfu/app/ui/pages/file_viewer/video_player_page.dart';
import 'package:filozon_kodfu/app/ui/pages/file_viewer/pdf_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FileViewerService {
  static void openFile(FileModel file) {
    // Dosya türüne göre uygun sayfaya yönlendirme yap
    switch (file.type) {
      case 'image':
        Get.to(() => PhotoViewerPage(file: file), transition: Transition.fadeIn);
        break;
      case 'video':
        Get.to(() => VideoPlayerPage(file: file), transition: Transition.fadeIn);
        break;
      case 'document':
        // Dosya uzantısına göre PDF kontrolü yap
        if (file.name.toLowerCase().endsWith('.pdf')) {
          Get.to(() => PDFViewerPage(file: file), transition: Transition.fadeIn);
        } else {
          // PDF olmayan belgeler için uyarı göster
          _showUnsupportedFormatDialog(file);
        }
        break;
      default:
        _showUnsupportedFormatDialog(file);
        break;
    }
  }
  
  static void _showUnsupportedFormatDialog(FileModel file) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF23243A),
        title: const Text('Desteklenmeyen Format', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dosya: ${file.name}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bu dosya formatı uygulama içinde önizleme için desteklenmiyor. Dosyayı indirmek için lütfen indirme seçeneğini kullanın.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Tamam', style: TextStyle(color: Color(0xFF6C63FF))),
            onPressed: () {
              Get.back();
            },
          ),
          TextButton(
            child: const Text('İndir', style: TextStyle(color: Color(0xFF6C63FF))),
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Geliştirme Aşamasında',
                'İndirme özelliği yakında eklenecektir',
                backgroundColor: const Color(0xFF23243A),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }
} 