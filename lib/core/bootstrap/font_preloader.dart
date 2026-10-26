// lib/core/bootstrap/font_preloader.dart
import 'package:flutter/services.dart';
import 'package:coach_studio/core/logger/app_logger.dart';

/// Verifies that every declared font asset exists in the bundle and warms
/// the asset cache. Missing/misnamed files fail LOUDLY at startup instead
/// of silently falling back to a different font.
Future<void> verifyFontAssets(AppLogger logger) async {
  const files = <String>[
    'assets/fonts/Estedad_Light.ttf',
    'assets/fonts/Estedad_Regular.ttf',
    'assets/fonts/Estedad_Medium.ttf',
    'assets/fonts/Estedad_Bold.ttf',
  ];

  for (final path in files) {
    try {
      final data = await rootBundle.load(path);
      logger.info('Font OK: $path (${data.lengthInBytes} bytes)');
      if (data.lengthInBytes < 1024) {
        logger.error('Font file suspiciously small: $path');
      }
    } catch (e) {
      logger.error('Font asset MISSING or unreadable: $path', error: e);
    }
  }
}
