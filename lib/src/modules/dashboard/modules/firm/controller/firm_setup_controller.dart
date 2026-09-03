import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/model/firm_setup_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/repository/firm_setup_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirmController extends BaseController {
  final FirmRepository _firmRepository;
  final StorageService _storageService;

  // Strict Named Constructor Injection for testability and DI stability
  FirmController({required this._firmRepository, required this._storageService});

  // Reactive state holding firm records for the UI table
  final RxList<Datum> firmList = <Datum>[].obs;

  // Dedicated Web ScrollControllers bound to firm_setup_view.dart
  late final ScrollController horizontalScrollController;
  late final ScrollController verticalScrollController;

  @override
  void onInit() {
    super.onInit();
    horizontalScrollController = ScrollController();
    verticalScrollController = ScrollController();
    fetchFirms();
  }

  /// Fetches the firm list safely through BaseController's runWithLoading
  Future<void> fetchFirms() async {
    await runWithLoading(() async {
      final response = await _firmRepository.viewFirms();

      // Proactive Memory Management: Abort state updates if controller was disposed
      if (isClosed) return;

      if (response.success) {
        firmList.assignAll(response.data);
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch the firm list.');
      }
    });
  }

  /// Explicit reload method for table refresh actions
  Future<void> refreshFirms() async {
    await fetchFirms();
  }

  @override
  void onClose() {
    // Proactive Memory Cleanup: Flush controllers to prevent web heap leaks
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    super.onClose();
  }
}
