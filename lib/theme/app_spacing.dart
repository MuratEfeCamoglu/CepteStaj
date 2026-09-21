/// 4pt spacing scale used throughout the layouts.
class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}

/// Corner radii used across cards, pills and buttons. Slightly larger than
/// a typical Material default — one of the small levers that reads as
/// "modernist minimal" rather than "generic app".
class AppRadius {
  AppRadius._();

  static const card = 16.0;
  static const cardLarge = 24.0;
  static const pill = 999.0;
}

/// Breakpoints and content-width caps that keep layouts legible past
/// phone width — a tablet, a foldable, or the app running in a resizable
/// desktop/web window. Screens wrap their scrollable content in
/// [ResponsiveContent] rather than reaching for these directly.
class AppBreakpoints {
  AppBreakpoints._();

  /// Above this width, content is centered instead of stretched edge to
  /// edge — a single column of body text or a settings list shouldn't
  /// become a full-bleed paragraph on a tablet.
  static const compact = 600.0;

  /// Above this, wide layouts (e.g. two-column grids) may kick in.
  static const medium = 900.0;

  /// Max width a single reading/edit column is allowed to grow to.
  static const maxContentWidth = 640.0;
}
