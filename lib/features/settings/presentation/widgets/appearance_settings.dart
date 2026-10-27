import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/theme_chooser_bottom_sheet.dart';
import 'package:freedium_mobile/features/webview/presentation/widgets/font_settings_sheet.dart';
import 'package:freedium_mobile/shared/widgets/expressive_switch_tile.dart';

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
    return M3EListItem(
      headline: 'Theme',
      supportingText: _getThemeModeName(settings.themeMode),
      leading: const Icon(Icons.brightness_6),
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
    return M3EListItem(
      headline: 'Default Font Size',
      supportingText: '${settings.defaultFontSize.toInt()}px',
      leading: const Icon(Icons.text_fields),
      onTap: () => showFontSettingsSheet(
        context,
        initialFontSize: settings.defaultFontSize,
        onFontSizeChanged: (newSize) async {
          final didSave = await notifier.setDefaultFontSize(newSize);
          if (!context.mounted) return;
          if (!didSave) {
            M3ESnackbar.show(
              context,
              message: 'Failed to save default font size',
              duration: const Duration(seconds: 4),
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
    return ExpressiveSwitchTile(
      leading: const Icon(Icons.notifications_outlined),
      title: 'Freedium Popups',
      subtitle: 'Show site announcements and notifications',
      value: settings.showSitePopups,
      onChanged: (value) async {
        HapticFeedback.lightImpact();
        final didSave = await notifier.setShowSitePopups(value);
        if (!context.mounted || didSave) return;
        M3ESnackbar.show(
          context,
          message: 'Failed to save site popup setting',
          duration: const Duration(seconds: 4),
        );
      },
    );
  }
}
