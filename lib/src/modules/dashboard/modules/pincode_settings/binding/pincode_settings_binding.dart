import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/repository/firm_setup_repository.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/controller/pincode_settings_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/pincode_settings/repository/pincode_settings_repository.dart';
import 'package:get/get.dart';

class PincodeSettingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FirmRepository>()) {
      Get.lazyPut<FirmRepository>(() => FirmRepository(apiClient: Get.find<ApiClient>()));
    }
    Get.lazyPut<PincodeSettingsRepository>(() => PincodeSettingsRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut<PincodeSettingsController>(
      () => PincodeSettingsController(
        repository: Get.find<PincodeSettingsRepository>(),
        firmRepository: Get.find<FirmRepository>(),
        storageService: Get.find<StorageService>(),
      ),
    );
  }
}
