import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Centers [child] and caps its width past [AppBreakpoints.maxContentWidth]
/// so lists, forms and cards stay a comfortable reading column instead of
/// stretching edge to edge on a tablet, foldable, or resizable desktop/web
/// window. A no-op on phone-width screens.
///
/// Wrap the *content* of a screen with this — not the [Scaffold] itself —
/// so backgrounds, app bars and bottom nav still span full width while the
/// content inside stays centered.
class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
