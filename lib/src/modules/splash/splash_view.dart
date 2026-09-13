import 'package:family_bazar_admin_panel/src/core/const/app_assets.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/layout/responsive_layout.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/splash/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    controller; // Explicitly touches GetView getter to trigger Get.lazyPut instantiation & fire onInit()
    return ResponsiveLayout(
      mobile: const _SplashContent(logoSize: 150.0),
      tablet: const _SplashContent(logoSize: 180.0),
      desktop: const _SplashContent(logoSize: 220.0),
    );
  }
}

class _SplashContent extends StatelessWidget {
  final double logoSize;

  const _SplashContent({required this.logoSize});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            RepaintBoundary(
              child: Image.asset(
                AppAssets.appLogo,
                width: logoSize,
                height: logoSize,
                fit: .contain,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.storefront_rounded, size: logoSize * 0.5, color: AppColors.primaryRed),
              ),
            ),
            SizedBox(height: context.responsiveHeight(24, 32)),
            RepaintBoundary(
              child: SizedBox(
                width: logoSize * 0.8,
                height: 3.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.0),
                  child: LinearProgressIndicator(
                    semanticsLabel: 'Initializing Application',
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                    backgroundColor: AppColors.primaryRed.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
