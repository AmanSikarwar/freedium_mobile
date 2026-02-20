import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';

void showThemeChooserBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => const ThemeChooserBottomSheet(),
  );
}

class ThemeChooserBottomSheet extends ConsumerWidget {
  const ThemeChooserBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const .symmetric(vertical: 16),
        child: Column(
          mainAxisSize: .min,
          children: [
            Padding(
              padding: const .symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Choose Theme',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: .bold),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              trailing: settings.themeMode == .light
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                settingsNotifier.setThemeMode(.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              trailing: settings.themeMode == .dark
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                settingsNotifier.setThemeMode(.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('System'),
              trailing: settings.themeMode == .system
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                settingsNotifier.setThemeMode(.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
