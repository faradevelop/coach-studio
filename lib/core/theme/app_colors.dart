import 'package:flutter/material.dart';

/// Coach Studio color tokens (Design System v2.0).
///
/// Roles follow the reference board:
///  * primary   — Orange: energy, actions, CTAs, active navigation
///  * accent    — Indigo: trust, structure, secondary CTAs, links
///  * secondary — Teal: success, progress, focus, status
///
/// Always use these semantic names — never hard-code colors in pages.
class AppColors {
  AppColors._();

  // ── Brand: Orange (primary) ──────────────────────────────
  static const Color primary = Color(0xFFFF8A3D);
  static const Color primaryDark = Color(0xFFD35A0B); // pressed / text on soft
  static const Color primaryLight = Color(0xFFFFB074); // gradient start / glow
  static const Color primarySoft = Color(0xFFFFF1E6); // primary @ ~12%
  static const Color onPrimary = Colors.white;

  // ── Brand: Teal (secondary) ──────────────────────────────
  static const Color secondary = Color(0xFF14B8A6);
  static const Color secondaryDark = Color(0xFF0D9488);
  static const Color secondaryLight = Color(0xFF5EEAD4);
  static const Color secondarySoft = Color(0xFFE6F8F5);
  static const Color onSecondary = Colors.white;

  // ── Brand: Indigo (accent) ───────────────────────────────
  static const Color accent = Color(0xFF4338CA);
  static const Color accentDark = Color(0xFF3730A3);
  static const Color accentLight = Color(0xFF6C63F0);
  static const Color accentSoft = Color(0xFFEEEFFD);
  static const Color onAccent = Colors.white;

  // ── Neutrals ─────────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color outline = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color disabled = Color(0xFFCBD5E1);

  // ── Semantic states ──────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color info = accent;
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Colors.white;

  static const Color successDark = Color(0xFF047857);
  static const Color infoDark = accentDark;
  static const Color warningDark = Color(0xFFB45309);
  static const Color errorDark = Color(0xFFB91C1C);

  // ── Glass (use sparingly: floating cards, nav, highlights) ─
  static const Color glassHighlight = Color(0xE6FFFFFF); // ~90% white
  static const Color glassFill = Color(0xB3FFFFFF); // ~70% white
  static const Color glassBorder = Color(0xCCFFFFFF);

  // ── Gradients ────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryLight, primary],
  );
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [accentLight, accent],
  );
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [secondaryDark, secondaryLight],
  );

  /// Decorative background tint (primary @ 10%).
  static const Color backgroundBlur = Color(0x1AFF8A3D);

  // ── Soft tints for status chips ──────────────────────────
  static Color get successSoft => success.withValues(alpha: 0.14);
  static Color get infoSoft => info.withValues(alpha: 0.12);
  static Color get warningSoft => warning.withValues(alpha: 0.16);
  static Color get errorSoft => error.withValues(alpha: 0.12);
}
