import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ChangelogBottomSheet extends StatelessWidget {
  const ChangelogBottomSheet({super.key, required this.updateInfo});

  final UpdateInfo updateInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            'What\'s New',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: .bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version ${updateInfo.latestVersion}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),

              const Divider(),

              Expanded(
                child: Markdown(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  data: updateInfo.releaseNotes,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                    h1: TextStyle(
                      fontSize: 24,
                      fontWeight: .bold,
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                    h2: TextStyle(
                      fontSize: 20,
                      fontWeight: .bold,
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                    h3: TextStyle(
                      fontSize: 18,
                      fontWeight: .bold,
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                    h4: TextStyle(
                      fontSize: 16,
                      fontWeight: .bold,
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                    h5: TextStyle(
                      fontSize: 15,
                      fontWeight: .bold,
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                    h6: TextStyle(
                      fontSize: 14,
                      fontWeight: .bold,
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                    listBullet: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: theme.colorScheme.onSurface,
                    ),
                    listIndent: 24,
                    blockquotePadding: const EdgeInsets.all(12),
                    blockquoteDecoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      border: Border(
                        left: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 4,
                        ),
                      ),
                    ),
                    code: TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                    codeblockPadding: const EdgeInsets.all(12),
                    codeblockDecoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    a: TextStyle(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTapLink: (text, href, title) {
                    if (href != null) {
                      launchUrl(Uri.parse(href));
                    }
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        launchUrl(Uri.parse(updateInfo.releaseUrl));
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Update Now'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void showChangelogBottomSheet(BuildContext context, UpdateInfo updateInfo) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ChangelogBottomSheet(updateInfo: updateInfo),
  );
}
