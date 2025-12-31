import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

class MirrorListTile extends ConsumerStatefulWidget {
  final FreediumMirror mirror;
  final bool isSelected;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MirrorListTile({
    super.key,
    required this.mirror,
    required this.isSelected,
    this.onEdit,
    this.onDelete,
  });

  @override
  ConsumerState<MirrorListTile> createState() => _MirrorListTileState();
}

class _MirrorListTileState extends ConsumerState<MirrorListTile> {
  bool _isTesting = false;
  MirrorTestResult? _testResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const .symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const .all(12),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                Radio<String>(value: widget.mirror.url),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.mirror.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: .bold,
                            ),
                          ),
                          if (widget.mirror.isDefault) ...[
                            const SizedBox(width: 8),
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
                            const SizedBox(width: 8),
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
                          ? Colors.green
                          : Colors.red,
                      size: 20,
                    ),
                  ),
                PopupMenuButton<String>(
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
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'test',
                      child: Row(
                        children: [
                          Icon(Icons.speed),
                          SizedBox(width: 8),
                          Text('Test'),
                        ],
                      ),
                    ),
                    if (widget.onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    if (widget.onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (_isTesting)
              const Padding(
                padding: .only(top: 8),
                child: LinearProgressIndicator(),
              ),
            if (_testResult != null && !_isTesting)
              Padding(
                padding: const .only(top: 8, left: 48),
                child: Text(
                  _testResult!.isReachable
                      ? 'Reachable (${_testResult!.responseTimeMs}ms)'
                      : 'Unreachable: ${_testResult!.error}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _testResult!.isReachable ? Colors.green : Colors.red,
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
