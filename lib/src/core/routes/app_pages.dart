import 'package:family_bazar_admin_panel/src/core/routes/app_routes.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/binding/dashboard_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/binding/firm_setup_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/view/firm_setup_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/binding/pincode_settings_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/view/pincode_settings_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/binding/category_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/view/category_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/view/dashboard_view.dart';
import 'package:family_bazar_admin_panel/src/modules/login/binding/login_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/login/view/login_view.dart';
import 'package:family_bazar_admin_panel/src/modules/splash/binding/splash_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/splash/splash_view.dart';
import 'package:get/get.dart';

class AppPages {
  AppPages._();

  static const String initial = AppRoutes.category;
  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(name: AppRoutes.login, page: () => const LoginView(), binding: LoginBinding(), transition: Transition.noTransition),
    GetPage(name: AppRoutes.dashboard, binding: DashboardBinding(), page: () => const DashboardView(), transition: Transition.fadeIn),
    GetPage(name: AppRoutes.firmSetup, page: () => const FirmView(), binding: FirmBinding(), transition: Transition.noTransition),
    GetPage(
      name: AppRoutes.pincodeSettings,
      page: () => const PincodeSettingsView(),
      binding: PincodeSettingsBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(name: AppRoutes.category, page: () => const CategoryView(), binding: CategoryBinding(), transition: Transition.noTransition),
  ];
}
