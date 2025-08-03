import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/clipboard_service.dart';
import 'package:freedium_mobile/features/webview/presentation/webview_screen.dart';

class HomeState {
  final TextEditingController urlController;
  final GlobalKey<FormState> formKey;

  HomeState({required this.urlController, required this.formKey});
}

class HomeNotifier extends StateNotifier<HomeState> {
  final Ref _ref;

  HomeNotifier(this._ref)
    : super(
        HomeState(
          urlController: TextEditingController(),
          formKey: GlobalKey<FormState>(),
        ),
      );

  Future<void> pasteFromClipboard() async {
    final clipboardText = await _ref.read(clipboardServiceProvider).paste();
    if (clipboardText != null) {
      state.urlController.text = clipboardText;
    }
  }

  void getArticle(BuildContext context) {
    if (state.formKey.currentState!.validate()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WebviewScreen(url: state.urlController.text),
        ),
      );
    }
  }

  @override
  void dispose() {
    state.urlController.dispose();
    super.dispose();
  }
}

final homeProvider = StateNotifierProvider.autoDispose<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(ref),
);
