import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/core/utils/device/device_meta_service.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/login/controller/login_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/login/repository/login_repository.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Track dependency injection pipeline
    Sentry.addBreadcrumb(Breadcrumb(message: 'Initializing LoginBinding dependencies', category: 'binding.init', level: SentryLevel.info));

    //  Memory Management: Lazy Controller Instantiation
    Get.lazyPut<LoginRepository>(() => LoginRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut<LoginController>(
      () => LoginController(
        loginRepository: Get.find<LoginRepository>(),
        storageService: Get.find<StorageService>(),
        deviceMetaService: DeviceMetaService(Get.find<ApiClient>().externalDio),
      ),
    );
  }
}
