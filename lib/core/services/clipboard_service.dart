import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clipboard_service.g.dart';

class ClipboardService() {
  Future<String?> detectUrl() async {
    try {
      return await const MethodChannel('freedium/clipboard')
          .invokeMethod<String>('readUrl');
    } catch (e) {
      debugPrint('Clipboard URL detection unavailable: $e');
      return null;
    }
  }

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
