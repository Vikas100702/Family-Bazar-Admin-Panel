import 'package:family_bazar_admin_panel/src/core/base_controller/base_table_controller.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/model/firm_setup_model.dart';
import 'package:family_bazar_admin_panel/src/modules/dashboard/modules/firm/repository/firm_setup_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class FirmController extends BaseTableController<ViewFirmDatum> {
  final FirmRepository _firmRepository;
  FirmController({required this._firmRepository});

  bool _isActionLocked = false;

  @override
  void onInit() {
    super.onInit();
    fetchFirms();
  }

  @override
  String searchTokenBuilder(ViewFirmDatum item) {
    return '${item.fFirmCode} ${item.fFirmName} ${item.fGstNumber} ${item.fCity} ${item.fPinCode}'.toLowerCase().trim();
  }

  Future<void> fetchFirms() async {
    if (_isActionLocked) return;
    _isActionLocked = true;

    await runWithLoading(() async {
      try {
        final ViewFirmModel response = await _firmRepository.viewFirms();

        if (isClosed) return;

        if (response.success) {
          setMasterData(response.data);
        } else {
          throw Exception(response.message.isNotEmpty ? response.message : 'Failed to fetch the firm list from server.');
        }
      } catch (e, stackTrace) {
        _logException(e, stackTrace, 'fetchFirms');
        if (!isClosed) {
          errorMessage(message: 'An unexpected error occurred while fetching firms.');
        }
      } finally {
        _isActionLocked = false;
      }
    });
  }

  Future<void> refreshFirms() async => fetchFirms();

  void _logException(dynamic exception, StackTrace stackTrace, String action, [Map<String, dynamic>? extra]) {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (Scope scope) {
        scope.setTag('controller', 'FirmController');
        scope.setTag('module', 'firm');
        scope.setContexts('firm_action', <String, dynamic>{'action': action, ...?extra});
      },
    );
  }

  @override
  void onClose() {
    Sentry.addBreadcrumb(Breadcrumb(message: 'FirmController Disposed', category: 'firm.controller', level: SentryLevel.info));
    super.onClose();
  }
}
