import 'package:family_bazar_admin_panel/src/core/base_controller/base_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/model/category_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/repository/category_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CategoryController extends BaseTableController<ViewCategoryDatum> {
  final CategoryRepository _categoryRepository;

  CategoryController({required this._categoryRepository});

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  @override
  String searchTokenBuilder(ViewCategoryDatum item) {
    return '${item.igCode} ${item.igName} ${item.igCmCode} ${item.igType} ${item.igEucode}';
  }

  Future<void> fetchCategories() async {
    await runWithLoading(() async {
      try {
        final response = await _categoryRepository.viewCategories();
        if (isClosed) return;

        if (response.success) {
          setMasterData(response.data);
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch the category list.');
        }
      } catch (e, stackTrace) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('controller', 'CategoryController');
          },
        );
        errorMessage(message: 'An unexpected error occurred while fetching categories.');
      }
    });
  }

  Future<void> refreshCategories() async => fetchCategories();
}
