import 'package:family_bazar_admin_panel/src/core/const/app_assets.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/layout/responsive_layout.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/splash/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      desktop: _SplashContent(logoSize: 300.0),
      tablet: _SplashContent(logoSize: 220.0),
      mobile: _SplashContent(logoSize: 180.0),
    );
  }
}

class _SplashContent extends StatelessWidget {
  final double logoSize;
  const _SplashContent({required this.logoSize});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RepaintBoundary(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Image.asset(
              AppAssets.appLogo,
              width: context.responsiveWidth(logoSize, logoSize),
              height: context.responsiveHeight(logoSize, logoSize),
              fit: BoxFit.contain,
              semanticLabel: 'Family Bazar Admin Logo',
            ),
            const SizedBox(height: 32.0),
            const CircularProgressIndicator(strokeWidth: 3.0),
          ],
        ),
      ),
    );
  }
}
