import 'package:flutter/widgets.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

/// Clearance a floating toolbar claims from scrollable content: the pill
/// height, its bottom screen margin, and a small gap.
///
/// Use this when the toolbar already sits inside a [SafeArea] (for example a
/// reader whose content is rendered below the inset).
double floatingToolbarContentInset() =>
    M3EToolbarTokens.containerSize + M3EToolbarTokens.screenOffset + 8;

/// Bottom clearance that keeps tab content reachable above the floating
/// navigation toolbar: [floatingToolbarContentInset] plus the system bottom
/// inset.
double floatingToolbarClearance(BuildContext context) =>
    floatingToolbarContentInset() + MediaQuery.paddingOf(context).bottom;
