class AppConstants {
  static const String freediumUrl = 'https://freedium.cfd';
  static const String appName = 'Freedium';
  static const String appDescription = 'Your paywall breakthrough for Medium!';
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '0.5.0',
  );

  static const String urlRegExp =
      r'^https?:\/\/([\w-]+\.)+[\w-]+(\/[\w-./?%&=@]*)?$';
}
