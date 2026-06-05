import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClipboardService {
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

final clipboardServiceProvider = Provider((ref) => ClipboardService());
