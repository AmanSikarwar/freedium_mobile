import 'package:shared_preferences/shared_preferences.dart';

class FontSizeService {
  static const String _fontSizeKey = 'webview_font_size';
  static const double _defaultFontSize = 18.0;

  Future<void> saveFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, fontSize);
  }

  Future<double> loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? _defaultFontSize;
  }

  Future<void> resetFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fontSizeKey);
  }
}
