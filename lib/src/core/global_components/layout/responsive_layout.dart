import 'package:family_bazar_admin_panel/src/core/const/app_constants.dart';
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget desktop;
  final Widget mobile;
  final Widget? tablet;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final bool useSafeArea;

  const ResponsiveLayout({
    super.key,
    required this.desktop,
    required this.mobile,
    this.tablet,
    this.backgroundColor,
    this.appBar,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
    this.useSafeArea = true,
  });

  /// Evaluates screen width.
  /// Uses [MediaQuery.sizeOf] to prevent unnecessary rebuilds triggered by non-size
  /// MediaQuery changes (e.g., keyboard opening/closing).
  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppConstants.mobileBreakpoint &&
      MediaQuery.sizeOf(context).width < AppConstants.tabletBreakpoint;

  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= AppConstants.tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    Widget bodyContent = LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        if (maxWidth >= AppConstants.tabletBreakpoint) {
          return desktop;
        } else if (maxWidth >= AppConstants.mobileBreakpoint) {
          return tablet ?? desktop;
        } else {
          return mobile;
        }
      },
    );

    if (useSafeArea) bodyContent = SafeArea(child: bodyContent);

    return Scaffold(
      // backgroundColor: backgroundColor ?? Colors.white,
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      body: bodyContent,
    );
  }
}
