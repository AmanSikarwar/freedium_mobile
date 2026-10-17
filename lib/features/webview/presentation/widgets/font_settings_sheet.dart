import 'package:freedium_mobile/shared/widgets/expressive_icon_button.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';

void showFontSettingsSheet(
  BuildContext context, {
  required double initialFontSize,
  required void Function(double) onFontSizeChanged,
}) {
  showModalBottomSheet<void>(
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

class const FontSettingsSheet({
  super.key,
  required this.initialFontSize,
  required this.onFontSizeChanged,
}) extends ConsumerStatefulWidget {
  final double initialFontSize;
  final void Function(double) onFontSizeChanged;

  @override
  ConsumerState<FontSettingsSheet> createState() => _FontSettingsSheetState();
}

class _FontSettingsSheetState() extends ConsumerState<FontSettingsSheet> {
  late double _currentFontSize;

  @override
  void initState() {
    super.initState();
    _currentFontSize = FontSizeService.normalizeFontSize(
      widget.initialFontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: .only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
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
                ExpressiveIconButton(
                  tooltip: 'Close',
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
                M3EButton.icon(
                  style: M3EButtonStyle.text,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _currentFontSize = FontSizeService.defaultFontSize;
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
                  child: M3ESlider(
                    value: _currentFontSize,
                    min: FontSizeService.minFontSize,
                    max: FontSizeService.maxFontSize,
                    divisions:
                        (FontSizeService.maxFontSize -
                                FontSizeService.minFontSize)
                            .toInt(),
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
