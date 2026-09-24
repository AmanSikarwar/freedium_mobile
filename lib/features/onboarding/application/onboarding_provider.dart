import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/onboarding/application/onboarding_service.dart';

part 'onboarding_provider.freezed.dart';
part 'onboarding_provider.g.dart';

@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(false) bool hasSeenOnboarding,
    @Default(false) bool isLoading,
  }) = _OnboardingState;
}

@Riverpod(keepAlive: true)
class Onboarding extends _$Onboarding {
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

@Riverpod(keepAlive: true)
OnboardingService? onboardingService(Ref ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.when(
    data: OnboardingService.new,
    loading: () => null,
    error: (_, _) => null,
  );
}
