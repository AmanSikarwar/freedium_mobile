import 'package:flutter/widgets.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

/// Bottom clearance that keeps tab content reachable above the floating
/// navigation toolbar: the pill height, its top and bottom screen margins, the
/// system bottom inset, and a small gap.
double floatingToolbarClearance(BuildContext context) =>
    M3EToolbarTokens.containerSize +
    M3EToolbarTokens.screenOffset * 2 +
    8 +
    MediaQuery.paddingOf(context).bottom;
