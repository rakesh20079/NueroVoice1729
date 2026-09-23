import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const List<String> _fontFallbacks = [
    'Inter',
    'Roboto',
    'Segoe UI',
    'sans-serif',
  ];

  static TextStyle get displayMetric => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 40 / 32,
        letterSpacing: -0.64,
        color: AppColors.onSurface,
        fontFamilyFallback: _fontFallbacks,
      );

  static TextStyle get headlineLg => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 36 / 28,
        letterSpacing: -0.28,
        color: AppColors.onSurface,
        fontFamilyFallback: _fontFallbacks,
      );

  static TextStyle get headlineMd => const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 28 / 22,
        letterSpacing: -0.22,
        color: AppColors.onSurface,
        fontFamilyFallback: _fontFallbacks,
      );

  static TextStyle get metricSm => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 32 / 24,
        color: AppColors.onSurface,
        fontFamilyFallback: _fontFallbacks,
      );

  static TextStyle get bodyLg => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurfaceVariant,
        fontFamilyFallback: _fontFallbacks,
      );

  static TextStyle get bodyMd => const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 22 / 15,
        color: AppColors.onSurfaceVariant,
        fontFamilyFallback: _fontFallbacks,
      );

  static TextStyle get bodyMdMedium => const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 22 / 15,
        color: AppColors.onSurface,
        fontFamilyFallback: _fontFallbacks,
      );

  static TextStyle get labelSm => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 18 / 13,
        letterSpacing: 0.13,
        color: AppColors.onSurfaceVariant,
        fontFamilyFallback: _fontFallbacks,
      );

  static TextStyle get labelSmBold => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 18 / 13,
        letterSpacing: 0.13,
        color: AppColors.onSurface,
        fontFamilyFallback: _fontFallbacks,
      );

  static TextStyle get badgeLabel => const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.onSurfaceVariant,
        fontFamilyFallback: _fontFallbacks,
      );
}
