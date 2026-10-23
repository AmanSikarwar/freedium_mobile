import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../bookmarks/presentation/bookmarks_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../settings/presentation/settings_screen.dart';

/// Root shell hosting the home, bookmarks, history, and settings tabs behind a
/// floating Material 3 Expressive navigation toolbar.
///
/// The selected destination expands to an icon + label pill, mirroring the
/// floating toolbar pattern used by expressive apps; unselected destinations
/// stay icon-only. Tab switches crossfade while the outgoing tab keeps its
/// state offstage.
class const AppShell({super.key}) extends StatefulWidget {
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState()
    extends State<AppShell>
    with SingleTickerProviderStateMixin {
  static const List<({String label, IconData icon, Widget tab})> _destinations =
      [
        (label: 'Home', icon: Icons.home_outlined, tab: HomeScreen()),
        (
          label: 'Bookmarks',
          icon: Icons.bookmark_border,
          tab: BookmarksScreen(),
        ),
        (label: 'History', icon: Icons.history, tab: HistoryScreen()),
        (label: 'Settings', icon: Icons.settings, tab: SettingsScreen()),
      ];
  static const Duration _crossfadeDuration = Duration(milliseconds: 220);

  late final AnimationController _crossfade;
  int _index = 0;

  /// Tabs are built on first visit so unopened screens do not load data.
  final Set<int> _visited = {0};

  /// Opacity each visible tab started the current crossfade from.
  ///
  /// Keeping a start per tab (instead of a single outgoing tab) keeps the fade
  /// continuous when another destination is tapped mid-transition.
  final Map<int, double> _fadeStarts = <int, double>{};

  @override
  void initState() {
    super.initState();
    _crossfade = AnimationController(
      vsync: this,
      duration: _crossfadeDuration,
      value: 1,
    )..addStatusListener(_handleCrossfadeStatus);
  }

  @override
  void dispose() {
    _crossfade
      ..removeStatusListener(_handleCrossfadeStatus)
      ..dispose();
    super.dispose();
  }

  void _handleCrossfadeStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _fadeStarts.isNotEmpty) {
      setState(_fadeStarts.clear);
    }
  }

  /// Current opacity of [index] at [progress] through the crossfade.
  double _opacityAt(int index, double progress) {
    final double start = _fadeStarts[index] ?? 0;
    return index == _index
        ? start + (1 - start) * progress
        : start * (1 - progress);
  }

  void _select(int index) {
    if (index == _index) return;
    HapticFeedback.lightImpact();
    FocusManager.instance.primaryFocus?.unfocus();

    final double progress = Curves.easeInOut.transform(_crossfade.value);
    final starts = <int, double>{};
    for (final tab in {_index, ..._fadeStarts.keys, index}) {
      final double opacity = _opacityAt(tab, progress);
      if (opacity > 0) {
        starts[tab] = opacity;
      }
    }

    setState(() {
      _fadeStarts
        ..clear()
        ..addAll(starts);
      _index = index;
      _visited.add(index);
    });
    _crossfade.forward(from: 0);
  }

  Widget _buildTab(int index) {
    if (!_visited.contains(index)) {
      return const SizedBox.shrink();
    }
    return _destinations[index].tab;
  }

  Widget _buildTabLayer(int index) {
    final bool isSelected = index == _index;
    final bool isVisible = isSelected || _fadeStarts.containsKey(index);
    return Offstage(
      offstage: !isVisible,
      child: AnimatedBuilder(
        animation: _crossfade,
        child: _buildTab(index),
        builder: (context, child) {
          final double progress = Curves.easeInOut.transform(_crossfade.value);
          final double start = _fadeStarts[index] ?? 0;
          final double opacity = isSelected
              ? start + (1 - start) * progress
              : start * (1 - progress);
          return ExcludeFocus(
            excluding: !isSelected,
            child: IgnorePointer(
              ignoring: !isSelected,
              child: ExcludeSemantics(
                excluding: !isSelected,
                child: Opacity(opacity: opacity, child: child),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _select(0);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Stack(
              fit: StackFit.expand,
              children: [
                for (var i = 0; i < _destinations.length; i++)
                  _buildTabLayer(i),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: M3EToolbar(
                alignment: Alignment.bottomCenter,
                semanticLabel: 'Main navigation',
                safeArea: true,
                actions: [
                  for (var i = 0; i < _destinations.length; i++)
                    M3EToolbarAction(
                      icon: _destinations[i].icon,
                      label: _destinations[i].label,
                      tooltip: _destinations[i].label,
                      active: _index == i,
                      onPressed: () => _select(i),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
