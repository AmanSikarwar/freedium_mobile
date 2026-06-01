import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/clipboard_service.dart';
import 'package:freedium_mobile/core/utils/article_url_parser.dart';
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
      final url = extractArticleUrl(clipboardText) ?? clipboardText.trim();
      state = state.copyWith(url: url);
      onPaste(url);
    }
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
