import 'package:family_bazar_admin_panel/src/modules/dashboard/controller/dashboard_coontroller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/view/firm_setup_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/view/pincode_settings_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/view/category_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/item/view/item_view.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/view/sub_cat_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/drawer/view/drawer_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        return Scaffold(
          appBar: isDesktop
              ? null
              : AppBar(
                  title: const Text('FamilyBazar Admin', style: TextStyle(fontWeight: FontWeight.w600)),
                  elevation: 2,
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),

          drawer: isDesktop ? null : const DrawerView(),

          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop) const SizedBox(width: 360, child: DrawerView()),

                // SPA Dynamic Content Area
                Expanded(
                  // RepaintBoundary isolates the dynamic content.
                  // Switching modules won't trigger repaints on the Sidebar/AppBar.
                  child: RepaintBoundary(
                    child: Obx(() {
                      // Reactive SPA logic: swaps out the right-side widget without page reloads
                      return _buildDynamicContent(controller.selectedMenuKey.value);
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Resolves the currently selected menu key into its respective UI View.
  Widget _buildDynamicContent(String menuKey) {
    switch (menuKey.toLowerCase()) {
      case 'dashboard':
        return const Center(
          child: Text('Dashboard Analytics Module Pending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        );

      // Master Categories
      case 'productcategory':
        return CategoryView();
      case 'productitem':
        return ItemsView();
      case 'productsubcategory':
        return SubCategoryView();
      case 'masterbrandname':
        return const Center(child: Text('Master Brand Module - Coming Soon'));

      // General Categories
      case 'firm setup': // Ensure this matches the exact key sent from your DrawerController
        return const FirmView();
      case 'pin code settings':
        return const PincodeSettingsView();
      case 'order':
        return const Center(child: Text('Order Management Module - Coming Soon'));
      case 'customer':
        return const Center(child: Text('Customer Management Module - Coming Soon'));

      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 64),
              const SizedBox(height: 16),
              Text(
                '404 / Module Unregistered: $menuKey',
                style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Please contact the development team to implement this module.'),
            ],
          ),
        );
    }
  }
}
