import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:filozon_kodfu/app/controllers/profile_controller.dart';
import 'package:filozon_kodfu/app/routes/app_pages.dart';
import 'package:filozon_kodfu/app/ui/pages/admin_control_panels/admin_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:filozon_kodfu/app/controllers/isGuest_controller.dart';
import 'package:filozon_kodfu/app/services/auth_service.dart';
import 'package:filozon_kodfu/app/ui/widgets/upload_options_modal.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final String? userEmail;
  final bool isGuestUser;
  const ProfilePage({Key? key, this.userEmail, this.isGuestUser = false}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController profileController;
  late final IsGuestController guestController;
  late bool isMisafir;

  @override
  void initState() {
    super.initState();
    profileController = Get.put(ProfileController());
    guestController = Get.find<IsGuestController>();
    
    isMisafir = widget.isGuestUser ||
                guestController.isGuestUser.value ||
                widget.userEmail == "guest" ||
                widget.userEmail == "Misafir" ||
                widget.userEmail == null;
    
    // Profil bilgilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Misafir değilse profil bilgilerini yükle
      if (!isMisafir) {
        profileController.loadUserProfile();
        if (profileController.userProfile.value.email == null) {
          profileController.setEmail(widget.userEmail ?? guestController.userDisplayName.value);
        }
      }
      
      // Misafir kullanıcıysa uyarı göster
      if (isMisafir) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF23243A),
            title: const Text('Giriş Gerekli', style: TextStyle(color: Colors.white)),
            content: const Text('Profil sayfasına erişmek için giriş yapmalısınız.', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                child: const Text('Giriş Yap', style: TextStyle(color: Color(0xFF6C63FF))),
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.toNamed('/login');
                },
              ),
              TextButton(
                child: const Text('Kayıt Ol', style: TextStyle(color: Color(0xFF6C63FF))),
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.toNamed('/register');
                },
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23243A),
        title: const Text('Profil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isMisafir
        ? const Center(
            child: Text(
              'Misafir kullanıcılar profil sayfasına erişemez.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(profileController, context),
                const SizedBox(height: 24),
                _buildProfileCards(context),
                const SizedBox(height: 24),
                _buildLogoutButton(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }

  Widget _buildProfileHeader(ProfileController profileController, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 80, bottom: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.2),
            const Color(0xFF6C63FF).withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Obx(() {
                return Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    // Avatar with glass effect
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF4A42D6)],
                          radius: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  _showAvatarOptions(context, profileController);
                                },
                                child: profileController.isLoading.value
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : _getProfileImage(profileController) != null
                                        ? CircleAvatar(
                                            radius: 60,
                                            backgroundColor: const Color(0xFF6C63FF).withOpacity(0.3),
                                            backgroundImage: _getProfileImage(profileController),
                                            child: _shouldShowDefaultIcon(profileController)
                                                ? const Icon(Icons.person, size: 60, color: Colors.white)
                                                : null,
                                          )
                                        : Center(
                                            child: _shouldShowDefaultIcon(profileController)
                                                ? Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color: Colors.white.withOpacity(0.9),
                                                  )
                                                : null,
                                          ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Camera button
                    Positioned(
                      right: 5,
                      bottom: 5,
                      child: GestureDetector(
                        onTap: () {
                          _showAvatarOptions(context, profileController);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),
              Obx(() {
                final name = profileController.userProfile.value.name ?? "";
                final surname = profileController.userProfile.value.surname ?? "";
                final hasName = name.isNotEmpty || surname.isNotEmpty;
                
                return Column(
                  children: [
                    if (hasName)
                      Text(
                        "$name $surname".trim(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      profileController.userProfile.value.email ?? '',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: hasName ? 14 : 16,
                        fontWeight: hasName ? FontWeight.normal : FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvatarOptions(BuildContext context, ProfileController profileController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => UploadOptionsModal(
        onPickGallery: () {
          Navigator.pop(context);
          profileController.pickAndUploadAvatar();
        },
        onPickFiles: () {
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
    );
  }

  // Admin paneli butonunu oluştur
  Widget _buildAdminPanelButton() {
    final profileController = Get.find<ProfileController>();
    
    // Kullanıcı admin değilse boş container döndür
    if (profileController.userProfile.value.isAdmin != true) {
      return const SizedBox.shrink();
    }
    
    // Admin ise admin paneli butonunu göster
    return Column(
      children: [
        _buildProfileCard(
          icon: Icons.admin_panel_settings_outlined,
          title: 'Yönetici Paneli',
          subtitle: 'Yönetim paneline erişin',
          onTap: () {
            Get.to(() => AdminDashboard());
          },
        ),
        const SizedBox(height: 12),
        const Divider(color: Colors.white12, height: 1, thickness: 1),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildProfileCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hesap Bilgileri',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 16),
          // Admin paneli butonunu ekle
          _buildAdminPanelButton(),
          _buildProfileCard(
            icon: Icons.shopping_bag_outlined,
            title: 'Siparişlerim',
            subtitle: 'Sipariş geçmişinizi görüntüleyin',
            onTap: () {
              Get.toNamed(Routes.ORDERS);
            },
          ),
          _buildProfileCard(
            icon: Icons.cloud_outlined,
            title: 'Filozon Cloud',
            subtitle: 'Dosyalarınızı yönetin ve yükleyin',
            onTap: () {
              Get.toNamed('/filozon-cloud');
            },
          ),
          _buildProfileCard(
            icon: Icons.location_on_outlined,
            title: 'Adreslerim',
            subtitle: 'Kayıtlı adreslerinizi yönetin',
            onTap: () {
              Get.toNamed('/addresses');
            },
          ),
          _buildProfileCard(
            icon: Icons.credit_card_outlined,
            title: 'Ödeme Yöntemlerim',
            subtitle: 'Kayıtlı ödeme yöntemlerinizi yönetin',
            onTap: () {
              Get.snackbar(
                'Geliştirme Aşamasında',
                'Bu özellik yakında eklenecektir',
                backgroundColor: const Color(0xFF23243A),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          _buildProfileCard(
            icon: Icons.settings_outlined,
            title: 'Ayarlar',
            subtitle: 'Hesap ayarlarınızı yönetin',
            onTap: () {
              Get.snackbar(
                'Geliştirme Aşamasında',
                'Bu özellik yakında eklenecektir',
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

  Widget _buildProfileCard({
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

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Get.defaultDialog(
              backgroundColor: const Color(0xFF23243A),
              title: 'Çıkış Yap',
              titleStyle: const TextStyle(color: Colors.white),
              middleText: 'Çıkış yapmak istediğinize emin misiniz?',
              middleTextStyle: const TextStyle(color: Colors.white70),
              textCancel: 'İptal',
              textConfirm: 'Çıkış',
              confirmTextColor: Colors.white,
              cancelTextColor: Colors.white,
              buttonColor: Colors.redAccent,
              onConfirm: () async {
                // AuthService'i kullanarak çıkış işlemini gerçekleştir
                final authService = AuthService();
                await authService.signOut();
                Get.offAllNamed('/login');
              },
            );
          },
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text('Çıkış Yap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage(ProfileController controller) {
    final photoUrl = controller.userProfile.value.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http')) {
        return NetworkImage(photoUrl);
      } else if (!kIsWeb) {
        return FileImage(File(photoUrl));
      }
    }
    return null;
  }

  bool _shouldShowDefaultIcon(ProfileController profileController) {
    final photoUrl = profileController.userProfile.value.photoUrl;
    return photoUrl == null || photoUrl.isEmpty;
  }
}