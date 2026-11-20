import 'package:material_ui/material_ui.dart';

// ═════════════════════════════════════════════════════════════════════════
// Layer 1 — Raw palette
// ═════════════════════════════════════════════════════════════════════════

/// Raw tonal scales. Every literal hex in the color system lives HERE and
/// nowhere else. UI code must never use this class directly — use
/// [AppColors] (or [AppDarkColors]) semantic tokens instead.
///
/// Scale convention: 50 (lightest) → 900 (darkest).
/// Brand anchors: orange500, navy800, sky400.
abstract final class AppPalette {
  AppPalette._();

  // ── Orange — brand primary (#F47738 = 500) ──────────────────────────
  static const Color orange50 = Color(0xFFFFF3EB);
  static const Color orange100 = Color(0xFFFFE5D3);
  static const Color orange200 = Color(0xFFFFCBA8);
  static const Color orange300 = Color(0xFFFBA97C);
  static const Color orange400 = Color(0xFFF8945C);
  static const Color orange500 = Color(0xFFF47738); // BRAND
  static const Color orange600 = Color(0xFFDE621F);
  static const Color orange700 = Color(0xFFBE4D16);
  static const Color orange800 = Color(0xFF94390F);
  static const Color orange900 = Color(0xFF6B280A);

  // ── Navy — brand secondary (#202B3C = 800) ──────────────────────────
  static const Color navy50 = Color(0xFFEDF1F6);
  static const Color navy100 = Color(0xFFDDE3EC);
  static const Color navy200 = Color(0xFFC0CAD8);
  static const Color navy300 = Color(0xFFA0ACBD);
  static const Color navy400 = Color(0xFF74839A);
  static const Color navy500 = Color(0xFF51617A);
  static const Color navy600 = Color(0xFF3A4A62);
  static const Color navy700 = Color(0xFF2B384C);
  static const Color navy800 = Color(0xFF202B3C); // BRAND
  static const Color navy900 = Color(0xFF141B27);
  static const Color navy950 = Color(0xFF0E141D);

  // ── Sky — brand accent (#8FB5D3 = 400) ──────────────────────────────
  static const Color sky50 = Color(0xFFF1F6FA);
  static const Color sky100 = Color(0xFFDCE9F3);
  static const Color sky200 = Color(0xFFC3D9E9);
  static const Color sky300 = Color(0xFFB2CDE1);
  static const Color sky400 = Color(0xFF8FB5D3); // BRAND
  static const Color sky500 = Color(0xFF6F9DBF);
  static const Color sky600 = Color(0xFF5384A9);
  static const Color sky700 = Color(0xFF3A6688);
  static const Color sky800 = Color(0xFF294D69);
  static const Color sky900 = Color(0xFF1B3449);

  // ── Gray — neutral scale (slightly cool, to sit next to navy) ───────
  static const Color gray0 = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF8F9FA);
  static const Color gray100 = Color(0xFFF1F3F5);
  static const Color gray200 = Color(0xFFE5E8EB);
  static const Color gray300 = Color(0xFFD3D8DD);
  static const Color gray400 = Color(0xFFAEB5BE);
  static const Color gray500 = Color(0xFF858D98);
  static const Color gray600 = Color(0xFF626B77);
  static const Color gray700 = Color(0xFF464E59);
  static const Color gray800 = Color(0xFF2D343D);
  static const Color gray900 = Color(0xFF1A1F26);

  // ── Status hues (600/700 = filled on light, 800 = text on soft tint,
  //    400 = filled on dark). White text on every 600/700 value ≥ 4.8:1.
  static const Color green400 = Color(0xFF3DBE8B);
  static const Color green600 = Color(0xFF0B7F58);
  static const Color green800 = Color(0xFF065F46);

  static const Color amber400 = Color(0xFFE3A33A);
  static const Color amber700 = Color(0xFFA16207);
  static const Color amber800 = Color(0xFF854D0E);

  static const Color red400 = Color(0xFFF26B6B);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red800 = Color(0xFF991B1B);

  static const Color blue400 = Color(0xFF6FA8DC);
  static const Color blue600 = Color(0xFF2B6CA3);
  static const Color blue800 = Color(0xFF1E4E79);
}

// ═════════════════════════════════════════════════════════════════════════
// Layer 2 — Semantic tokens (Light theme)
// ═════════════════════════════════════════════════════════════════════════

/// Coach Studio color tokens (Design System v3.0 — Light).
///
/// Roles are strictly separated:
///  * primary   — Orange: brand energy. CTAs, active navigation, key actions.
///  * secondary — Navy: structure and emphasis. Focus rings, selected states,
///                strong text, dark surfaces.
///  * accent    — Sky blue: supportive highlights, secondary CTAs, decorative
///                fills. NOT a status color (see [info]).
///  * state colors (success / info / warning / error) are independent of
///    the brand colors, so a brand change never alters their meaning.
///
/// Naming scheme:
///    role · role+Dark/Light/Soft · on+Role (content drawn ON that role)
///
/// Contrast (WCAG): every `onX` token is ≥ 4.5:1 on its `X`, and
/// [textPrimary] / [textSecondary] are ≥ 4.5:1 on [background] and [surface].
///
/// Always use these semantic names; never hard-code colors in pages.
abstract final class AppColors {
  AppColors._();

  // ── Primary (Orange) ─────────────────────────────────────
  static const Color primary = AppPalette.orange500;
  static const Color primaryDark =
      AppPalette.orange700; // pressed; text on soft (≈4.5:1)
  static const Color primaryLight =
      AppPalette.orange300; // gradient start / glow
  static const Color primarySoft = AppPalette.orange50; // tinted fill

  /// Navy on orange = 5.1:1. White on #F47738 is only 2.8:1 (fails AA).
  /// To restore white labels (brand preference), set this to
  /// `AppPalette.gray0`.
  static const Color onPrimary = AppPalette.gray0;

  // ── Secondary (Navy) ─────────────────────────────────────
  static const Color secondary = AppPalette.navy800;
  static const Color secondaryDark = AppPalette.navy900;
  static const Color secondaryLight = AppPalette.navy500;
  static const Color secondarySoft =
      AppPalette.navy50; // selected / tinted fill
  static const Color onSecondary = AppPalette.gray0; // 14:1

  // ── Accent (Sky blue) ────────────────────────────────────
  static const Color accent = AppPalette.sky400;
  static const Color accentDark =
      AppPalette.sky700; // text/icon-safe accent (6.1:1 on white)
  static const Color accentLight = AppPalette.sky300;
  static const Color accentSoft = AppPalette.sky100;

  /// Navy on sky = 6.6:1.
  static const Color onAccent = AppPalette.navy800;

  // ── Neutrals: surfaces ───────────────────────────────────
  static const Color background = AppPalette.gray50; // page background
  static const Color surface = AppPalette.gray0; // cards, dialogs, sheets
  static const Color surfaceVariant =
      AppPalette.gray100; // nested / muted fills
  static const Color outline = AppPalette.gray200; // hairline borders, dividers
  static const Color outlineStrong = AppPalette.gray300; // emphasized borders
  static const Color disabled = AppPalette.gray300; // disabled fills / tracks

  // ── Neutrals: text ───────────────────────────────────────
  static const Color textPrimary = AppPalette.navy800; // 14:1 on white
  static const Color textSecondary = AppPalette.gray600; // 5.4:1 on white
  /// Placeholders / non-essential hints only (≈3.3:1 — never for core copy).
  static const Color textMuted = AppPalette.gray500;
  static const Color textDisabled = AppPalette.gray400;

  /// Links and text-sized accent content (accent itself is too light for text).
  static const Color textLink = accentDark;

  // ── Semantic states ──────────────────────────────────────
  static const Color success = AppPalette.green400;
  static const Color successDark = AppPalette.green800;
  static const Color onSuccess = AppPalette.gray0;

  static const Color info = AppPalette.blue600;
  static const Color infoDark = AppPalette.blue800;
  static const Color onInfo = AppPalette.gray0;

  static const Color warning = AppPalette.amber400;
  static const Color warningDark = AppPalette.amber800;
  static const Color onWarning = AppPalette.gray0;

  static const Color error = AppPalette.red600;
  static const Color errorDark = AppPalette.red800;
  static const Color onError = AppPalette.gray0;

  // ── Glass (use sparingly: floating nav, highlights) ──────
  static const Color glassHighlight = Color(0xE6FFFFFF); // white @ ~90%
  static const Color glassFill = Color(0xB3FFFFFF); // white @ ~70%
  static const Color glassBorder = Color(0xCCFFFFFF); // white @ ~80%

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
    colors: [secondaryLight, secondaryDark],
  );

  // ── Translucent tints ────────────────────────────────────
  /// Decorative background tint (primary @ 10%). Const-compatible literal;
  /// keep in sync with [primary].
  static const Color backgroundBlur = Color(0x1AF47738);

  /// Modal barrier / overlay scrim (secondary @ 40%).
  static final Color scrim = secondary.withValues(alpha: 0.40);

  // ── Soft tints for status chips (derived, never hand-written) ─
  static final Color successSoft = success.withValues(alpha: 0.14);
  static final Color infoSoft = info.withValues(alpha: 0.12);
  static final Color warningSoft = warning.withValues(alpha: 0.16);
  static final Color errorSoft = error.withValues(alpha: 0.12);
}

// ═════════════════════════════════════════════════════════════════════════
// Layer 3 — Dark theme draft (NOT wired to the app yet)
// ═════════════════════════════════════════════════════════════════════════

/// Dark counterpart of [AppColors], using the SAME token names so a future
/// switch is a mechanical change (e.g. exposing both sets through a
/// `ThemeExtension`).
///
/// Principles:
///  * surfaces step UP in lightness with elevation (950 → 900 → 800);
///  * brand colors keep their hue; `secondary` inverts to a light navy,
///    because dark navy would vanish on dark surfaces;
///  * state colors move to their lighter 400 steps;
///  * contrast ≥ 4.5:1 for text on [background] and [surface].
abstract final class AppDarkColors {
  AppDarkColors._();

  static const Color primary = AppPalette.orange500; // 6.2:1 on surface
  static const Color primaryDark = AppPalette.orange400;
  static const Color primaryLight = AppPalette.orange300;
  static const Color primarySoft = AppPalette.orange900;
  static const Color onPrimary = AppPalette.navy900;

  static const Color secondary = AppPalette.navy300;
  static const Color secondaryDark = AppPalette.navy200;
  static const Color secondaryLight = AppPalette.navy400;
  static const Color secondarySoft = AppPalette.navy700;
  static const Color onSecondary = AppPalette.navy900;

  static const Color accent = AppPalette.sky400; // 8:1 on surface
  static const Color accentDark = AppPalette.sky300;
  static const Color accentLight = AppPalette.sky200;
  static const Color accentSoft = AppPalette.sky900;
  static const Color onAccent = AppPalette.navy900;

  static const Color background = AppPalette.navy950;
  static const Color surface = AppPalette.navy900;
  static const Color surfaceVariant = AppPalette.navy800;
  static const Color outline = AppPalette.navy700;
  static const Color outlineStrong = AppPalette.navy600;
  static const Color disabled = AppPalette.navy600;

  static const Color textPrimary = AppPalette.gray50;
  static const Color textSecondary = AppPalette.gray400; // 8.3:1 on surface
  static const Color textMuted = AppPalette.gray500;
  static const Color textDisabled = AppPalette.gray600;
  static const Color textLink = AppPalette.sky300;

  static const Color success = AppPalette.green400;
  static const Color info = AppPalette.blue400;
  static const Color warning = AppPalette.amber400;
  static const Color error = AppPalette.red400;
  static const Color onStatus =
      AppPalette.navy950; // text on the 400-step fills
}
