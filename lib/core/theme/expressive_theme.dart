import 'package:flutter/services.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

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
        data: M3EThemeData.fromMaterial(themed),
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
