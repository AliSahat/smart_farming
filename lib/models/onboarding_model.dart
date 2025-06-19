// lib/models/onboarding_model.dart
class OnBoardingItem {
  final String title;
  final String description;
  final String image;
  final String? buttonText;

  OnBoardingItem({
    required this.title,
    required this.description,
    required this.image,
    this.buttonText,
  });
}
