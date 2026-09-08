import 'package:family_bazar_admin_panel/src/core/const/app_assets.dart';
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
    return ResponsiveLayout(
      desktop: _LoginContent(controller: controller),
      mobile: _LoginContent(controller: controller),
    );
  }
}

class _LoginContent extends StatelessWidget {
  final LoginController controller;

  const _LoginContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(50, 0), vertical: context.responsiveHeight(24, 24)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.responsiveWidth(context.screenWidth * 2.5, 450)),
          child: Container(
            decoration: context.defaultDecoration,
            padding: .symmetric(horizontal: context.responsiveWidth(50, 40), vertical: context.responsiveHeight(24, 24)),
            child: AutofillGroup(
              child: Form(
                key: controller.loginFormKey,
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .stretch,
                  children: [
                    RepaintBoundary(
                      child: Image.asset(
                        AppAssets.appLogo,
                        height: context.responsiveHeight(160, 280),
                        width: context.responsiveWidth(160, 280),
                        fit: BoxFit.contain,
                        semanticLabel: 'Family Bazar Admin Logo',
                      ),
                    ),
                    // SizedBox(height: context.responsiveHeight(16, 12)),
                    Text(AppStrings.adminLogin, style: context.titleStyleActive, textAlign: TextAlign.center),
                    SizedBox(height: context.responsiveHeight(8, 6)),

                    // USERNAME FIELD
                    TextFormField(
                      controller: controller.usernameController,
                      autofillHints: const [AutofillHints.username],
                      decoration: InputDecoration(labelText: AppStrings.username, prefixIcon: const Icon(Icons.person_outline)),
                      validator: (value) => (value == null || value.trim().isEmpty) ? AppStrings.requiredField : null,
                    ),
                    SizedBox(height: context.responsiveHeight(16, 12)),

                    // PASSWORD FIELD
                    Obx(
                      () => TextFormField(
                        controller: controller.passwordController,
                        obscureText: !controller.isPasswordVisible.value,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: AppStrings.password,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty) ? AppStrings.requiredField : null,
                      ),
                    ),
                    SizedBox(height: context.responsiveHeight(16, 20)),

                    // SECURITY DISCLAIMER
                    Text(AppStrings.loginDisclaimer, style: context.subTitleStyle, textAlign: TextAlign.center),
                    SizedBox(height: context.responsiveHeight(32, 40)),

                    // SUBMIT BUTTON
                    ElevatedButton(
                      onPressed: controller.login,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: context.responsiveHeight(16, 20)),
                        shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(12, 8)),
                      ),
                      child: Text(AppStrings.login, style: context.titleStyleActive.copyWith(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
