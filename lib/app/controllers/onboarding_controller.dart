import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/onboarding_model.dart';
import '../services/onboarding_service.dart';
import '../services/auth_service.dart';

class OnboardingController extends GetxController {
  final OnboardingService _onboardingService = OnboardingService();
  final AuthService _authService = AuthService();

  final currentPage = 0.obs;
  final totalPages = 3;
  final isDarkTheme = true.obs;
  final selectedGender = ''.obs;
  final selectedAgeRange = ''.obs;
  final selectedCategories = <String>[].obs;
  final hasCompletedOnboarding = false.obs;
  final isLoading = false.obs;

  final PageController pageController = PageController();

  // Yaş aralıkları
  final List<String> ageRanges = [
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55+'
  ];

  // Cinsiyet seçenekleri
  final List<Map<String, dynamic>> genders = [
    {'name': 'Erkek', 'icon': Icons.male},
    {'name': 'Kadın', 'icon': Icons.female},
    {'name': 'Belirtmek İstemiyorum', 'icon': Icons.person},
  ];

  // Kategori seçenekleri
  final List<Map<String, dynamic>> categories = [
    {'name': 'Elektronik', 'icon': Icons.computer},
    {'name': 'Giyim', 'icon': Icons.checkroom},
    {'name': 'Spor', 'icon': Icons.sports_soccer},
    {'name': 'Kozmetik', 'icon': Icons.face},
    {'name': 'Ev & Yaşam', 'icon': Icons.home},
    {'name': 'Kitap', 'icon': Icons.book},
    {'name': 'Oyuncak', 'icon': Icons.toys},
    {'name': 'Hobi', 'icon': Icons.palette},
  ];

  @override
  void onInit() {
    super.onInit();
    _checkOnboardingStatus();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // Kullanıcının onboarding durumunu kontrol etme
  Future<void> _checkOnboardingStatus() async {
    isLoading.value = true;
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final completed = await _onboardingService.hasCompletedOnboarding(user.uid);
        hasCompletedOnboarding.value = completed;

        if (!completed) {
          // Eğer onboarding tamamlanmamışsa, mevcut verileri yükle
          final onboardingData = await _onboardingService.getOnboardingData(user.uid);
          if (onboardingData != null) {
            _loadOnboardingData(onboardingData);
          }
        }
      }
    } catch (e) {
      print('Onboarding durumu kontrol edilirken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Onboarding verilerini yükleme
  void _loadOnboardingData(OnboardingModel data) {
    isDarkTheme.value = data.isDarkTheme;
    selectedGender.value = data.gender;
    selectedAgeRange.value = data.ageRange;
    selectedCategories.value = List<String>.from(data.favoriteCategories);
  }

  // Sonraki sayfaya geçme
  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value++;
      _saveCurrentPageData();
    }
  }

  // Önceki sayfaya dönme
  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value--;
    }
  }

  // Tema tercihini güncelleme
  void updateThemePreference(bool isDark) {
    isDarkTheme.value = isDark;
    _saveCurrentPageData();
  }

  // Cinsiyet seçimini güncelleme
  void updateGender(String gender) {
    selectedGender.value = gender;
    _saveCurrentPageData();
  }

  // Yaş aralığı seçimini güncelleme
  void updateAgeRange(String ageRange) {
    selectedAgeRange.value = ageRange;
    _saveCurrentPageData();
  }

  // Kategori seçimini güncelleme
  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
    _saveCurrentPageData();
  }

  // Mevcut sayfadaki verileri kaydetme
  Future<void> _saveCurrentPageData() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final userId = user.uid;

    try {
      switch (currentPage.value) {
        case 0:
          await _onboardingService.updateThemePreference(userId, isDarkTheme.value);
          break;
        case 1:
          await _onboardingService.updateDemographics(
            userId,
            selectedGender.value,
            selectedAgeRange.value,
          );
          break;
        case 2:
          await _onboardingService.updateFavoriteCategories(
            userId,
            selectedCategories.toList(),
          );
          break;
      }
    } catch (e) {
      print('Onboarding verisi kaydedilirken hata: $e');
    }
  }

  // Onboarding'i tamamlama
  Future<void> completeOnboarding() async {
    isLoading.value = true;
    try {
      await _saveCurrentPageData();
      final user = _authService.currentUser;
      if (user != null) {
        await _onboardingService.markOnboardingAsCompleted(user.uid);
        hasCompletedOnboarding.value = true;
      }
    } catch (e) {
      print('Onboarding tamamlanırken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Açık tema seçildiğinde uyarı gösterme
  void showLightThemeWarning() {
    Get.snackbar(
      'Bilgi',
      'Açık tema şu anda geliştirme aşamasındadır.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.amber,
      colorText: Colors.black,
      duration: const Duration(seconds: 3),
    );
  }
} 