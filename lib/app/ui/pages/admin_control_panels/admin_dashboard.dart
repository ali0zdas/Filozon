import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:filozon_kodfu/app/controllers/profile_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboard extends StatelessWidget {
  final ProfileController _profileController = Get.find<ProfileController>();

  AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/gradBG2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button at the top left
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildWelcomeCard(),
                      const SizedBox(height: 30),
                      _buildAdminOptions(),
                      // Add some bottom padding
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 140,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.15),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hoş Geldiniz',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Obx(() {
              final user = _profileController.userProfile.value;
              final name = '${user.name ?? ''} ${user.surname ?? ''}'.trim();
              return Text(
                name.isNotEmpty ? name : 'Admin',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
            const SizedBox(height: 8),
            Text(
              'Yönetim panelini kullanarak uygulamayı yönetebilirsiniz.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOptions() {
    final List<Map<String, dynamic>> adminOptions = [
      {
        'icon': Icons.people,
        'title': 'Kullanıcılar',
        'color': Colors.blueAccent,
        'onTap': () {
          Get.toNamed('/admin/users');
        },
      },
      {
        'icon': Icons.shopping_bag,
        'title': 'Ürün Kontrolleri',
        'color': Colors.orange,
        'onTap': () {
          Get.toNamed('/admin/products');
        },
      },
      {
        'icon': Icons.receipt,
        'title': 'Siparişler',
        'color': const Color.fromARGB(255, 166, 255, 82),
        'onTap': () {
          Get.toNamed('/admin/orders');
        },

      },
      {
        'icon': Icons.analytics,
        'title': 'İstatistikler',
        'color': const Color.fromARGB(255, 0, 255, 242),
        'onTap': () {
          Get.snackbar(
            'Bilgi',
            'Bu özellik yakında eklenecek!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.white,
          );
        },
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: adminOptions.length,
      itemBuilder: (context, index) {
        return _buildAdminOptionCard(
          icon: adminOptions[index]['icon'] as IconData,
          title: adminOptions[index]['title'] as String,
          color: adminOptions[index]['color'] as Color,
          onTap: adminOptions[index]['onTap'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildAdminOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color(0xFF6C63FF),
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GlassmorphicContainer(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          borderRadius: 24,
          blur: 16,
          alignment: Alignment.center,
          border: 1.6,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
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
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 40,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
