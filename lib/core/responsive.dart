import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Responsive Utility
//  Usage:
//    R.of(context).sp(14)          → scaled font size
//    R.of(context).w(20)           → % of screen width
//    R.of(context).h(10)           → % of screen height
//    R.of(context).isMobile        → screen width < 600
//    R.of(context).isTablet        → 600 ≤ width < 1024
//    R.of(context).isDesktop       → width ≥ 1024
//    R.of(context).hp(1.0)         → horizontal padding (safe)
//
//  ResponsiveBuilder widget for layout switching:
//    ResponsiveBuilder(
//      mobile:  (ctx, sz) => MobileLayout(),
//      tablet:  (ctx, sz) => TabletLayout(),   // optional
//      desktop: (ctx, sz) => DesktopLayout(),  // optional
//    )
// ─────────────────────────────────────────────────────────────────────────────

class R {
  final BuildContext _context;

  R._(this._context);

  factory R.of(BuildContext context) => R._(context);

  // ── Screen metrics ────────────────────────────────────────────────────────
  Size   get _size   => MediaQuery.of(_context).size;
  double get width   => _size.width;
  double get height  => _size.height;

  // ── Breakpoints ───────────────────────────────────────────────────────────
  bool get isMobile  => width < 600;
  bool get isTablet  => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;

  // ── Adaptive values ───────────────────────────────────────────────────────

  /// Percentage of screen width  e.g. w(5) = 5% of width
  double w(double percent) => width * percent / 100;

  /// Percentage of screen height  e.g. h(10) = 10% of height
  double h(double percent) => height * percent / 100;

  /// Scaled font size — scales relative to 375pt baseline (iPhone SE)
  double sp(double size) {
    final scale = (width / 375).clamp(0.85, 1.6);
    return size * scale;
  }

  /// Horizontal page padding — scales with screen width
  double get hp => isMobile ? 20 : (isTablet ? 40 : 80);

  /// Vertical section spacing
  double get vs => isMobile ? 20 : (isTablet ? 28 : 36);

  /// Card border radius
  double get radius => isMobile ? 4 : 8;

  /// Adaptive value: pick from mobile / tablet / desktop
  T adaptive<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Number of grid columns  
  int gridCols({int mobile = 1, int tablet = 2, int desktop = 3}) =>
      adaptive(mobile: mobile, tablet: tablet, desktop: desktop);
}

// ── Convenience extension ─────────────────────────────────────────────────────
extension ResponsiveContext on BuildContext {
  R get r => R.of(this);
}

// ─────────────────────────────────────────────────────────────────────────────
//  ResponsiveBuilder widget
// ─────────────────────────────────────────────────────────────────────────────
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Size size) mobile;
  final Widget Function(BuildContext context, Size size)? tablet;
  final Widget Function(BuildContext context, Size size)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final w   = constraints.maxWidth;

        if (w >= 1024 && desktop != null) return desktop!(context, size);
        if (w >= 600  && tablet  != null) return tablet!(context, size);
        return mobile(context, size);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Responsive padded body wrapper
//  Wraps content with proper horizontal padding for all screen sizes
// ─────────────────────────────────────────────────────────────────────────────
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? mobilePadding;

  const ResponsivePadding({super.key, required this.child, this.mobilePadding});

  @override
  Widget build(BuildContext context) {
    final r = R.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: mobilePadding ?? r.hp),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Adaptive grid helper
//  Auto-switches between 1 / 2 / 3 columns based on screen width
// ─────────────────────────────────────────────────────────────────────────────
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileCols;
  final int tabletCols;
  final int desktopCols;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.mobileCols  = 1,
    this.tabletCols  = 2,
    this.desktopCols = 3,
    this.spacing     = 16,
    this.runSpacing  = 16,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final cols = R.of(context).gridCols(
      mobile:  mobileCols,
      tablet:  tabletCols,
      desktop: desktopCols,
    );
    return GridView.count(
      crossAxisCount: cols,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}
