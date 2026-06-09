import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await .getInstance();
});

class FontSizeService {
  static const String _fontSizeKey = 'webview_font_size';
  static const String _legacyDefaultFontSizeKey = 'default_font_size';
  static const double minFontSize = 14.0;
  static const double maxFontSize = 28.0;
  static const double defaultFontSize = 18.0;
  final SharedPreferences _prefs;

  FontSizeService(this._prefs);

  Future<void> saveFontSize(double fontSize) async {
    final success = await _prefs.setDouble(
      _fontSizeKey,
      normalizeFontSize(fontSize),
    );
    if (!success) {
      throw Exception('setDouble returned false for key "$_fontSizeKey"');
    }
  }

  double loadFontSize() {
    return normalizeFontSize(
      _prefs.getDouble(_fontSizeKey) ??
          _prefs.getDouble(_legacyDefaultFontSizeKey) ??
          defaultFontSize,
    );
  }

  Future<void> resetFontSize() async {
    await _removeIfPresent(_fontSizeKey);
    await _removeIfPresent(_legacyDefaultFontSizeKey);
  }

  static double normalizeFontSize(double fontSize) {
    if (!fontSize.isFinite) return defaultFontSize;
    return fontSize.clamp(minFontSize, maxFontSize).toDouble();
  }

  Future<void> _removeIfPresent(String key) async {
    if (!_prefs.containsKey(key)) return;

    final success = await _prefs.remove(key);
    if (!success) {
      throw Exception('remove returned false for key "$key"');
    }
  }
}
