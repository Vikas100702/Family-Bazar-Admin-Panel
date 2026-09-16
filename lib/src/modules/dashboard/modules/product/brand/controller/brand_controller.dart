import 'package:family_bazar_admin_panel/src/core/base_controller/base_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/model/view_brand_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/product/brand/repository/brand_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class BrandController extends BaseTableController<ViewBrandDatum> {
  final BrandRepository _brandRepository;

  BrandController({required this._brandRepository});

  @override
  void onInit() {
    super.onInit();
    fetchBrands();
  }

  @override
  String searchTokenBuilder(ViewBrandDatum brand) {
    return '${brand.mcCompCode} ${brand.mcCompName}';
  }

  Future<void> fetchBrands() async {
    await runWithLoading(() async {
      try {
        final response = await _brandRepository.viewBrands();
        if (isClosed) return;

        if (response.success) {
          setMasterData(response.data);
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch the brand list from server.');
        }
      } catch (e, stackTrace) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('controller', 'BrandController');
          },
        );
        errorMessage(message: 'An unexpected error occurred while fetching brands.');
      }
    });
  }

  Future<bool> updateBrand({required String mcCompCode, int? featuredBrand, int? status, String? mImg, String? wImg}) async {
    bool isSuccess = false;
    await runWithLoading(() async {
      try {
        final updatedDatum = await _brandRepository.updateBrand(
          mcCompCode: mcCompCode,
          featuredBrand: featuredBrand,
          status: status,
          mImg: mImg,
          wImg: wImg,
        );

        if (updatedDatum.mcCompCode.isNotEmpty) {
          isSuccess = true;
          successMessage(title: 'Success', message: '${updatedDatum.mcCompName} updated successfully');
          await fetchBrands();
        }
      } catch (e) {
        errorMessage(message: 'Failed to update brand');
      }
    });
    return isSuccess;
  }

  Future<void> toggleBrandStatus(ViewBrandDatum brand, bool newStatus) async {
    await updateBrand(mcCompCode: brand.mcCompCode, status: newStatus ? 1 : 0);
  }

  Future<void> toggleBrandFeatured(ViewBrandDatum brand, bool newFeatured) async {
    await updateBrand(mcCompCode: brand.mcCompCode, featuredBrand: newFeatured ? 1 : 0);
  }

  Future<void> refreshBrands() async => fetchBrands();

  @override
  void onClose() {
    super.onClose();
  }
}
