import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/controller/image_upload_controller.dart';
import 'package:family_bazar_admin_panel/src/core/global_components/component/image_upload/repository/image_upload_repository.dart';
import 'package:family_bazar_admin_panel/src/core/network/api_client.dart';
import 'package:get/get.dart';

class ImageUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageUploadRepository>(() => ImageUploadRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut<ImageUploadController>(() => ImageUploadController(imageUploadRepository: Get.find<ImageUploadRepository>()));
  }
}
