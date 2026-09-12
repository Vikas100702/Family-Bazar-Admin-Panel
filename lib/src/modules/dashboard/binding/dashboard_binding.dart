import 'package:family_bazar_admin_panel/src/modules/dashboard/controller/dashboard_coontroller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/drawer/binding/drawer_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/binding/firm_setup_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/binding/pincode_settings_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/binding/category_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/dashboard_group/binding/dashboard_group_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/binding/item_binding.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/binding/sub_cat_binding.dart';
import 'package:get/get.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Proactive Memory Management: Lazy load the parent SPA Router
    Get.lazyPut<DashboardController>(
      () => DashboardController(),
      fenix: true, // Ensures it can recreate itself if the admin logs out and logs back in
    );

    DrawerBinding().dependencies();
    FirmBinding().dependencies();
    PincodeSettingsBinding().dependencies();
    CategoryBinding().dependencies();
    SubCategoryBinding().dependencies();
    ItemBinding().dependencies();
    DashboardGroupBinding().dependencies();
  }
}
