import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/model/category_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/repository/category_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CategoryController extends BaseServerTableController<ViewCategoryDatum> {
  final CategoryRepository _categoryRepository;
  CategoryController({required this._categoryRepository});

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
        final ViewCategoryModel response = await _categoryRepository.viewCategories(
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
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch the category list from server.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchServerData', <String, dynamic>{
          'page': currentPage.value,
          'limit': itemsPerPage.value,
          'search': searchQuery.value,
        });
        if (!isClosed) {
          errorMessage(message: 'An unexpected error occurred while fetching categories.');
        }
      }
    });
  }

  Future<bool> updateCategory({required String igCode, int? status, String? mImg, String? wImg}) async {
    if (_isActionLocked) return false;
    _isActionLocked = true;

    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final ViewCategoryDatum updatedDatum = await _categoryRepository.updateCategoryDetails(catCode: igCode, status: status);

        if (isClosed) return;

        if (updatedDatum.igCode.isNotEmpty) {
          isSuccess = true;
          successMessage(title: 'Success', message: '${updatedDatum.igName.isNotEmpty ? updatedDatum.igName : "Category"} updated successfully.');
          await refreshData();
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'updateCategory', <String, dynamic>{'IG_Code': igCode, 'status': status});
        if (!isClosed) {
          errorMessage(message: 'Failed to update category.');
        }
      } finally {
        _isActionLocked = false;
      }
    });

    return isSuccess;
  }

  Future<void> toggleCategoryStatus(ViewCategoryDatum category, bool newStatus) async {
    await updateCategory(igCode: category.igCode, status: newStatus ? 1 : 0);
    refreshData();
  }

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.addBreadcrumb(
      Breadcrumb(message: 'CategoryController error in $action', category: 'product.category.controller', level: SentryLevel.error, data: extra),
    );

    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('module', 'category');
        scope.setTag('controller', 'CategoryController');
        scope.setContexts('category_action', <String, dynamic>{'action': action, 'current_page': currentPage.value, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
