import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/theme/theme_provider.dart';

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
    final currentThemeMode = ref.watch(themeModeProvider);
    final themeModeNotifier = ref.read(themeModeProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Choose Theme',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              trailing:
                  currentThemeMode == ThemeMode.light
                      ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                      : null,
              onTap: () {
                themeModeNotifier.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              trailing:
                  currentThemeMode == ThemeMode.dark
                      ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                      : null,
              onTap: () {
                themeModeNotifier.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('System'),
              trailing:
                  currentThemeMode == ThemeMode.system
                      ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                      : null,
              onTap: () {
                themeModeNotifier.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
