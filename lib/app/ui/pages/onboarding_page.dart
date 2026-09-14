import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/onboarding_controller.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingController controller = Get.put(OnboardingController());

  OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Geri tuşunu devre dışı bırak
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Yarı şeffaf arkaplan
            Container(
              color: Colors.black.withOpacity(0.7),
            ),
            // Pop-up içeriği
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: PageView(
                          controller: controller.pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            controller.currentPage.value = index;
                          },
                          children: [
                            _buildThemePage(),
                            _buildDemographicsPage(),
                            _buildCategoriesPage(),
                          ],
                        ),
                      ),
                    ),
                    _buildNavigationButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tema seçimi sayfası
  Widget _buildThemePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 80,
            color: Colors.amber,
          ),
          const SizedBox(height: 20),
          const Text(
            'Hoş Geldiniz!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Hangi temayı tercih edersiniz?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildThemeOption(
                icon: Icons.dark_mode,
                title: 'Koyu Tema',
                isSelected: true,
                onTap: () => controller.updateThemePreference(true),
              ),
              _buildThemeOption(
                icon: Icons.light_mode,
                title: 'Açık Tema',
                isSelected: false,
                onTap: () {
                  controller.showLightThemeWarning();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tema seçeneği widgeti
  Widget _buildThemeOption({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Obx(() {
      final isDarkSelected = controller.isDarkTheme.value;
      final isThisSelected = (title == 'Koyu Tema' && isDarkSelected) ||
          (title == 'Açık Tema' && !isDarkSelected);

      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: isThisSelected ? const Color.fromARGB(255, 6, 57, 98) : Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isThisSelected ? const Color.fromARGB(255, 0, 16, 93) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: isThisSelected ? Colors.white : Colors.white70,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: isThisSelected ? Colors.white : Colors.white70,
                  fontWeight: isThisSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Demografik bilgiler sayfası
  Widget _buildDemographicsPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_alt_outlined,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'Biraz Sizi Tanıyalım',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Size daha iyi hizmet verebilmek için birkaç bilgi alabilir miyiz?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            _buildGenderSelection(),
            const SizedBox(height: 30),
            _buildAgeSelection(),
          ],
        ),
      ),
    );
  }

  // Cinsiyet seçimi bölümü
  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cinsiyetiniz',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: controller.genders.map((gender) {
            return Obx(() => GestureDetector(
                  onTap: () => controller.updateGender(gender['name']),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: controller.selectedGender.value == gender['name']
                          ? Colors.deepOrange
                          : Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: controller.selectedGender.value == gender['name']
                            ? Colors.white
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          gender['icon'],
                          size: 36,
                          color: controller.selectedGender.value == gender['name']
                              ? Colors.white
                              : Colors.white70,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          gender['name'],
                          style: TextStyle(
                            color: controller.selectedGender.value == gender['name']
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          }).toList(),
        ),
      ],
    );
  }

  // Yaş aralığı seçimi bölümü
  Widget _buildAgeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Yaş Aralığınız',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: controller.ageRanges.map((ageRange) {
            return Obx(() => GestureDetector(
                  onTap: () => controller.updateAgeRange(ageRange),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.selectedAgeRange.value == ageRange
                          ? Colors.deepOrange
                          : Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: controller.selectedAgeRange.value == ageRange
                            ? Colors.white
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      ageRange,
                      style: TextStyle(
                        color: controller.selectedAgeRange.value == ageRange
                            ? Colors.white
                            : Colors.white70,
                      ),
                    ),
                  ),
                ));
          }).toList(),
        ),
      ],
    );
  }

  // Favori kategoriler sayfası
  Widget _buildCategoriesPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.category_outlined,
              size: 80,
              color: Colors.amber,
            ),
            const SizedBox(height: 20),
            const Text(
              'Favori Kategorileriniz',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'İlgi alanlarınıza göre size özel ürünler sunalım',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            _buildCategoryGrid(),
            const SizedBox(height: 20),
            Obx(() => Text(
                  controller.selectedCategories.isEmpty
                      ? 'En az bir kategori seçiniz'
                      : '${controller.selectedCategories.length} kategori seçtiniz',
                  style: TextStyle(
                    fontSize: 14,
                    color: controller.selectedCategories.isEmpty
                        ? Colors.redAccent
                        : Colors.greenAccent,
                    fontStyle: FontStyle.italic,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // Kategori grid görünümü
  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.5,
      ),
      itemCount: controller.categories.length,
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        return Obx(() => GestureDetector(
              onTap: () => controller.toggleCategory(category['name']),
              child: Container(
                decoration: BoxDecoration(
                  color: controller.selectedCategories.contains(category['name'])
                      ? Colors.deepOrange
                      : Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: controller.selectedCategories.contains(category['name'])
                        ? Colors.white
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'],
                      size: 32,
                      color: controller.selectedCategories.contains(category['name'])
                          ? Colors.white
                          : Colors.white70,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'],
                      style: TextStyle(
                        color: controller.selectedCategories.contains(category['name'])
                            ? Colors.white
                            : Colors.white70,
                        fontWeight:
                            controller.selectedCategories.contains(category['name'])
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }

  // Navigasyon butonları
  Widget _buildNavigationButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Obx(() {
        final isFirstPage = controller.currentPage.value == 0;
        final isLastPage = controller.currentPage.value == controller.totalPages - 1;
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Geri butonu
            if (!isFirstPage)
              ElevatedButton.icon(
                onPressed: controller.previousPage,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Önceki'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                ),
              )
            else
              const SizedBox(width: 100),
            
            // İlerleme göstergesi
            Row(
              children: List.generate(controller.totalPages, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.currentPage.value == index
                        ? Colors.deepOrange
                        : Colors.grey,
                  ),
                );
              }),
            ),
            
            // İleri/Bitir butonu
            ElevatedButton.icon(
              onPressed: () {
                if (isLastPage) {
                  // Son sayfada isek onboarding'i tamamla
                  controller.completeOnboarding().then((_) {
                    // Onboarding'den çık ve ana sayfaya yönlendir
                    Navigator.of(context).pop();
                  });
                } else {
                  // Bir sonraki sayfaya geç
                  controller.nextPage();
                }
              },
              icon: Icon(isLastPage ? Icons.check : Icons.arrow_forward),
              label: Text(isLastPage ? 'Alışverişe Başla' : 'Sonraki'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      }),
    );
  }
} 