import 'package:flutter/material.dart';

/// Coach Studio colour tokens (Design System v1.0).
///
/// Semantic names only — use these everywhere. Neutral surfaces are flat;
/// the only translucent "glass" element left in the app is the floating
/// bottom navigation, which draws its own tint.
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────
  static const Color primary = Color(0xFF5B5CE2); // Indigo — CTA, active
  static const Color primaryDark = Color(0xFF4546B8); // pressed / gradients
  static const Color primaryLight = Color(0xFF8F90EE); // derived: glow/hover
  static const Color primarySoft = Color(0xFFEFEFFC); // primary @ ~10% on white
  static const Color onPrimary = Colors.white;

  static const Color secondary = Color(0xFF42C7A5); // Mint — focus, outline btn
  static const Color secondaryDark = Color(0xFF2FA286); // derived: text/icons
  static const Color secondaryLight = Color(0xFFA7E9D9); // gradient end
  static const Color secondarySoft = Color(0xFFE8F8F4); // secondary @ ~12%
  static const Color onSecondary = Colors.white;

  static const Color accent = Color(0xFFFF9478); // Coral — sparse highlights
  static const Color accentSoft = Color(0xFFFFEFEA); // derived
  static const Color onAccent = Colors.white;

  // ── Neutrals ─────────────────────────────────────────────
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(
    0xFFEEF0F7,
  ); // derived: subtle fills
  static const Color outline = Color(0xFFE7E9F0);
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF74798C);
  static const Color disabled = Color(0xFFC7C9E8);

  // ── Semantic states ──────────────────────────────────────
  static const Color success = Color(0xFF34D399);
  static const Color info = primary;
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF6B6B);
  static const Color onError = Colors.white;

  // Readable foregrounds for tinted status chips (derived).
  static const Color successDark = Color(0xFF168F63);
  static const Color warningDark = Color(0xFFB86F08);
  static const Color errorDark = Color(0xFFD64545);

  // ── Gradients & effects ──────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, secondary],
  );
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [secondary, secondaryLight],
  );

  /// Decorative background blur tint (primary @ 10%).
  static const Color backgroundBlur = Color(0x1A5B5CE2);

  // ── Soft tints for status chips ──────────────────────────
  static Color get successSoft => success.withValues(alpha: 0.14);
  static Color get infoSoft => info.withValues(alpha: 0.12);
  static Color get warningSoft => warning.withValues(alpha: 0.16);
  static Color get errorSoft => error.withValues(alpha: 0.12);
}
