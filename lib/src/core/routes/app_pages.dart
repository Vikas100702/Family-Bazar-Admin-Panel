import 'package:family_bazar_admin_panel/src/core/routes/app_routes.dart';
import 'package:family_bazar_admin_panel/src/core/routes/auth_middleware.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/binding/dashboard_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/app_banners/binding/app_banners_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/app_banners/view/app_banners_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/binding/delivery_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/delivery_mgmt/view/delivery_rule_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/misc_charges/binding/misc_charges_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/misc_charges/view/misc_charges_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/time_slot/binding/time_slot_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/cart_mgmt/time_slot/view/time_slot_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/binding/coupon_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/coupon_mgmt/view/coupon_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/binding/customer_details_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/customer/view/customer_details_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/binding/firm_setup_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/view/firm_setup_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/order_mgmt/binding/orders_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/order_mgmt/view/orders_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/binding/pincode_settings_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/view/pincode_settings_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/binding/brand_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/view/brand_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/binding/category_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/view/category_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/binding/dashboard_group_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/view/dashboard_group_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/binding/item_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/view/item_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/binding/sub_cat_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/view/sub_cat_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/settings/app_settings/loyalty_prog/binding/loyalty_prog_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/settings/app_settings/loyalty_prog/view/loyalty_prog_view.dart';
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
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.dashboard,
      binding: DashboardBinding(),
      page: () => const DashboardView(),
      transition: Transition.fadeIn,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.firmSetup,
      page: () => const FirmView(),
      binding: FirmBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.pincodeSettings,
      page: () => const PincodeSettingsView(),
      binding: PincodeSettingsBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.category,
      page: () => const CategoryView(),
      binding: CategoryBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.subCategory,
      page: () => const SubCategoryView(),
      binding: SubCategoryBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.item,
      page: () => const ItemsView(),
      binding: ItemBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.dashboardGroup,
      page: () => const DashboardGroupView(),
      binding: DashboardGroupBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.brands,
      page: () => const BrandView(),
      binding: BrandBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.coupons,
      page: () => const CouponView(),
      binding: CouponBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.delivery,
      page: () => const DeliveryView(),
      binding: DeliveryBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.timeSlot,
      page: () => const TimeSlotView(),
      binding: TimeSlotBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.miscCharges,
      page: () => const MiscChargesView(),
      binding: MiscChargesBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.loyaltyProgram,
      page: () => const LoyaltyProgView(),
      binding: LoyaltyProgBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.appBanners,
      page: () => const AppBannersView(),
      binding: AppBannersBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.customerDetails,
      page: () => const CustomerDetailsView(),
      binding: CustomerDetailsBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.orderDetails,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthMiddleware()],
    ),
  ];
}
