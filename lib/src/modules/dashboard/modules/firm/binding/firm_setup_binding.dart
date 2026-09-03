import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/controller/firm_setup_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/repository/firm_setup_repository.dart';
import 'package:get/get.dart';

class FirmBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FirmRepository>(() => FirmRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut<FirmController>(() => FirmController(firmRepository: Get.find<FirmRepository>(), storageService: Get.find<StorageService>()));
  }
}
