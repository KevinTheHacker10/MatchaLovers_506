import 'package:flutter/material.dart';

// =============================================================================
// BREAKPOINTS
// =============================================================================

/// Device type based on screen width
enum DeviceType { mobile, tablet, desktop }

/// Central class for all responsive logic
class Responsive {
  // Breakpoint thresholds
  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  /// Returns the [DeviceType] for the current screen width
  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileMax) return DeviceType.mobile;
    if (width < tabletMax) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      deviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      deviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      deviceType(context) == DeviceType.desktop;

  static bool isTabletOrDesktop(BuildContext context) =>
      !isMobile(context);

  // ---------------------------------------------------------------------------
  // Grid columns for product catalog
  // ---------------------------------------------------------------------------

  /// Returns the number of grid columns based on screen width
  static int gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileMax) return 2;       // Mobile: 2 columns
    if (width < tabletMax) return 3;       // Tablet: 3 columns
    return 4;                               // Desktop: 4 columns
  }

  // ---------------------------------------------------------------------------
  // Cart panel width
  // ---------------------------------------------------------------------------

  /// Returns the fixed width of the cart panel on tablet/desktop.
  /// On mobile the cart is a bottom sheet/modal, so this returns 0.
  static double cartPanelWidth(BuildContext context) {
    if (isMobile(context)) return 0;
    if (isTablet(context)) return 320;
    return 380;
  }

  // ---------------------------------------------------------------------------
  // Spacing helpers
  // ---------------------------------------------------------------------------

  /// Horizontal padding that scales with screen size
  static double horizontalPadding(BuildContext context) {
    if (isMobile(context)) return 12;
    if (isTablet(context)) return 16;
    return 24;
  }

  // ---------------------------------------------------------------------------
  // Value selector shorthand
  // ---------------------------------------------------------------------------

  /// Returns one of three values depending on device type.
  /// Usage: Responsive.value(context, mobile: 2, tablet: 3, desktop: 4)
  static T value<T>(
    BuildContext context, {
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    switch (deviceType(context)) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }
}

// =============================================================================
// RESPONSIVE LAYOUT WIDGET
// =============================================================================

/// Renders different widgets based on screen size.
///
/// ```dart
/// ResponsiveLayout(
///   mobile: MobileView(),
///   tablet: TabletView(),   // optional — falls back to desktop
///   desktop: DesktopView(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width < Responsive.mobileMax) return mobile;
        if (width < Responsive.tabletMax) return tablet ?? desktop;
        return desktop;
      },
    );
  }
}
