import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/clipboard_service.dart';
import 'package:freedium_mobile/features/home/domain/home_state.dart';

export 'package:freedium_mobile/features/home/domain/home_state.dart';

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  void setUrl(String url) {
    state = state.copyWith(url: url);
  }

  Future<void> pasteFromClipboard(void Function(String) onPaste) async {
    final clipboardText = await ref.read(clipboardServiceProvider).paste();
    if (clipboardText != null) {
      state = state.copyWith(url: clipboardText);
      onPaste(clipboardText);
    }
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
