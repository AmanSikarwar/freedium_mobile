import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/onboarding/application/onboarding_service.dart';

@immutable
class const OnboardingState({
  this.hasSeenOnboarding = false,
  this.isLoading = false,
}) {
  final bool hasSeenOnboarding;
  final bool isLoading;
}

class OnboardingNotifier() extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    final prefsAsync = ref.watch(sharedPreferencesProvider);
    return prefsAsync.when(
      data: (prefs) => OnboardingState(
        hasSeenOnboarding: OnboardingService(prefs).hasSeenOnboarding(),
      ),
      loading: () => const OnboardingState(isLoading: true),
      // On error, skip onboarding to avoid blocking the user
      error: (_, _) => const OnboardingState(hasSeenOnboarding: true),
    );
  }

  Future<bool> completeOnboarding() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await OnboardingService(prefs).completeOnboarding();
      state = const OnboardingState(hasSeenOnboarding: true);
      return true;
    } catch (e) {
      debugPrint('Failed to persist onboarding completion: $e');
      return false;
    }
  }
}

final onboardingServiceProvider = Provider<OnboardingService?>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.when(
    data: OnboardingService.new,
    loading: () => null,
    error: (_, _) => null,
  );
});

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );
