import 'package:family_bazar_admin_panel/src/modules/dashboard/controller/dashboard_coontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/drawer/view/drawer_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint for Desktop vs Mobile Web (Enterprise Standard: 800px)
        final isDesktop = constraints.maxWidth > 800;

        return Scaffold(
          // Mobile Web: Requires an AppBar with a native hamburger menu to open the drawer
          appBar: isDesktop
              ? null
              : AppBar(
                  title: const Text('FamilyBazar Admin', style: TextStyle(fontWeight: FontWeight.w600)),
                  elevation: 2,
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),

          // Mobile Web: The drawer acts as a slide-out overlay
          drawer: isDesktop ? null : const DrawerView(),

          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Desktop Web: The drawer is a permanent, fixed side-panel
                if (isDesktop)
                  const SizedBox(
                    width: 360, // Fixed enterprise standard sidebar width
                    child: DrawerView(),
                  ),

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
    // Defensive UI: Strict switch-case acting as a UI try-catch.
    // Guarantees an unknown key never crashes the layout or causes a red screen of death.
    switch (menuKey.toLowerCase()) {
      case 'dashboard':
        return const Center(
          child: Text('Dashboard Analytics Module Pending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        );

      // Master Categories
      case 'mastercategory':
        return const Center(child: Text('Master Category Module - Coming Soon'));
      case 'mastersubcategory':
        return const Center(child: Text('Master Sub-Category Module - Coming Soon'));
      case 'masterbrandname':
        return const Center(child: Text('Master Brand Module - Coming Soon'));

      // General Categories
      case 'product':
        return const Center(child: Text('Product Management Module - Coming Soon'));
      case 'order':
        return const Center(child: Text('Order Management Module - Coming Soon'));
      case 'customer':
        return const Center(child: Text('Customer Management Module - Coming Soon'));

      default:
        // Zero-Tolerance UI Crash: Fallback for unregistered modules
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
