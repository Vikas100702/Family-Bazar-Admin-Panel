import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class StorageService extends GetxService {
  GetStorage get _box => GetStorage();

  Future<StorageService> init() async {
    try {
      await GetStorage.init();
      Sentry.addBreadcrumb(Breadcrumb(message: 'Local Storage Initialized Successfully', category: 'storage.init', level: SentryLevel.info));
      return this;
    } catch (e, stackTrace) {
      Sentry.captureException(
        Exception('[CRITICAL]: GetStorage Init Failed (Storage Blocked/Restricted) - $e'),
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('layer', 'storage_service');
          scope.setTag('platform', kIsWeb ? 'web' : 'native');
        },
      );
      debugPrint('--- [CRITICAL] GetStorage Init Failed ---');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      throw Exception('Failed to initialize local storage via GetStorage.');
    }
  }

  /// Global Storage Error Logger
  void _logStorageError(String operation, String key, Object error, StackTrace stackTrace) {
    Sentry.captureException(
      Exception('Storage operation $operation Failed on key: $key - $error'),
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setTag('layer', 'storage_service');
        scope.setTag('storage_operation', operation);
        scope.setContexts('storage_meta', {'key': key});
      },
    );
    debugPrint('--- [STORAGE EXCEPTION] Operation: $operation | Key: $key ---');
    debugPrint(error.toString());
    debugPrint(stackTrace.toString());
  }

  /// Centralized read logic
  T? _readData<T>(String key) {
    try {
      return _box.read<T>(key);
    } catch (e, stackTrace) {
      _logStorageError('read<$T>', key, e, stackTrace);
      return null;
    }
  }

  /// Centralized write logic
  Future<bool> _writeData(String key, dynamic value) async {
    if (value == null) {
      await _box.remove(key);
      return true;
    }
    try {
      await _box.write(key, value);
      return true;
    } catch (e, stackTrace) {
      _logStorageError('write', key, e, stackTrace);
      return false;
    }
  }

  /// SETTERS
  Future<bool> setString(String key, String value) async => _writeData(key, value);
  Future<bool> setBool(String key, bool value) async => _writeData(key, value);
  Future<bool> setInt(String key, int value) async => _writeData(key, value);
  Future<bool> setDouble(String key, double value) async => _writeData(key, value);
  Future<bool> setDynamic(String key, dynamic value) async => _writeData(key, value);

  /// GETTERS
  String? getString(String key) => _readData<String>(key);
  bool? getBool(String key) => _readData<bool>(key);
  int? getInt(String key) => _readData<int>(key);
  double? getDouble(String key) => _readData<double>(key);
  dynamic getDynamic(String key) => _readData<dynamic>(key);

  /// CHECK IF KEY EXISTS IN STORAGE
  bool hasData(String key) {
    try {
      return _box.hasData(key);
    } catch (e, stackTrace) {
      _logStorageError('hasData', key, e, stackTrace);
      return false;
    }
  }

  /// Explicit key removal
  Future<bool> removeKey(String key) async {
    try {
      await _box.remove(key);
      return true;
    } catch (e, stackTrace) {
      _logStorageError('removeKey', key, e, stackTrace);
      return false;
    }
  }

  /// Clear All Data (Session wipe)
  Future<bool> clearAll() async {
    try {
      await _box.erase();
      Sentry.addBreadcrumb(Breadcrumb(message: 'Local Storage Wiped (Session Cleared)', category: 'auth.session', level: SentryLevel.warning));
      return true;
    } catch (e, stackTrace) {
      _logStorageError('clearAll', 'ALL_KEYS', e, stackTrace);
      debugPrint('--- [STORAGE EXCEPTION] Operation: clearAll ---');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      return false;
    }
  }
}
