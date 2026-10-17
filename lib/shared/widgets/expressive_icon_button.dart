import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

class const ExpressiveIconButton({
  required this.icon,
  required this.tooltip,
  required this.onPressed,
  super.key,
}) extends StatelessWidget {
  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    // Keep the action separate inside text fields and actionable cards.
    container: true,
    button: true,
    enabled: onPressed != null,
    label: tooltip,
    onTap: onPressed,
    child: ExcludeSemantics(
      child: M3EIconButton(
        variant: M3EIconButtonVariant.standard,
        icon: icon,
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    ),
  );
}
