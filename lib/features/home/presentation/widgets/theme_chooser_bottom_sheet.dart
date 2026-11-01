import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

void showThemeChooserBottomSheet(BuildContext context) {
  M3EBottomSheet.show<void>(
    context,
    builder: (context) => const ThemeChooserBottomSheet(),
  );
}

class const ThemeChooserBottomSheet({super.key}) extends ConsumerWidget {
  Future<void> _selectTheme(
    BuildContext context,
    Settings settingsNotifier,
    ThemeMode themeMode,
  ) async {
    HapticFeedback.selectionClick();
    final navigator = Navigator.of(context);
    final didSave = await settingsNotifier.setThemeMode(themeMode);
    if (!context.mounted) return;
    if (didSave) {
      navigator.pop();
    } else {
      M3ESnackbar.show(
        context,
        message: 'Failed to save theme',
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value ?? const SettingsState();
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Padding(
      padding: const .symmetric(vertical: 16),
      child: Column(
        mainAxisSize: .min,
        children: [
          Padding(
            padding: const .symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Choose Theme',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: .bold),
            ),
          ),
          const M3EDivider(),
          M3EListItem(
            headline: 'Light',
            leading: const Icon(Icons.light_mode),
            trailing: settings.themeMode == .light
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () => _selectTheme(context, settingsNotifier, .light),
          ),
          M3EListItem(
            headline: 'Dark',
            leading: const Icon(Icons.dark_mode),
            trailing: settings.themeMode == .dark
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () => _selectTheme(context, settingsNotifier, .dark),
          ),
          M3EListItem(
            headline: 'System',
            leading: const Icon(Icons.brightness_auto),
            trailing: settings.themeMode == .system
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () => _selectTheme(context, settingsNotifier, .system),
          ),
        ],
      ),
    );
  }
}
