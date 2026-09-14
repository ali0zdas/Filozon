import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/onboarding_model.dart';

class OnboardingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı onboarding verilerini kaydetme
  Future<void> saveOnboardingData(OnboardingModel onboardingModel) async {
    try {
      await _firestore
          .collection('users')
          .doc(onboardingModel.userId)
          .collection('onboardingData')
          .doc('userPreferences')
          .set(onboardingModel.toJson());
    } catch (e) {
      print('Onboarding verisi kaydedilirken hata oluştu: $e');
      throw e;
    }
  }

  // Kullanıcı onboarding verilerini getirme
  Future<OnboardingModel?> getOnboardingData(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('onboardingData')
          .doc('userPreferences')
          .get();
          
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return OnboardingModel.fromJson({
          'userId': userId,
          ...docSnapshot.data()!
        });
      }
      return null;
    } catch (e) {
      print('Onboarding verisi alınırken hata oluştu: $e');
      throw e;
    }
  }

  // Kullanıcının onboarding'i tamamlayıp tamamlamadığını kontrol etme
  Future<bool> hasCompletedOnboarding(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('onboardingData')
          .doc('userPreferences')
          .get();
          
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        return data['hasCompletedOnboarding'] ?? false;
      }
      return false;
    } catch (e) {
      print('Onboarding durumu kontrol edilirken hata oluştu: $e');
      return false;
    }
  }

  // Onboarding'i tamamlandı olarak işaretleme
  Future<void> markOnboardingAsCompleted(String userId) async {
    try {
      final onboardingData = await getOnboardingData(userId);
      if (onboardingData != null) {
        final updatedData = onboardingData.copyWith(hasCompletedOnboarding: true);
        await saveOnboardingData(updatedData);
      } else {
        final newOnboardingData = OnboardingModel(
          userId: userId,
          hasCompletedOnboarding: true,
        );
        await saveOnboardingData(newOnboardingData);
      }
    } catch (e) {
      print('Onboarding tamamlandı olarak işaretlenirken hata oluştu: $e');
      throw e;
    }
  }

  // Tema tercihini güncelleme
  Future<void> updateThemePreference(String userId, bool isDarkTheme) async {
    try {
      final onboardingData = await getOnboardingData(userId);
      if (onboardingData != null) {
        final updatedData = onboardingData.copyWith(isDarkTheme: isDarkTheme);
        await saveOnboardingData(updatedData);
      } else {
        final newOnboardingData = OnboardingModel(
          userId: userId,
          isDarkTheme: isDarkTheme,
        );
        await saveOnboardingData(newOnboardingData);
      }
    } catch (e) {
      print('Tema tercihi güncellenirken hata oluştu: $e');
      throw e;
    }
  }

  // Cinsiyet ve yaş aralığı tercihini güncelleme
  Future<void> updateDemographics(String userId, String gender, String ageRange) async {
    try {
      final onboardingData = await getOnboardingData(userId);
      if (onboardingData != null) {
        final updatedData = onboardingData.copyWith(gender: gender, ageRange: ageRange);
        await saveOnboardingData(updatedData);
      } else {
        final newOnboardingData = OnboardingModel(
          userId: userId,
          gender: gender,
          ageRange: ageRange,
        );
        await saveOnboardingData(newOnboardingData);
      }
    } catch (e) {
      print('Demografik bilgiler güncellenirken hata oluştu: $e');
      throw e;
    }
  }

  // Favori kategorileri güncelleme
  Future<void> updateFavoriteCategories(String userId, List<String> categories) async {
    try {
      final onboardingData = await getOnboardingData(userId);
      if (onboardingData != null) {
        final updatedData = onboardingData.copyWith(favoriteCategories: categories);
        await saveOnboardingData(updatedData);
      } else {
        final newOnboardingData = OnboardingModel(
          userId: userId,
          favoriteCategories: categories,
        );
        await saveOnboardingData(newOnboardingData);
      }
    } catch (e) {
      print('Favori kategoriler güncellenirken hata oluştu: $e');
      throw e;
    }
  }
} 