import 'package:flutter/material.dart';

/// AppSpacing implements the 8px grid system.
class AppSpacing {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// AppRadius defines standardized rounding across the app.
class AppRadius {
  static const Radius small = Radius.circular(8);
  static const Radius medium = Radius.circular(12);
  static const Radius large = Radius.circular(16);
  static const Radius pill = Radius.circular(999);

  static final BorderRadius smallBR = BorderRadius.circular(8);
  static final BorderRadius mediumBR = BorderRadius.circular(12);
  static final BorderRadius largeBR = BorderRadius.circular(16);
  static final BorderRadius pillBR = BorderRadius.circular(999);
}

/// AppShadow provides consistent depth levels.
class AppShadow {
  static final List<BoxShadow> level1 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static final List<BoxShadow> level2 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> level3 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> level4 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.14),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}

/// AppDuration for standardized animation timings.
class AppDuration {
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 350);
}

/// AppCurve for standardized animation easing.
class AppCurve {
  static const standard = Cubic(0.4, 0.0, 0.2, 1.0);
}
