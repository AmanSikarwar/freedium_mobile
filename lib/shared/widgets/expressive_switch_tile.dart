import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

class const ExpressiveSwitchTile({
  required this.value,
  required this.onChanged,
  required this.title,
  required this.subtitle,
  required this.leading,
  super.key,
}) extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget title;
  final Widget subtitle;
  final Widget leading;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      onTap: () => onChanged(!value),
      trailing: ExcludeFocus(
        child: M3ESwitch(value: value, onChanged: onChanged),
      ),
    ),
  );
}
