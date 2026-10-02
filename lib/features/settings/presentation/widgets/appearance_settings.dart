import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/theme_chooser_bottom_sheet.dart';
import 'package:freedium_mobile/features/webview/presentation/widgets/font_settings_sheet.dart';

class const AppearanceSettings({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).requireValue;
    final settingsNotifier = ref.read(settingsProvider.notifier);
    return Column(
      children: [
        _buildThemeTile(context, settings, settingsNotifier),
        _buildFontSizeTile(context, settings, settingsNotifier),
        _buildSitePopupsTile(context, settings, settingsNotifier),
      ],
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    SettingsState settings,
    Settings notifier,
  ) {
    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: const Text('Theme'),
      subtitle: Text(_getThemeModeName(settings.themeMode)),
      onTap: () => showThemeChooserBottomSheet(context),
    );
  }

  String _getThemeModeName(ThemeMode themeMode) {
    return switch (themeMode) {
      .light => 'Light',
      .dark => 'Dark',
      .system => 'System',
    };
  }

  Widget _buildFontSizeTile(
    BuildContext context,
    SettingsState settings,
    Settings notifier,
  ) {
    return ListTile(
      leading: const Icon(Icons.text_fields),
      title: const Text('Default Font Size'),
      subtitle: Text('${settings.defaultFontSize.toInt()}px'),
      onTap: () => showFontSettingsSheet(
        context,
        initialFontSize: settings.defaultFontSize,
        onFontSizeChanged: (newSize) async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final didSave = await notifier.setDefaultFontSize(newSize);
          if (!context.mounted) return;
          if (!didSave) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Failed to save default font size'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSitePopupsTile(
    BuildContext context,
    SettingsState settings,
    Settings notifier,
  ) {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications_outlined),
      title: const Text('Freedium Popups'),
      subtitle: const Text('Show site announcements and notifications'),
      value: settings.showSitePopups,
      onChanged: (value) async {
        HapticFeedback.lightImpact();
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final didSave = await notifier.setShowSitePopups(value);
        if (!context.mounted || didSave) return;
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to save site popup setting'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }
}
