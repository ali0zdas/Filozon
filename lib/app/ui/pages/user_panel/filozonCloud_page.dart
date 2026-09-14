import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:filozon_kodfu/app/controllers/upload_controller.dart';
import 'package:filozon_kodfu/app/models/file_model.dart';
import 'package:filozon_kodfu/app/services/file_viewer_service.dart';
import 'package:filozon_kodfu/app/ui/widgets/upload_options_modal.dart';

class FilozonCloudPage extends StatefulWidget {
  const FilozonCloudPage({Key? key}) : super(key: key);

  @override
  State<FilozonCloudPage> createState() => _FilozonCloudPageState();
}

class _FilozonCloudPageState extends State<FilozonCloudPage> with SingleTickerProviderStateMixin {
  final UploadController uploadController = Get.put(UploadController());
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23243A),
        title: const Text('Filozon Cloud', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6C63FF),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'DOSYA İŞLEMLERİ'),
            Tab(text: 'DOSYALARIM'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUploadTab(),
          _buildFilesTab(),
        ],
      ),
      bottomNavigationBar: Obx(() {
        if (uploadController.isUploading.value) {
          return Container(
            color: const Color(0xFF23243A),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dosya Yükleniyor...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(uploadController.uploadProgress.value * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: uploadController.uploadProgress.value,
                  backgroundColor: Colors.grey.shade800,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildUploadTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bulut Depolama',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 16),
            _buildCloudCard(
              icon: Icons.cloud_upload_outlined,
              title: 'Dosya Yükleme',
              subtitle: 'Cihazınızdan buluta dosya yükleyin',
              onTap: () {
                _showUploadOptions(context);
              },
            ),
            const SizedBox(height: 20),
            Obx(() {
              if (uploadController.lastUploadedFile.value != null) {
                final file = uploadController.lastUploadedFile.value!;
                return Card(
                  color: const Color(0xFF23243A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Son Yüklenen Dosya',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              _getIconForFileType(file.type),
                              color: const Color(0xFF6C63FF),
                              size: 36,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatFileSize(file.size),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            // Yükleme sırasında bottom padding ekleyelim
            Obx(() => uploadController.isUploading.value 
              ? const SizedBox(height: 100) 
              : const SizedBox.shrink()
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilesTab() {
    return Obx(() {
      if (uploadController.userFiles.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 80, color: Colors.white24),
              SizedBox(height: 16),
              Text(
                'Dosya Bulunamadı',
                style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Dosya yüklemek için "DOSYA İŞLEMLERİ" sekmesine geçin',
                style: TextStyle(color: Colors.white38, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: uploadController.userFiles.length,
        itemBuilder: (context, index) {
          final file = uploadController.userFiles[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: const Color(0xFF23243A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForFileType(file.type),
                  color: const Color(0xFF6C63FF),
                ),
              ),
              title: Text(
                file.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    _formatFileSize(file.size),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Yüklenme: ${_formatDate(file.uploadedAt)}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white70),
                onPressed: () {
                  _showFileOptions(context, file);
                },
              ),
              onTap: () {
                _previewFile(file);
              },
            ),
          );
        },
      );
    });
  }
  
  void _showFileOptions(BuildContext context, FileModel file) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF23243A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              file.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.open_in_new, color: Color(0xFF6C63FF)),
              title: const Text('Aç', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _previewFile(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Color(0xFF6C63FF)),
              title: const Text('Paylaş', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Geliştirme Aşamasında',
                  'Bu özellik yakında eklenecektir',
                  backgroundColor: const Color(0xFF23243A),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text('Sil', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteFile(file);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _confirmDeleteFile(FileModel file) {
    Get.defaultDialog(
      backgroundColor: const Color(0xFF23243A),
      title: 'Dosya Silinecek',
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      middleText: 'Bu dosyayı silmek istediğinize emin misiniz?',
      middleTextStyle: const TextStyle(color: Colors.white70),
      contentPadding: const EdgeInsets.all(20),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          Get.back();
          uploadController.deleteFile(file);
        },
        child: const Text('SİL'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('İPTAL', style: TextStyle(color: Colors.white70)),
      ),
    );
  }
  
  void _previewFile(FileModel file) {
    FileViewerService.openFile(file);
  }
  
  Widget _buildCloudCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF23243A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF)),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white60),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => UploadOptionsModal(
        onPickGallery: () {
          Navigator.pop(context);
          uploadController.pickAndUploadFile(fromGallery: true);
        },
        onPickFiles: () {
          Navigator.pop(context);
          uploadController.pickAndUploadFile(fromGallery: false);
        },
      ),
    );
  }
  
  // Dosya tipine göre ikon belirleme
  IconData _getIconForFileType(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_file;
      case 'document':
        return Icons.insert_drive_file;
      default:
        return Icons.insert_drive_file;
    }
  }
  
  // Dosya boyutunu formatla
  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      final kb = sizeInBytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      final mb = sizeInBytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    } else {
      final gb = sizeInBytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(1)} GB';
    }
  }
  
  // Tarihi formatla
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
} 