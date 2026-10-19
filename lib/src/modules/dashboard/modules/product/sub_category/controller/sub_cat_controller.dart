import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/model/view_sub_category_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/sub_category/repository/sub_category_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SubCategoryController extends BaseServerTableController<ViewSubCategoryDatum> {
  final SubCategoryRepository _subCategoryRepository;
  SubCategoryController({required this._subCategoryRepository});

  bool _isActionLocked = false;

  @override
  void onInit() {
    super.onInit();
    fetchServerData();
  }

  @override
  Future<void> fetchServerData() async {
    await runWithLoading(() async {
      try {
        final ViewSubCategoryModel response = await _subCategoryRepository.viewSubCategories(
          page: currentPage.value,
          limit: itemsPerPage.value,
          searchValue: searchQuery.value,
        );

        if (isClosed) return;

        if (response.success) {
          setServerData(
            data: response.data,
            totalCount: response.pagination?.totalRecords ?? response.data.length,
            pageCount: response.pagination?.totalPages,
          );
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch the sub category list from server.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchServerData', <String, dynamic>{
          'page': currentPage.value,
          'limit': itemsPerPage.value,
          'search': searchQuery.value,
        });
        if (!isClosed) {
          errorMessage(message: 'An unexpected error occurred while fetching sub categories.');
        }
      }
    });
  }

  Future<bool> updateSubCategory({required String ogCode, int? status, String? mImg, String? wImg}) async {
    if (_isActionLocked) return false;
    _isActionLocked = true;

    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final ViewSubCategoryDatum updatedDatum = await _subCategoryRepository.updateSubCategoryDetails(ogCode: ogCode, status: status);

        if (isClosed) return;

        if (updatedDatum.ogCode.isNotEmpty) {
          isSuccess = true;
          successMessage(title: 'Success', message: '${updatedDatum.ogName.isNotEmpty ? updatedDatum.ogName : "Sub Category"} updated successfully.');
          await refreshData();
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'updateSubCategory', <String, dynamic>{'OG_Code': ogCode, 'status': status});
        if (!isClosed) {
          errorMessage(message: 'Failed to update sub category.');
        }
      } finally {
        _isActionLocked = false;
      }
    });

    return isSuccess;
  }

  Future<void> toggleSubCategoryStatus(ViewSubCategoryDatum subCategory, bool newStatus) async {
    await updateSubCategory(ogCode: subCategory.ogCode, status: newStatus ? 1 : 0);
    await refreshData();
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'SubCategoryController error in $action',
        category: 'product.sub_category.controller',
        level: SentryLevel.error,
        data: extra,
      ),
    );

    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('module', 'sub_category');
        scope.setTag('controller', 'SubCategoryController');
        scope.setContexts('sub_category_action', <String, dynamic>{'action': action, 'current_page': currentPage.value, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
