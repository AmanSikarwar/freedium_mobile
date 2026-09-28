import 'package:material_ui/material_ui.dart';
import 'package:freedium_mobile/shared/widgets/article_card.dart'
    show libraryContentMaxWidth;

/// Search bar hosted in the `AppBar.bottom` slot of library screens
/// (history, bookmarks).
///
/// Extracts the previously duplicated search header: fixed heights, centered
/// max-width constrained [SearchBar] with a clear button.
class const LibrarySearchHeader({
  super.key,
  required this.controller,
  required this.hintText,
  required this.query,
  required this.onChanged,
  required this.onClear,
}) extends StatelessWidget implements PreferredSizeWidget {
  static const double searchBarHeight = 56.0;
  static const double searchBarBottomPadding = 8.0;
  static const double searchAreaHeight =
      searchBarHeight + searchBarBottomPadding;

  final TextEditingController controller;
  final String hintText;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Size get preferredSize => const Size.fromHeight(searchAreaHeight);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: libraryContentMaxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, searchBarBottomPadding),
          child: SearchBar(
            controller: controller,
            hintText: hintText,
            leading: const Icon(Icons.search),
            trailing: [
              if (query.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Clear search',
                  onPressed: onClear,
                ),
            ],
            onChanged: onChanged,
            elevation: const WidgetStatePropertyAll(0),
            side: WidgetStatePropertyAll(
              BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
        ),
      ),
    );
  }
}
