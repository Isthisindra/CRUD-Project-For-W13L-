// lib/utils/app_theme.dart
// Konstanta tema dan styling untuk desain Stock+.

import 'package:flutter/cupertino.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF1A7FDB);
  static const Color primaryDark = Color(0xFF155FA0);
  static const Color accentBlue = Color(0xFF4DA6FF);
  static const Color lightBlue = Color(0xFFE8F4FD);
  static const Color surfaceBlue = Color(0xFFF0F8FF);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);

  // Spacing
  static const double spacingXS = 4;
  static const double spacingSM = 8;
  static const double spacingMD = 12;
  static const double spacingLG = 16;
  static const double spacingXL = 20;
  static const double spacingXXL = 24;
  static const double spacing3XL = 32;
  static const double spacing4XL = 40;

  // Border Radius
  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 20;
  static const double radiusFull = 100;

  // Font Sizes
  static const double fontXS = 11;
  static const double fontSM = 13;
  static const double fontMD = 15;
  static const double fontLG = 17;
  static const double fontXL = 20;
  static const double fontXXL = 24;
  static const double font3XL = 28;
  static const double font4XL = 32;

  // Shadow
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: font3XL,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: fontXXL,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: fontXL,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: fontLG,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: fontMD,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: fontSM,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: fontXS,
    fontWeight: FontWeight.w500,
    color: textTertiary,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: fontMD,
    fontWeight: FontWeight.w600,
    color: white,
  );

  // Input Decoration
  static BoxDecoration get inputDecoration => BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(radiusMD),
        border: Border.all(color: border, width: 1),
      );

  static BoxDecoration get inputFocusDecoration => BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(radiusMD),
        border: Border.all(color: primaryBlue, width: 1.5),
      );

  // Card Decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(radiusLG),
        boxShadow: cardShadow,
      );
}
