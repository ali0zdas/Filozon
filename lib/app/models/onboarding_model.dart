class OnboardingModel {
  final String userId;
  final bool isDarkTheme;
  final String gender;
  final String ageRange;
  final List<String> favoriteCategories;
  final bool hasCompletedOnboarding;

  OnboardingModel({
    required this.userId,
    this.isDarkTheme = true,
    this.gender = '',
    this.ageRange = '',
    this.favoriteCategories = const [],
    this.hasCompletedOnboarding = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'isDarkTheme': isDarkTheme,
      'gender': gender,
      'ageRange': ageRange,
      'favoriteCategories': favoriteCategories,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }

  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return OnboardingModel(
      userId: json['userId'] ?? '',
      isDarkTheme: json['isDarkTheme'] ?? true,
      gender: json['gender'] ?? '',
      ageRange: json['ageRange'] ?? '',
      favoriteCategories: List<String>.from(json['favoriteCategories'] ?? []),
      hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
    );
  }

  OnboardingModel copyWith({
    String? userId,
    bool? isDarkTheme,
    String? gender,
    String? ageRange,
    List<String>? favoriteCategories,
    bool? hasCompletedOnboarding,
  }) {
    return OnboardingModel(
      userId: userId ?? this.userId,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      gender: gender ?? this.gender,
      ageRange: ageRange ?? this.ageRange,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
} 