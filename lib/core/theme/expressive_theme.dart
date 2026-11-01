import 'package:flutter/services.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import 'package:freedium_mobile/core/layout/floating_toolbar.dart';

class const ExpressiveTheme({required this.child, super.key})
    extends StatelessWidget {
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final material = Theme.of(context);
    // M3E's theme projection omits fixed roles; keep the complete native scheme.
    final themed = material.copyWith(
      textTheme: M3ETypography.material3().baseline
          .withColor(material.colorScheme.onSurface)
          .toTextTheme(),
    );
    final isDark = material.brightness == Brightness.dark;
    final base = M3EThemeData.fromMaterial(themed);
    final themeData = base.copyWith(
      textFieldTheme: base.textFieldTheme.copyWith(
        // Filled fields use the expressive rounding of buttons and the search
        // bar. The M3 spec's bottom indicator paints a full-width bar that
        // cannot follow rounded corners, so it is disabled; errors still read
        // through the label, caret and supporting text.
        filledShape: M3EShapes.radiusExtraLarge,
        activeIndicatorWidth: 0,
        focusActiveIndicatorWidth: 0,
      ),
      // Keep transient messages above the floating navigation and reader
      // toolbars instead of covering their actions.
      snackBarTheme: base.snackBarTheme.copyWith(
        overlayBottomInset: floatingToolbarContentInset(),
      ),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // M3E app bars paint behind the transparent status bar. Keeping the
      // style at the app root ties the icon brightness to the resolved theme;
      // otherwise the style of the last opened M3E sheet or dialog sticks
      // after it closes and survives theme changes.
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: M3ETheme(
        data: themeData,
        // M3ETheme projects its color scheme onto Theme.of for descendants and
        // drops native fixed roles. Re-assert the complete native scheme below
        // the M3E scope so Material widgets keep it while M3E components read
        // the expressive theme above.
        child: Theme(
          data: themed,
          // Bridge dependencies that still use package:flutter/material.dart.
          // ignore: deprecated_member_use
          child: MaterialUiCompatibilityBridge(child: child),
        ),
      ),
    );
  }
}
