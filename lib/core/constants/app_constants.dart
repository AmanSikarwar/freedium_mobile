class AppConstants {
  static const String freediumUrl = 'https://freedium.cfd';
  static const String freediumMirrorUrl = 'https://freedium-mirror.cfd';
  static const String appName = 'Freedium';
  static const String appDescription =
      'Your paywall breakthrough for premium articles!';
  static const String appPackageName = 'io.github.amansikarwar.freedium_mobile';
  static const String appSourceUrl =
      'https://github.com/AmanSikarwar/freedium_mobile';
  static const String appVersion = .fromEnvironment(
    'APP_VERSION',
    defaultValue: '0.10.0',
  );
}
