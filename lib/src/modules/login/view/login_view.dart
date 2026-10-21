import 'package:family_bazar_admin_panel/src/core/const/app_assets.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_colors.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_constants.dart';
import 'package:family_bazar_admin_panel/src/core/const/app_strings.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/layout/responsive_layout.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/modules/login/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    return ResponsiveLayout(
      useSafeArea: true,
      backgroundColor: context.isDark ? AppColors.canvasDarkSlate : AppColors.canvasLightGray,
      desktop: isDesktop ? _buildDesktopLayout(context) : const SizedBox.shrink(),
      tablet: !isDesktop ? _buildDesktopLayout(context) : null,
      mobile: !isDesktop ? _buildMobileLayout(context) : const SizedBox.shrink(),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const .symmetric(vertical: 24),
        child: Container(
          width: context.screenWidth * 0.85,
          constraints: const BoxConstraints(maxWidth: AppConstants.maxDesktopContainerWidth, minHeight: AppConstants.minAuthContainerHeight),
          decoration: context.defaultDecoration.copyWith(borderRadius: .circular(16)),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: .stretch,
              children: [
                Expanded(flex: 5, child: _buildBrandHeroSection(context)),
                VerticalDivider(width: 1, thickness: 1, color: context.isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleSlate),
                Expanded(
                  flex: 5,
                  child: Center(
                    child: SingleChildScrollView(padding: const .symmetric(horizontal: 48, vertical: 36), child: _buildLoginForm(context)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: .symmetric(horizontal: 24, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            padding: EdgeInsets.all(context.responsiveSize(20, 32)),
            decoration: context.defaultDecoration,
            child: _buildLoginForm(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeroSection(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      color: isDark ? AppColors.surfaceSubtleSlate : AppColors.surfaceSubtleGray,
      child: Column(
        children: [
          ClipPath(
            clipper: RedHeaderClipper(),
            child: Container(
              width: double.infinity,
              color: AppColors.borderSubtleSlate,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    padding: const EdgeInsets.all(1),
                    decoration: const BoxDecoration(color: AppColors.primaryRed, shape: BoxShape.circle),
                    child: Center(
                      child: Image.asset(
                        AppAssets.appLogo,
                        semanticLabel: 'Family Bazar Logo',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.storefront_rounded, size: 40, color: AppColors.primaryRed),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'GROCERIES FROM THE BEST BRANDS',
                    style: context.titleStyleActive.copyWith(
                      color: AppColors.primaryRed,
                      fontSize: 15,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Delivered to your doorstep',
                    style: context.subTitleStyle.copyWith(
                      color: AppColors.primaryRed.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: RepaintBoundary(
                  child: Image.asset(
                    AppAssets.signInBanner,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.shopping_bag_rounded, size: 96, color: AppColors.primaryRed.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Text(
              'Enterprise Admin Portal for Unified Operations & Inventory Control',
              style: context.subTitleStyle.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final isDark = context.isDark;

    return AutofillGroup(
      child: Form(
        key: controller.loginFormKey,
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            Text(
              'Sign In to Family Bazar',
              style: context.mainHeadingTextStyle.copyWith(fontSize: context.responsiveSize(18, 24)),
              textAlign: .center,
            ),
            SizedBox(height: context.responsiveHeight(6, 6)),
            Text('Enter your credentials to access the panel', style: context.subTitleStyle, textAlign: TextAlign.center),
            SizedBox(height: context.responsiveHeight(24, 32)),
            Text(
              AppStrings.username,
              style: context.titleStyleRegular.copyWith(fontSize: context.responsiveSize(13, 13), fontWeight: FontWeight.w600),
            ),
            SizedBox(height: context.responsiveHeight(8, 8)),
            TextFormField(
              controller: controller.usernameController,
              autofillHints: const [AutofillHints.username, AutofillHints.telephoneNumber],
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              keyboardType: TextInputType.text,
              style: context.bodyTextStyle,
              decoration: InputDecoration(
                hintText: 'Enter username',
                prefixIcon: Icon(Icons.person_outline_rounded, size: context.responsiveSize(20, 20)),
              ),
              validator: controller.validateUsername,
            ),
            SizedBox(height: context.responsiveHeight(16, 20)),
            Text(
              AppStrings.password,
              style: context.titleStyleRegular.copyWith(fontSize: context.responsiveSize(13, 13), fontWeight: FontWeight.w600),
            ),
            SizedBox(height: context.responsiveHeight(8, 8)),
            Obx(
              () => TextFormField(
                controller: controller.passwordController,
                obscureText: !controller.isPasswordVisible.value,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => controller.login(),
                style: context.bodyTextStyle,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock_outline_rounded, size: context.responsiveSize(20, 20)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: context.responsiveSize(20, 20),
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedSlate,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                    mouseCursor: SystemMouseCursors.click,
                    tooltip: controller.isPasswordVisible.value ? 'Hide password' : 'Show password',
                  ),
                ),
                validator: controller.validatePassword,
              ),
            ),
            SizedBox(height: context.responsiveHeight(24, 32)),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.login,
                style: ElevatedButton.styleFrom(
                  enabledMouseCursor: SystemMouseCursors.click,
                  disabledMouseCursor: SystemMouseCursors.basic,
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: AppColors.onPrimaryWhite,
                  disabledBackgroundColor: AppColors.primaryRed.withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(8, 8)),
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        height: context.responsiveSize(20, 20),
                        width: context.responsiveSize(20, 20),
                        child: const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : Text(
                        AppStrings.signIn,
                        style: TextStyle(fontSize: context.responsiveSize(15, 15), fontWeight: FontWeight.w600, letterSpacing: 0.3),
                      ),
              ),
            ),
            SizedBox(height: context.responsiveHeight(18, 22)),
            Text('${AppStrings.appName} • ${AppStrings.appVersion}', style: context.captionStyle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class RedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    // Left to Right smooth bottom curve
    final controlPoint = Offset(size.width / 2, size.height + 25);
    final endPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
