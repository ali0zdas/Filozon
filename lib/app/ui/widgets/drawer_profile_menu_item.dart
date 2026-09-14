import 'package:flutter/material.dart';
import '../pages/user_panel/profile_page.dart';
import 'package:get/get.dart';
import 'package:filozon_kodfu/app/controllers/profile_controller.dart';

class DrawerProfileMenuItem extends StatelessWidget {
  final String? userEmail;
  final bool isGuestUser;
  const DrawerProfileMenuItem({Key? key, this.userEmail, this.isGuestUser = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get.put ile ProfileController'ı oluştur veya getir
    final ProfileController profileController = Get.put(ProfileController());
    
    return ListTile(
      leading: Obx(() {
        final photoUrl = profileController.userProfile.value.photoUrl;
        final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
        
        if (hasPhoto) {
          return CircleAvatar(
            backgroundImage: NetworkImage(photoUrl),
            backgroundColor: const Color.fromARGB(255, 58, 30, 117).withOpacity(0.2),
            radius: 12,
          );
        } else {
          return const Icon(Icons.person, color: Colors.white);
        }
      }),
      title: const Text('Kullanıcı Profili', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
      onTap: () {
        // Tüm kullanıcıları ProfilePage'e yönlendir, misafir kontrolü orada yapılacak
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(userEmail: userEmail, isGuestUser: isGuestUser),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      },
    );
  }
}
