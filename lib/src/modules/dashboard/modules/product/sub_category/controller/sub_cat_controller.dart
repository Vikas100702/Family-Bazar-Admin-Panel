import 'package:family_bazar_admin_panel/src/core/base_controller/base_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/model/view_sub_category_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/repository/sub_category_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SubCategoryController extends BaseTableController<ViewSubCategoryDatum> {
  final SubCategoryRepository _subCategoryRepository;

  SubCategoryController({required this._subCategoryRepository});

  @override
  void onInit() {
    super.onInit();
    fetchSubCategories();
  }

  @override
  String searchTokenBuilder(ViewSubCategoryDatum item) {
    return '${item.ogCode} ${item.ogName} ${item.ogScCode} ${item.ogEucode}';
  }

  Future<void> fetchSubCategories() async {
    await runWithLoading(() async {
      try {
        final response = await _subCategoryRepository.viewSubCategories();
        if (isClosed) return;

        if (response.success) {
          setMasterData(response.data);
        } else {
          errorMessage(message: response.message.isNotEmpty ? response.message : 'Failed to fetch the sub category list.');
        }
      } catch (e, stackTrace) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('controller', 'SubCategoryController');
          },
        );
        errorMessage(message: 'An unexpected error occurred while fetching sub categories.');
      }
    });
  }

  Future<void> refreshCategories() async => fetchSubCategories();
}
