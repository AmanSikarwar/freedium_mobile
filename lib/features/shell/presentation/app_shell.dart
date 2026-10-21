import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../bookmarks/presentation/bookmarks_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../home/presentation/home_screen.dart';

/// Root shell hosting the home, bookmarks, history, and settings tabs behind a
/// floating Material 3 Expressive navigation toolbar.
///
/// The selected destination expands to an icon + label pill, mirroring the
/// floating toolbar pattern used by expressive apps; unselected destinations
/// stay icon-only.
class const AppShell({super.key}) extends StatefulWidget {
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState() extends State<AppShell> {
  static const List<({String label, IconData icon})> _destinations = [
    (label: 'Home', icon: Icons.home_outlined),
    (label: 'Bookmarks', icon: Icons.bookmark_border),
    (label: 'History', icon: Icons.history),
    (label: 'Settings', icon: Icons.settings),
  ];

  int _index = 0;

  /// Tabs are built on first visit so unopened screens do not load data.
  final Set<int> _visited = {0};

  void _select(int index) {
    if (index == _index) return;
    HapticFeedback.lightImpact();
    setState(() {
      _index = index;
      _visited.add(index);
    });
  }

  Widget _buildTab(int index) {
    if (!_visited.contains(index)) {
      return const SizedBox.shrink();
    }
    return switch (index) {
      0 => const HomeScreen(),
      1 => const BookmarksScreen(),
      2 => const HistoryScreen(),
      _ => const SettingsScreen(),
    };
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
            IndexedStack(
              index: _index,
              children: [
                for (var i = 0; i < _destinations.length; i++) _buildTab(i),
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
