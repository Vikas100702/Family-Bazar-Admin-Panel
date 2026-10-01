import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/model/view_sub_category_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/repository/sub_category_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SubCategoryController extends BaseServerTableController<ViewSubCategoryDatum> {
  final SubCategoryRepository _subCategoryRepository;

  SubCategoryController({required this._subCategoryRepository});

  @override
  void onInit() {
    super.onInit();
    fetchServerData();
  }

  @override
  Future<void> fetchServerData() async {
    await runWithLoading(() async {
      try {
        final response = await _subCategoryRepository.viewSubCategories(
          page: currentPage.value,
          limit: itemsPerPage.value,
          searchValue: searchQuery.value,
        );
        if (isClosed) return;

        if (response.success) {
          setServerData(data: response.data, totalCount: response.pagination?.totalRecords ?? 0, pageCount: response.pagination?.totalPages);
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch the sub category list from server.');
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

  Future<bool> updateSubCategory({required String ogCode, int? status, String? mImg, String? wImg}) async {
    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        await _subCategoryRepository.updateSubCategoryDetails(ogCode: ogCode, status: status);
        isSuccess = true;
        // Unconditional refresh call after successful API hit
        await refreshSubCategories();
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'updateCategory', {'OG_Code': ogCode});
        errorMessage(message: 'Failed to update category');
      }
    });
    return isSuccess;
  }

  Future<void> toggleSubCategoryStatus(ViewSubCategoryDatum subCategory, bool newStatus) async {
    await updateSubCategory(ogCode: subCategory.ogCode, status: newStatus ? 1 : 0);
  }

  Future<void> refreshSubCategories() async => fetchServerData();

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.addBreadcrumb(
      Breadcrumb(message: 'SubCategoryController error in $action', category: 'subCategory.controller', level: SentryLevel.error, data: extra),
    );

    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('controller', 'SubCategoryController');
        scope.setContexts('subCategory_action', {'action': action, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
