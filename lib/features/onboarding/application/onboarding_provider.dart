import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';

@immutable
class OnboardingState {
  final bool hasSeenOnboarding;
  const OnboardingState({this.hasSeenOnboarding = false});
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  static const _key = 'has_seen_onboarding';

  @override
  OnboardingState build() {
    final prefsAsync = ref.watch(sharedPreferencesProvider);
    return prefsAsync.when(
      data: (prefs) =>
          OnboardingState(hasSeenOnboarding: prefs.getBool(_key) ?? false),
      loading: () => const OnboardingState(),
      // On error, skip onboarding to avoid blocking the user
      error: (_, _) => const OnboardingState(hasSeenOnboarding: true),
    );
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setBool(_key, true);
    } catch (e) {
      debugPrint('Failed to persist onboarding completion: $e');
    }
    state = const OnboardingState(hasSeenOnboarding: true);
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );
