import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Web reload helper utilizing modern JS interop and Web standards.
class WebReloadHelper {
  WebReloadHelper._();

  /// Reloads the web application with a unique cache-busting timestamp parameter.
  static void reloadWithCacheBust() {
    if (!kIsWeb) return;

    try {
      final currentHref = web.window.location.href;
      final currentUri = Uri.parse(currentHref);

      final queryParameters = Map<String, String>.from(currentUri.queryParameters);
      queryParameters['cache-bust'] = DateTime.now().millisecondsSinceEpoch.toString();

      final newUri = currentUri.replace(queryParameters: queryParameters);
      web.window.location.href = newUri.toString();
    } catch (error, stackTrace) {
      // Fallback: standard browser reload if URL parsing fails
      try {
        web.window.location.reload();
      } catch (e) {
        debugPrint('Failed to force web reload: $e\n$stackTrace');
      }
    }
  }
}
