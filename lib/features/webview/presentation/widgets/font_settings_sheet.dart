import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showFontSettingsSheet(
  BuildContext context, {
  required double initialFontSize,
  required Function(double) onFontSizeChanged,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return FontSettingsSheet(
        initialFontSize: initialFontSize,
        onFontSizeChanged: onFontSizeChanged,
      );
    },
  );
}

class FontSettingsSheet extends ConsumerStatefulWidget {
  final double initialFontSize;
  final Function(double) onFontSizeChanged;

  const FontSettingsSheet({
    super.key,
    required this.initialFontSize,
    required this.onFontSizeChanged,
  });

  @override
  ConsumerState<FontSettingsSheet> createState() => _FontSettingsSheetState();
}

class _FontSettingsSheetState extends ConsumerState<FontSettingsSheet> {
  late double _currentFontSize;

  @override
  void initState() {
    super.initState();
    _currentFontSize = widget.initialFontSize;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: .only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const .vertical(top: .circular(20)),
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          Container(
            margin: const .only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: .circular(2),
            ),
          ),

          Padding(
            padding: const .symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  'Font Size',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: .bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const .symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  'Size: ${_currentFontSize.toInt()}px',
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: .w500),
                ),
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _currentFontSize = 18.0;
                    });
                    widget.onFontSizeChanged(_currentFontSize);
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ),

          Padding(
            padding: const .symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.text_fields, size: 16),
                Expanded(
                  child: Slider(
                    value: _currentFontSize,
                    min: 14,
                    max: 28,
                    divisions: 14,
                    label: '${_currentFontSize.toInt()}px',
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _currentFontSize = value;
                      });
                      widget.onFontSizeChanged(value);
                    },
                  ),
                ),
                const Icon(Icons.text_fields, size: 28),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
