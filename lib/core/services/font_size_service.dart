import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';

part 'font_size_service.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferencesWithCache> sharedPreferences(Ref ref) async {
  await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
    legacySharedPreferencesInstance: await SharedPreferences.getInstance(),
    sharedPreferencesAsyncOptions: const SharedPreferencesOptions(),
    migrationCompletedKey: 'preferences_migrated_v1',
  );
  return SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
}

class FontSizeService(this._prefs) {
  static const String _fontSizeKey = 'webview_font_size';
  static const String _legacyDefaultFontSizeKey = 'default_font_size';
  static const double minFontSize = 14.0;
  static const double maxFontSize = 28.0;
  static const double defaultFontSize = 18.0;
  final SharedPreferencesWithCache _prefs;

  Future<void> saveFontSize(double fontSize) async {
    await _prefs.setDouble(_fontSizeKey, normalizeFontSize(fontSize));
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

    await _prefs.remove(key);
  }
}
