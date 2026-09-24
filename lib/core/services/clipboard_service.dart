import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clipboard_service.g.dart';

class ClipboardService() {
  Future<String?> paste() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      return clipboardData?.text;
    } catch (e) {
      debugPrint('Failed to read clipboard: $e');
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
ClipboardService clipboardService(Ref ref) => ClipboardService();
