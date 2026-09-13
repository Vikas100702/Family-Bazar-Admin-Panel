import 'package:family_bazar_admin_panel/src/core/base_controller/base_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/model/firm_setup_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/repository/firm_setup_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class FirmController extends BaseTableController<Datum> {
  final FirmRepository _firmRepository;

  FirmController({required this._firmRepository});

  @override
  void onInit() {
    super.onInit();
    fetchFirms();
  }

  @override
  String searchTokenBuilder(Datum item) {
    return '${item.fFirmCode} ${item.fFirmName} ${item.fGstNumber} ${item.fLocationCode} ${item.fPinCode}';
  }

  Future<void> fetchFirms() async {
    await runWithLoading(() async {
      try {
        final response = await _firmRepository.viewFirms();
        if (isClosed) return;
        if (response.success) {
          setMasterData(response.data);
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch the firm list from server.');
        }
      } catch (e, stackTrace) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('controller', 'FirmController');
          },
        );
        errorMessage(message: 'An unexpected error occurred while fetching firms.');
      }
    });
  }

  Future<void> refreshFirms() async => fetchFirms();

  @override
  void onClose() {
    Sentry.addBreadcrumb(Breadcrumb(message: 'FirmController Disposed', category: 'firm.controller', level: SentryLevel.info));
    super.onClose();
  }
}
