import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

class FontSizeService {
  static const String _fontSizeKey = 'webview_font_size';
  static const double _defaultFontSize = 18.0;
  final SharedPreferences _prefs;

  FontSizeService(this._prefs);

  Future<void> saveFontSize(double fontSize) async {
    await _prefs.setDouble(_fontSizeKey, fontSize);
  }

  double loadFontSize() {
    return _prefs.getDouble(_fontSizeKey) ?? _defaultFontSize;
  }

  Future<void> resetFontSize() async {
    await _prefs.remove(_fontSizeKey);
  }
}
