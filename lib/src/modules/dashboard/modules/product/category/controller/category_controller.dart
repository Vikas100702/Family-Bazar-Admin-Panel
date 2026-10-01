import 'package:family_bazar_admin_panel/src/core/base_controller/base_server_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/model/category_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/category/repository/category_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CategoryController extends BaseServerTableController<ViewCategoryDatum> {
  final CategoryRepository _categoryRepository;
  CategoryController({required this._categoryRepository});

  @override
  void onInit() {
    super.onInit();
    fetchServerData();
  }

  @override
  Future<void> fetchServerData() async {
    await runWithLoading(() async {
      try {
        final response = await _categoryRepository.viewCategories(page: currentPage.value, limit: itemsPerPage.value, searchValue: searchQuery.value);
        if (isClosed) return;

        if (response.success) {
          setServerData(data: response.data, totalCount: response.pagination?.totalRecords ?? 0, pageCount: response.pagination?.totalPages);
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch the category list from server.');
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

  Future<bool> updateCategory({required String igCode, int? status, String? mImg, String? wImg}) async {
    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        await _categoryRepository.updateCategoryDetails(catCode: igCode, status: status);
        isSuccess = true;
        // Unconditional refresh call after successful API hit
        await refreshCategories();
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'updateCategory', {'IG_CODE': igCode});
        errorMessage(message: 'Failed to update category');
      }
    });
    return isSuccess;
  }

  Future<void> toggleCategoryStatus(ViewCategoryDatum category, bool newStatus) async {
    await updateCategory(igCode: category.igCode, status: newStatus ? 1 : 0);
  }

  Future<void> refreshCategories() async => fetchServerData();

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.addBreadcrumb(
      Breadcrumb(message: 'CategoryController error in $action', category: 'category.controller', level: SentryLevel.error, data: extra),
    );

    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('controller', 'CategoryController');
        scope.setContexts('category_action', {'action': action, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
