import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/clipboard_service.dart';
import 'package:freedium_mobile/features/home/domain/home_state.dart';

export 'package:freedium_mobile/features/home/domain/home_state.dart';

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    final urlController = TextEditingController();

    ref.onDispose(urlController.dispose);

    return HomeState(
      urlController: urlController,
      formKey: GlobalKey<FormState>(),
    );
  }

  Future<void> pasteFromClipboard() async {
    final clipboardText = await ref.read(clipboardServiceProvider).paste();
    if (clipboardText != null) {
      state.urlController.text = clipboardText;
    }
  }

  String? getValidatedUrl() {
    if (state.formKey.currentState!.validate()) {
      return state.urlController.text;
    }
    return null;
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
