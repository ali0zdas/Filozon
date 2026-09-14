import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:filozon_kodfu/app/models/file_model.dart';
import 'package:get/get.dart';

class PhotoViewerPage extends StatelessWidget {
  final FileModel file;

  const PhotoViewerPage({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          file.name,
          style: const TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Get.snackbar(
                'Geliştirme Aşamasında',
                'Paylaşım özelliği yakında eklenecektir',
                backgroundColor: const Color(0xFF23243A),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
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
      body: Center(
        child: Hero(
          tag: file.url,
          child: PhotoView(
            imageProvider: NetworkImage(file.url),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.0,
            initialScale: PhotoViewComputedScale.contained,
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            loadingBuilder: (context, event) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: event == null
                        ? null
                        : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                    color: const Color(0xFF6C63FF),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Resim yükleniyor...',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 64, color: Colors.white38),
                  SizedBox(height: 16),
                  Text(
                    'Resim yüklenirken bir hata oluştu',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 