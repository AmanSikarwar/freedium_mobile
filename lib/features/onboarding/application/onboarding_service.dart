import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService(this._prefs) {
  static const String hasSeenOnboardingKey = 'has_seen_onboarding';
  final SharedPreferences _prefs;

  bool hasSeenOnboarding() {
    return _prefs.getBool(hasSeenOnboardingKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    final success = await _prefs.setBool(hasSeenOnboardingKey, true);
    if (!success) {
      throw Exception('setBool returned false for key "$hasSeenOnboardingKey"');
    }
  }
}
