import 'package:family_bazar_admin_panel/src/core/routes/app_routes.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/binding/dashboard_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/view/dashboard_view.dart';
import 'package:family_bazar_admin_panel/src/modules/login/binding/login_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/login/view/login_view.dart';
import 'package:family_bazar_admin_panel/src/modules/splash/binding/splash_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/splash/splash_view.dart';
import 'package:get/get.dart';

class AppPages {
  AppPages._();
  static const String initial = AppRoutes.splash;
  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(name: AppRoutes.login, page: () => const LoginView(), binding: LoginBinding(), transition: Transition.noTransition),
    GetPage(
      name: AppRoutes.dashboard,
      binding: DashboardBinding(),
      page: () => const DashboardView(),
      transition: Transition.fadeIn,
    ),
  ];
}
