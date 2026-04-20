import 'package:flutter/material.dart';
import 'package:freedium_mobile/features/webview/domain/webview_state.dart';

/// A thin dismissible bar shown at the bottom of the WebView once article
/// metadata (author, read time) has been extracted from the Freedium DOM.
class ArticleMetaBar extends StatefulWidget {
  final ArticleMeta meta;
  final VoidCallback onDismiss;

  const ArticleMetaBar({
    super.key,
    required this.meta,
    required this.onDismiss,
  });

  @override
  State<ArticleMetaBar> createState() => _ArticleMetaBarState();
}

class _ArticleMetaBarState extends State<ArticleMetaBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = widget.meta;

    final parts = <String>[];
    if (meta.author.isNotEmpty) parts.add(meta.author);
    if (meta.readTime.isNotEmpty) parts.add(meta.readTime);
    final label = parts.join(' · ');

    if (label.isEmpty) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnim,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Material(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _dismiss,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
