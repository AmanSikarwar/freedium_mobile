import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await .getInstance();
});

class FontSizeService {
  static const String _fontSizeKey = 'webview_font_size';
  static const double minFontSize = 14.0;
  static const double maxFontSize = 28.0;
  static const double defaultFontSize = 18.0;
  final SharedPreferences _prefs;

  FontSizeService(this._prefs);

  Future<void> saveFontSize(double fontSize) async {
    await _prefs.setDouble(_fontSizeKey, normalizeFontSize(fontSize));
  }

  double loadFontSize() {
    return normalizeFontSize(_prefs.getDouble(_fontSizeKey) ?? defaultFontSize);
  }

  Future<void> resetFontSize() async {
    await _prefs.remove(_fontSizeKey);
  }

  static double normalizeFontSize(double fontSize) {
    if (!fontSize.isFinite) return defaultFontSize;
    return fontSize.clamp(minFontSize, maxFontSize).toDouble();
  }
}
