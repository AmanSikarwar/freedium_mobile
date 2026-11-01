import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';
import 'package:freedium_mobile/shared/widgets/expressive_icon_button.dart';

class const MirrorListTile({
  super.key,
  required this.mirror,
  required this.selectedMirrorUrl,
  required this.onSelect,
  this.onEdit,
  this.onDelete,
}) extends ConsumerStatefulWidget {
  final FreediumMirror mirror;
  final String? selectedMirrorUrl;
  final ValueChanged<String> onSelect;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  ConsumerState<MirrorListTile> createState() => _MirrorListTileState();
}

class _MirrorListTileState() extends ConsumerState<MirrorListTile> {
  bool _isTesting = false;
  MirrorTestResult? _testResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const .symmetric(horizontal: 16, vertical: 4),
      child: M3ECard(
        variant: M3ECardVariant.filled,
        padding: const .all(12),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                M3ERadio<String>(
                  value: widget.mirror.url,
                  groupValue: widget.selectedMirrorUrl,
                  onChanged: widget.onSelect,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: .center,
                        children: [
                          Text(
                            widget.mirror.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: .bold,
                            ),
                          ),
                          if (widget.mirror.isDefault) ...[
                            Container(
                              padding: const .symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: .circular(4),
                              ),
                              child: Text(
                                'Default',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                          if (widget.mirror.isCustom) ...[
                            Container(
                              padding: const .symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: .circular(4),
                              ),
                              child: Text(
                                'Custom',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.mirror.url,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: .ellipsis,
                      ),
                    ],
                  ),
                ),
                if (_testResult != null)
                  Padding(
                    padding: const .only(right: 8),
                    child: Icon(
                      _testResult!.isReachable
                          ? Icons.check_circle
                          : Icons.error,
                      color: _testResult!.isReachable
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                      size: 20,
                    ),
                  ),
                M3EMenu.entries(
                  anchorBuilder: (context, open) => ExpressiveIconButton(
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'Mirror options',
                    onPressed: open,
                  ),
                  position: M3EMenuAnchorPosition.bottomEnd,
                  onSelected: (value) {
                    switch (value) {
                      case 'test':
                        HapticFeedback.lightImpact();
                        _handleTest();
                        break;
                      case 'edit':
                        HapticFeedback.lightImpact();
                        widget.onEdit?.call();
                        break;
                      case 'delete':
                        HapticFeedback.mediumImpact();
                        widget.onDelete?.call();
                        break;
                    }
                  },
                  entries: [
                    const M3EMenuEntry(
                      label: 'Test',
                      value: 'test',
                      leading: Icon(Icons.speed),
                    ),
                    if (widget.onEdit != null)
                      const M3EMenuEntry(
                        label: 'Edit',
                        value: 'edit',
                        leading: Icon(Icons.edit),
                      ),
                    if (widget.onDelete != null)
                      const M3EMenuEntry(
                        label: 'Delete',
                        value: 'delete',
                        leading: Icon(Icons.delete),
                        isDestructive: true,
                      ),
                  ],
                ),
              ],
            ),
            if (_isTesting)
              const Padding(
                padding: .only(top: 8),
                child: M3EProgressIndicator.linear(),
              ),
            if (_testResult != null && !_isTesting)
              Padding(
                padding: const .only(top: 8, left: 48),
                child: Text(
                  _testResult!.isReachable
                      ? 'Reachable (${_testResult!.responseTimeMs}ms)'
                      : 'Unreachable: ${_testResult!.error}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _testResult!.isReachable
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTest() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final result = await ref
        .read(settingsProvider.notifier)
        .testMirror(widget.mirror.url);

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testResult = result;
      });
    }
  }
}
