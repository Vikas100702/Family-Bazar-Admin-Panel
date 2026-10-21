import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/repository/firm_setup_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/controller/pincode_settings_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/repository/pincode_settings_repository.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class PincodeSettingsBinding extends Bindings {
  @override
  void dependencies() {
    try {
      final ApiClient apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put<ApiClient>(ApiClient(), permanent: true);

      final StorageService storageService = Get.isRegistered<StorageService>()
          ? Get.find<StorageService>()
          : Get.put<StorageService>(StorageService(), permanent: true);

      if (!Get.isRegistered<FirmRepository>()) {
        Get.lazyPut<FirmRepository>(() => FirmRepository(apiClient: apiClient), fenix: true);
      }

      Get.lazyPut<PincodeSettingsRepository>(() => PincodeSettingsRepository(apiClient: apiClient), fenix: true);

      Get.lazyPut<PincodeSettingsController>(
            () =>
            PincodeSettingsController(
              repository: Get.find<PincodeSettingsRepository>(),
              firmRepository: Get.find<FirmRepository>(),
              storageService: storageService,
            ),
        fenix: true,
      );
    } catch (e, stackTrace) {
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (Scope scope) {
          scope.setTag('layer', 'PincodeSettingsBinding');
          scope.setTag('module', 'pincode_settings');
        },
      );
      rethrow;
    }
  }
}
