import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:freedium_mobile/core/layout/floating_toolbar.dart';
import 'package:freedium_mobile/shared/widgets/article_card.dart';

/// Grouped, dismissible article list shared by the history and bookmarks
/// screens.
///
/// The screens own filtering, sorting, and per-item display mapping;
/// this widget owns the [ListView] shell, date-group headers, swipe to
/// remove, and [ArticleCard] wiring.
class const LibraryListView<T extends Object>({
  super.key,
  required this.grouped,
  required this.keyFor,
  required this.titleFor,
  required this.subtitleFor,
  required this.urlFor,
  required this.progressFor,
  required this.trailingFor,
  required this.onRemove,
  required this.removeFailMessage,
  required this.onTap,
  this.badgeFor,
}) extends StatelessWidget {
  /// `(groupLabel, item)` entries, e.g. from `buildGroupedList`.
  final List<(String, T)> grouped;
  final String Function(T item) keyFor;
  final String Function(T item) titleFor;
  final String Function(T item) subtitleFor;
  final String Function(T item) urlFor;
  final double? Function(T item) progressFor;
  final Widget? Function(T item) trailingFor;

  /// Optional per-item badge label (e.g. bookmark folder). Null everywhere
  /// when unused.
  final String? Function(T item)? badgeFor;

  /// Removes [item]; returns true when the removal persisted.
  final Future<bool> Function(T item) onRemove;
  final String removeFailMessage;
  final void Function(T item) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 24 + floatingToolbarClearance(context),
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final (label, item) = grouped[index];
        final showHeader = index == 0 || grouped[index - 1].$1 != label;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader) DateGroupHeader(label: label),
            Dismissible(
              key: ValueKey(keyFor(item)),
              direction: DismissDirection.endToStart,
              background: const ArticleDismissBackground(),
              confirmDismiss: (_) async {
                HapticFeedback.lightImpact();
                final didRemove = await onRemove(item);
                if (!context.mounted) return false;

                if (!didRemove) {
                  M3ESnackbar.show(
                    context,
                    message: removeFailMessage,
                    duration: const Duration(seconds: 4),
                  );
                }

                return didRemove;
              },
              child: ArticleCard(
                title: titleFor(item),
                subtitle: subtitleFor(item),
                url: urlFor(item),
                progress: progressFor(item),
                trailingIcon: trailingFor(item),
                badge: badgeFor?.call(item),
                onTap: () => onTap(item),
              ),
            ),
          ],
        );
      },
    );
  }
}
