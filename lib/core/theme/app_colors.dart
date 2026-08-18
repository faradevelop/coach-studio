import 'package:flutter/material.dart';

class AppColors {
  // ── Primary (CTA only) ───────────────────────────────────
  static const Color orange = Color(0xFFFF7A00);
  static const Color orangeDark = Color(0xFFFF5B00);
  static const Color orangeSoft = Color(0xFFFFF0E8);
  static const Color orangeGlow = Color(0xFFFF9A5A);

  // ── Secondary (new) ──────────────────────────────────────
  static const Color teal = Color(0xFF2A9D8F);
  static const Color tealDark = Color(0xFF1F7A6F);
  static const Color tealSoft = Color(0xFFE6F5F2);
  static const Color tealMuted = Color(0xFF5BB8AA);

  // ── Neutrals ─────────────────────────────────────────────
  static const Color charcoal = Color(0xFF1C1C1E);
  static const Color charcoalSoft = Color(0xFF2C2C2E);
  static const Color cream = Color(0xFFF7F3EE);
  static const Color dirtyCream = Color(0xFFE9DED4);
  static const Color grey = Color(0xFFD7CFC8);
  static const Color muted = Color(0xFF8A8178);

  // ── Glass / Surface helpers ──────────────────────────────
  static Color get glass => Colors.white.withValues(alpha: 0.55);
  static Color get glassStrong => Colors.white.withValues(alpha: 0.72);
  static Color get glassBorder => Colors.white.withValues(alpha: 0.45);
  static Color get glassBorderSoft => Colors.white.withValues(alpha: 0.28);

  static Color get surfaceGlass => dirtyCream.withValues(alpha: 0.40);
  static Color get surfaceGlassBorder => dirtyCream.withValues(alpha: 0.55);

  // ── Semantic ─────────────────────────────────────────────
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color onOrange = Colors.white;
  static const Color onTeal = Colors.white;
  static const Color onCharcoal = Colors.white;

  // ── Background gradient stops (used in ScaffoldWithBottomNav) ──
  static const Color bgStart = Color(0xFFF8F4EE);
  static const Color bgMid = Color(0xFFF5F0E8);
  static const Color bgEnd = Color(0xFFF2ECE5);

  static const List<Color> bgColors = [Color(0xFFfdf1e3), Color(0xFFfbf2e3)];
  static const List<double> bgStops = [0.0, 1.0];
}
