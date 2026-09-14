import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'package:filozon_kodfu/app/ui/widgets/drawer_profile_menu_item.dart';
import 'package:filozon_kodfu/app/controllers/isGuest_controller.dart';
import 'package:filozon_kodfu/app/controllers/profile_controller.dart';
import 'package:filozon_kodfu/app/ui/pages/user_panel/profile_page.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback? onFavoritesTap;
  final VoidCallback? onCartTap;
  final String userEmail;
  const CustomDrawer({Key? key, this.onFavoritesTap, this.onCartTap, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Controller'ları Get.find() ile bul veya bağla
    final IsGuestController guestController = Get.find<IsGuestController>();
    // Get.put ile ProfileController'ı oluştur/getir (yoksa oluşturur, varsa mevcut olanı getirir)
    final ProfileController profileController = Get.put(ProfileController());
    
    // Build işlemi tamamlandıktan sonra controller'ı güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userEmail == "guest") {
        guestController.setGuestLogin();
      } else if (userEmail.isNotEmpty) {
        guestController.checkGuestStatus(userEmail);
      } else {
        guestController.checkGuestStatus();
      }
    });
    
    return Opacity(
      opacity: 0.65,
      child: Drawer(
        child: Stack(
          children: <Widget>[
            // Gaussian blur arka plan
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 1, 0, 9).withOpacity(1),
                ),
              ),
            ),
            ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start, // YUKARIDA BAŞLASIN
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 20.0),
                        child: Text(
                          'Menü',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                userEmail: guestController.userDisplayName.value,
                                isGuestUser: guestController.isGuestUser.value,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 78, 69, 249),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: Obx(() {
                                final photoUrl = profileController.userProfile.value.photoUrl;
                                final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
                                
                                return CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
                                  child: hasPhoto ? null : const Icon(Icons.person, color: Colors.white, size: 24),
                                );
                              }),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Obx(() {
                                final name = profileController.userProfile.value.name ?? "";
                                final surname = profileController.userProfile.value.surname ?? "";
                                final displayName = (name.isNotEmpty || surname.isNotEmpty) 
                                    ? "$name $surname".trim() 
                                    : guestController.userDisplayName.value;
                                
                                return Text(
                                  displayName,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Profil menü öğesi
                Obx(() => DrawerProfileMenuItem(
                  userEmail: guestController.userDisplayName.value, 
                  isGuestUser: guestController.isGuestUser.value
                )),
                _DrawerMenuItem(
                  icon: Icons.shopping_cart_outlined,
                  text: 'Sepet',
                  onTap: onCartTap,
                ),
                _DrawerMenuItem(
                  icon: Icons.favorite_border,
                  text: 'Favoriler',
                  onTap: onFavoritesTap,
                ),
                const SizedBox(height: 8),
              ],
            ),
            // Çıkış butonunu en alta sabitle
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                child: _DrawerMenuItem(
                  icon: Icons.logout,
                  text: 'Çıkış Yap',
                  onTap: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF23243A),
                        title: const Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
                        content: const Text('Çıkış yapmak istediğinize emin misiniz?', style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            child: const Text('İptal', style: TextStyle(color: Colors.white)),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: const Text('Çıkış', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      ),
                    );
                    if (result == true) {
                      // Firebase'den çıkış yap (kullanıcı girişli ise)
                      if (FirebaseAuth.instance.currentUser != null) {
                        await FirebaseAuth.instance.signOut();
                      }
                      
                      // Controller'ı güncelle
                      guestController.resetUser();
                      
                      // GetX navigation kullanarak login sayfasına git ve tüm sayfaları temizle
                      Get.offAllNamed('/login');
                      
                      // Çıkış mesajını göster
                      Get.showSnackbar(
                        const GetSnackBar(
                          message: 'Başarıyla çıkış yaptınız',
                          backgroundColor: Colors.redAccent,
                          icon: Icon(Icons.exit_to_app, color: Colors.white),
                          isDismissible: true,
                          duration: Duration(seconds: 2),
                          snackPosition: SnackPosition.BOTTOM,
                        ),
                      );
                    }
                  },
                  textColor: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final Color? textColor;

  const _DrawerMenuItem({Key? key, required this.icon, required this.text, this.onTap, this.textColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.white),
            title: Text(
                text,
                style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontWeight: FontWeight.bold,
                ),
            ),
      onTap: onTap,
    );
  }
}
