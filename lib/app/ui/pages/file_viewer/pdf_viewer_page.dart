import 'package:flutter/material.dart';
import 'package:filozon_kodfu/app/models/file_model.dart';
import 'package:get/get.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:path_provider/path_provider.dart';

class PDFViewerPage extends StatefulWidget {
  final FileModel file;

  const PDFViewerPage({Key? key, required this.file}) : super(key: key);

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _localFilePath;
  int _currentPage = 0;
  int _totalPages = 0;
  
  @override
  void initState() {
    super.initState();
    _downloadFile();
  }
  
  Future<void> _downloadFile() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${widget.file.name}';
      
      await FileDownloader.downloadFile(
        url: widget.file.url,
        name: widget.file.name,
        onDownloadCompleted: (path) {
          setState(() {
            _localFilePath = path;
            _isLoading = false;
          });
        },
        onDownloadError: (error) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: const Color(0xFF23243A),
        title: Text(
          widget.file.name,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF23243A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sayfa: ${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_localFilePath != null)
            PDFView(
              filePath: _localFilePath!,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: true,
              pageFling: true,
              pageSnap: true,
              defaultPage: _currentPage,
              fitPolicy: FitPolicy.BOTH,
              onRender: (_pages) {
                setState(() {
                  _totalPages = _pages!;
                });
              },
              onError: (error) {
                setState(() {
                  _hasError = true;
                });
              },
              onPageError: (page, error) {
                print('PDF sayfa hatası: $error');
              },
              onViewCreated: (PDFViewController pdfViewController) {
                // PDF görüntüleyici başarıyla oluşturuldu
              },
              onPageChanged: (int? page, int? total) {
                if (page != null) {
                  setState(() {
                    _currentPage = page;
                  });
                }
              },
            ),
          if (_isLoading)
            Container(
              color: Colors.grey.shade900,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF6C63FF)),
                    SizedBox(height: 16),
                    Text(
                      'PDF yükleniyor...',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
          if (_hasError)
            Container(
              color: Colors.grey.shade900,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'PDF yüklenemedi',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Dosya açılırken bir sorun oluştu',
                      style: TextStyle(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: !_isLoading && !_hasError && _localFilePath != null ? BottomAppBar(
        color: const Color(0xFF23243A),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                _downloadFile();
              },
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out, color: Colors.white),
              onPressed: () {
                // Zoom out fonksiyonu flutter_pdfview'de doğrudan mevcut değil
              },
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in, color: Colors.white),
              onPressed: () {
                // Zoom in fonksiyonu flutter_pdfview'de doğrudan mevcut değil
              },
            ),
          ],
        ),
      ) : null,
    );
  }
} 