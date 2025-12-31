class AppConstants {
  static const String freediumUrl = 'https://freedium.cfd';
  static const String freediumMirrorUrl = 'https://freedium-mirror.cfd';
  static const String appName = 'Freedium';
  static const String appDescription = 'Your paywall breakthrough for Medium!';
  static const String appPackageName = 'com.amansikarwar.freedium';
  static const String appSourceUrl = 'https://github.com/amansikarwar/freedium';
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '0.5.0',
  );

  static const String urlRegExp =
      r'^https?:\/\/([\w-]+\.)+[\w-]+(\/[\w-./?%&=@]*)?$';
}
