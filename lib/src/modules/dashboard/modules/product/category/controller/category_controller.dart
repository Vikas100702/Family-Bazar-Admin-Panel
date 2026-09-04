import 'package:family_bazar_admin_panel/src/core/base_controller/base_controller.dart';
import 'package:family_bazar_admin_panel/src/core/utils/storage/storage_services.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/model/category_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/repository/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryController extends BaseController {
  final CategoryRepository _categoryRepository;
  final StorageService _storageService;

  // Strict Named Constructor Injection for testability and DI stability
  CategoryController({required this._categoryRepository, required this._storageService});

  // Reactive state holding firm records for the UI table
  final RxList<ViewCategoryDatum> categoryList = <ViewCategoryDatum>[].obs;

  // Dedicated Web ScrollControllers bound to firm_setup_view.dart
  late final ScrollController horizontalScrollController;
  late final ScrollController verticalScrollController;

  @override
  void onInit() {
    super.onInit();
    horizontalScrollController = ScrollController();
    verticalScrollController = ScrollController();
    fetchCategories();
  }

  /// Fetches the firm list safely through BaseController's runWithLoading
  Future<void> fetchCategories() async {
    await runWithLoading(() async {
      final response = await _categoryRepository.viewCategories();

      // Proactive Memory Management: Abort state updates if controller was disposed
      if (isClosed) return;

      if (response.success) {
        categoryList.assignAll(response.data);
      } else {
        errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch the category list.');
      }
    });
  }

  /// Explicit reload method for table refresh actions
  Future<void> refreshCategories() async {
    await fetchCategories();
  }

  @override
  void onClose() {
    // Proactive Memory Cleanup: Flush controllers to prevent web heap leaks
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    super.onClose();
  }
}
