import 'package:family_bazar_admin_panel/src/core/global_components/layout/responsive_layout.dart';
import 'package:family_bazar_admin_panel/src/core/routes/app_routes.dart';
import 'package:family_bazar_admin_panel/src/core/utils/extensions/style_extensions.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ComingSoonView extends StatelessWidget {
  final String title;

  const ComingSoonView({super.key, this.title = 'Dashboard'});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktop: _ComingSoonContent(title: title),
      mobile: _ComingSoonContent(title: title),
    );
  }
}

class _ComingSoonContent extends StatelessWidget {
  final String title;

  const _ComingSoonContent({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.responsiveSize(24, 16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(context.responsiveSize(24, 16)),
              decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
              child: Icon(Icons.construction_rounded, size: context.responsiveSize(64, 48), color: Colors.orange.shade800),
            ),
            SizedBox(height: context.responsiveHeight(24, 16)),
            Text(
              '$title - Coming Soon',
              style: context.titleStyleActive, // Rule Maintained
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveHeight(8, 6)),
            Text(
              'This feature is under development. It will be live soon!',
              style: context.subTitleStyle, // Rule Maintained
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveHeight(32, 24)),
            ElevatedButton.icon(
              onPressed: () async {
                final storage = Get.find<StorageService>();
                await storage.clearAll();
                Get.offAllNamed(AppRoutes.login);
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Back to Login'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(24, 16), vertical: context.responsiveHeight(16, 12)),
                shape: RoundedRectangleBorder(borderRadius: context.responsiveRadius(12, 8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
