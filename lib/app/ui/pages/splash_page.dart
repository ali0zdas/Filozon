import 'package:flutter/material.dart';
import 'dart:async';
import 'package:filozon_kodfu/app/ui/pages/login_register/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  final String _text = 'Filozon';

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_text.length, (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    ));
    _animations = List.generate(_text.length, (i) => Tween<Offset>(
      begin: const Offset(12, 0), // sağdan başlasın
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controllers[i],
      curve: Curves.easeOutBack,
    )));
    _startLetterAnimations();
  }

  Future<void> _startLetterAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      _controllers[i].forward();
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      await _navigateToNextScreen();
    }
  }

  Future<void> _navigateToNextScreen() async {
    // Hot restart veya cold restart sonrası her zaman login sayfasına yönlendir
    Navigator.of(context).pushReplacement(_createRoute());
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_text.length, (i) {
            return SlideTransition(
              position: _animations[i],
              child: Text(
                _text[i],
                style: const TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 58,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
