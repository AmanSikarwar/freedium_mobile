import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/shared/widgets/expressive_switch_tile.dart';

class const PrivacySettings({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ExpressiveSwitchTile(
      leading: const Icon(Icons.content_paste_search),
      title: 'Detect clipboard URLs',
      subtitle: 'Autofill links identified by Android. You can always paste manually.',
      value: ref.watch(settingsProvider).requireValue.autoDetectClipboard,
      onChanged: (enabled) async {
        final saved = await ref
            .read(settingsProvider.notifier)
            .setAutoDetectClipboard(enabled);
        if (!context.mounted || saved) return;
        M3ESnackbar.show(context, message: 'Could not save clipboard setting');
      },
    );
  }
}
