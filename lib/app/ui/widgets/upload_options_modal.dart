import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class UploadOptionsModal extends StatelessWidget {
  final VoidCallback onPickGallery;
  final VoidCallback onPickFiles;

  const UploadOptionsModal({
    Key? key,
    required this.onPickGallery,
    required this.onPickFiles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 230,
        borderRadius: 24,
        blur: 18,
        alignment: Alignment.center,
        border: 1.5,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.18),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Dosya Yükleme',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF6C63FF)),
                title: const Text('Galeriden Seç', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                onTap: onPickGallery,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                hoverColor: Colors.white10,
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.folder, color: Color(0xFF6C63FF)),
                title: const Text('Dosyalarımdan Seç', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                onTap: onPickFiles,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                hoverColor: Colors.white10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
