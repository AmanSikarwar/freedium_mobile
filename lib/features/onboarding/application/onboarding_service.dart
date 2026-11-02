import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService(this._prefs) {
  static const String hasSeenOnboardingKey = 'has_seen_onboarding';
  final SharedPreferencesWithCache _prefs;

  bool hasSeenOnboarding() {
    return _prefs.getBool(hasSeenOnboardingKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool(hasSeenOnboardingKey, true);
  }
}
