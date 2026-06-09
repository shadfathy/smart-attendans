// lib/core/theme/text_styles.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';
import 'fonts.dart';

class TextStyles {
  static double fontSize(double size) {
    double responsiveSize = 1.sw >= 800 ? size.spMax * 0.7 : size.sp;
    return responsiveSize *
        0.85; // Scale down Tajawal font as it appears larger than Lateef
  }

  static final String _font = kArabicFontFamily;

  static bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color _textPrimary(BuildContext context) {
    return _isDark(context)
        ? ColorsManager.darkTextPrimary
        : ColorsManager.black;
  }

  static Color _textSecondary(BuildContext context) {
    return _isDark(context)
        ? ColorsManager.darkTextSecondary
        : ColorsManager.darkGray;
  }

  static Color _textDark(BuildContext context) {
    return _isDark(context)
        ? ColorsManager.darkTextPrimary
        : ColorsManager.darkFontColor;
  }

  static Color _primaryColor(BuildContext context) {
    return _isDark(context)
        ? ColorsManager.primary300
        : ColorsManager.primaryColor;
  }

  static Color _primary400(BuildContext context) {
    return _isDark(context)
        ? ColorsManager.primary300
        : ColorsManager.primary400;
  }

  static Color _primary500(BuildContext context) {
    return _isDark(context)
        ? ColorsManager.primary300
        : ColorsManager.primary500;
  }

  static Color _dark500(BuildContext context) {
    return _isDark(context)
        ? ColorsManager.darkTextSecondary
        : ColorsManager.dark500;
  }

  // ==================== Font Size 6 ====================
  static TextStyle font6Blue500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(6),
    fontWeight: FontWeight.w500,
    color: _primaryColor(context),
    fontFamily: _font,
  );

  // ==================== Font Size 10 ====================
  static TextStyle font10White500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(10),
    fontWeight: FontWeight.w500,
    color: ColorsManager.white,
    fontFamily: _font,
  );

  static TextStyle font10DarkGray400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(10),
    fontWeight: FontWeight.w400,
    color: _textSecondary(context),
    fontFamily: _font,
  );

  static TextStyle font10Yellow500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(12),
    fontWeight: FontWeight.w500,
    color: ColorsManager.secondary500,
    fontFamily: _font,
  );

  static TextStyle font10Yellow400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(10),
    fontWeight: FontWeight.w400,
    color: ColorsManager.secondary,
    fontFamily: _font,
  );

  static TextStyle font10Dark400Grey400Weight(BuildContext context) =>
      TextStyle(
        fontSize: fontSize(10),
        fontWeight: FontWeight.w400,
        color: _textSecondary(context),
        fontFamily: _font,
      );

  static TextStyle font10Secondary500700Weight(BuildContext context) =>
      TextStyle(
        fontSize: fontSize(10),
        fontWeight: FontWeight.w700,
        color: ColorsManager.secondary500,
        fontFamily: _font,
      );

  static TextStyle font10Error500500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(10),
    fontWeight: FontWeight.w500,
    color: ColorsManager.errorColor,
    fontFamily: _font,
  );

  static TextStyle font10Dark600Grey400Weight(BuildContext context) =>
      TextStyle(
        fontSize: fontSize(10),
        fontWeight: FontWeight.w400,
        color: _textSecondary(context),
        fontFamily: _font,
      );

  static TextStyle font10Primary400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(10),
    fontWeight: FontWeight.w400,
    color: _primaryColor(context),
    fontFamily: _font,
  );

  static TextStyle font10Primary500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(10),
    fontWeight: FontWeight.w500,
    color: _primaryColor(context),
    fontFamily: _font,
  );

  static TextStyle font10secondary500Weight400(BuildContext context) =>
      TextStyle(
        fontSize: fontSize(10),
        fontWeight: FontWeight.w400,
        color: ColorsManager.secondary500,
        fontFamily: _font,
      );

  static TextStyle font10darkGrayWeight400(BuildContext context) => TextStyle(
    fontSize: fontSize(10),
    fontWeight: FontWeight.w400,
    color: _textSecondary(context),
    fontFamily: _font,
  );

  static TextStyle font10Primary400400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(10),
    fontWeight: FontWeight.w400,
    color: _primary400(context),
    fontFamily: _font,
  );

  // ==================== Font Size 12 ====================
  static TextStyle font12White400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(12),
    fontWeight: FontWeight.w400,
    color: ColorsManager.white,
    fontFamily: _font,
  );

  static TextStyle font12White500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(12),
    fontWeight: FontWeight.w500,
    color: ColorsManager.white,
    fontFamily: _font,
  );

  static TextStyle font12Black400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(12),
    fontWeight: FontWeight.w400,
    color: _textPrimary(context),
    fontFamily: _font,
  );

  static TextStyle font12Black500Weight(BuildContext context) => TextStyle(
    fontFamily: _font,
    fontSize: fontSize(12),
    fontWeight: FontWeight.w500,
    color: _textDark(context),
  );

  static TextStyle font12DarkGray400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(12),
    fontWeight: FontWeight.w400,
    color: _textSecondary(context),
    fontFamily: _font,
  );

  static TextStyle font12Blue400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(12),
    fontWeight: FontWeight.w400,
    color: _primaryColor(context),
    fontFamily: _font,
  );

  static TextStyle font12Green400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(12),
    fontWeight: FontWeight.w400,
    color: ColorsManager.teal,
    fontFamily: _font,
  );

  static TextStyle font12secondary500yellow400Weight(BuildContext context) =>
      TextStyle(
        fontSize: fontSize(12),
        fontWeight: FontWeight.w400,
        color: ColorsManager.secondary,
        fontFamily: _font,
      );

  static TextStyle font12Primary100400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(12),
    fontWeight: FontWeight.w400,
    color: _isDark(context)
        ? ColorsManager.primary200
        : ColorsManager.primary100,
    fontFamily: _font,
  );

  static TextStyle font12Primary400400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(12),
    fontWeight: FontWeight.w400,
    color: _primary400(context),
    fontFamily: _font,
  );

  static TextStyle font12Dark500400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(12),
    fontWeight: FontWeight.w400,
    color: _dark500(context),
    fontFamily: _font,
  );

  static TextStyle font12Dark500500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(12),
    fontWeight: FontWeight.w500,
    color: _dark500(context),
    fontFamily: _font,
  );

  static TextStyle font12Primary300400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(12),
    fontWeight: FontWeight.w400,
    color: ColorsManager.primary300,
    fontFamily: _font,
  );

  static TextStyle font12secondary900400Weight(BuildContext context) =>
      TextStyle(
        fontSize: fontSize(12),
        fontWeight: FontWeight.w400,
        color: _isDark(context)
            ? ColorsManager.secondary500
            : ColorsManager.secondary900,
        fontFamily: _font,
      );

  // ==================== Font Size 14 ====================
  static TextStyle font14White400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(14),
    fontWeight: FontWeight.w400,
    color: ColorsManager.white,
    fontFamily: _font,
  );

  static TextStyle font14White500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(14),
    fontWeight: FontWeight.w500,
    color: ColorsManager.white,
    fontFamily: _font,
  );

  static TextStyle font14Black400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(14),
    fontWeight: FontWeight.w400,
    color: _textPrimary(context),
    fontFamily: _font,
  );

  static TextStyle font14Black500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(14),
    fontWeight: FontWeight.w500,
    color: _textDark(context),
    fontFamily: _font,
  );

  static TextStyle font14DarkGray400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(14),
    fontWeight: FontWeight.w400,
    color: _textSecondary(context),
    fontFamily: _font,
  );

  static TextStyle font14Dark400400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(14),
    fontWeight: FontWeight.w400,
    color: _textSecondary(context),
    fontFamily: _font,
  );

  static TextStyle font14Blue400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(14),
    fontWeight: FontWeight.w400,
    color: _primaryColor(context),
    fontFamily: _font,
  );

  static TextStyle font14Blue500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(14),
    fontWeight: FontWeight.w500,
    color: _primaryColor(context),
    fontFamily: _font,
  );

  static TextStyle font14Red500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(14),
    fontWeight: FontWeight.w500,
    color: ColorsManager.errorColor,
    fontFamily: _font,
  );

  static TextStyle font14secondary600yellow400Weight(BuildContext context) =>
      TextStyle(
        fontSize: fontSize(14),
        fontWeight: FontWeight.w400,
        color: ColorsManager.secondary600,
        fontFamily: _font,
      );

  static TextStyle font14Primary300500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(14),
    fontWeight: FontWeight.w500,
    color: ColorsManager.primary300,
    fontFamily: _font,
  );

  static TextStyle font14Dark300400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(14),
    fontWeight: FontWeight.w400,
    color: _textSecondary(context),
    fontFamily: _font,
  );

  static TextStyle font14Dark500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(14),
    fontWeight: FontWeight.w500,
    color: _textDark(context),
    fontFamily: _font,
  );

  static TextStyle font14Dark200400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(14),
    fontWeight: FontWeight.w400,
    color: _isDark(context)
        ? ColorsManager.darkTextSecondary
        : ColorsManager.black,
    fontFamily: _font,
  );

  static TextStyle font14PrimaryColor400Weight(BuildContext context) =>
      TextStyle(
        fontSize: fontSize(14),
        fontWeight: FontWeight.w400,
        color: _primaryColor(context),
        fontFamily: _font,
      );

  static TextStyle font14Primary500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(14),
    fontWeight: FontWeight.w500,
    color: _primaryColor(context),
    fontFamily: _font,
  );

  // ==================== Font Size 16 ====================
  static TextStyle font16White500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(16),
    fontWeight: FontWeight.w500,
    color: ColorsManager.white,
    fontFamily: _font,
  );

  static TextStyle font16Black500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(16),
    fontWeight: FontWeight.w500,
    color: _textPrimary(context),
    fontFamily: _font,
  );

  static TextStyle font16Dark300Grey400Weight(BuildContext context) =>
      TextStyle(
        fontSize: fontSize(16),
        fontWeight: FontWeight.w500,
        color: _textSecondary(context),
        fontFamily: _font,
      );

  static TextStyle font16DarkGrey400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(16),
    fontWeight: FontWeight.w400,
    color: _textSecondary(context),
    fontFamily: _font,
  );

  static TextStyle font16DarkGrey500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(16),
    fontWeight: FontWeight.w500,
    color: _textSecondary(context),
    fontFamily: _font,
  );

  static TextStyle font16Dark400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(16),
    fontWeight: FontWeight.w400,
    color: _textPrimary(context),
    fontFamily: _font,
  );

  static TextStyle font16Dark500400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(16),
    fontWeight: FontWeight.w400,
    color: _dark500(context),
    fontFamily: _font,
  );

  static TextStyle font16Primary500400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(16),
    fontWeight: FontWeight.w400,
    color: _primary500(context),
    fontFamily: _font,
  );

  static TextStyle font16Primary500500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(16),
    fontWeight: FontWeight.w500,
    color: _primary500(context),
    fontFamily: _font,
  );

  // ==================== Font Size 18 ====================
  static TextStyle font18Black400Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(18),
    fontWeight: FontWeight.w400,
    color: _textPrimary(context),
    fontFamily: _font,
  );

  static TextStyle font18Black500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(18),
    fontWeight: FontWeight.w500,
    color: _textPrimary(context),
    fontFamily: _font,
  );

  // ==================== Font Size 20 ====================
  static TextStyle font20White500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(20),
    fontWeight: FontWeight.w500,
    color: ColorsManager.white,
    fontFamily: _font,
  );

  static TextStyle font20Black500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(20),
    fontWeight: FontWeight.w500,
    color: _textDark(context),
    fontFamily: _font,
  );

  static TextStyle font20DarkGray500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(20),
    fontWeight: FontWeight.w500,
    color: _textSecondary(context),
    fontFamily: _font,
  );

  // ==================== Font Size 24 ====================
  static TextStyle font24White500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(24),
    fontWeight: FontWeight.w500,
    color: ColorsManager.white,
    fontFamily: _font,
  );

  static TextStyle font24Black700Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(24),
    fontWeight: FontWeight.w700,
    color: _textPrimary(context),
    fontFamily: _font,
  );

  static TextStyle font24Yellow700Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(24),
    fontWeight: FontWeight.w700,
    color: ColorsManager.secondary500,
    fontFamily: _font,
  );

  static TextStyle font24Primary500Weight(BuildContext context) => TextStyle(
    fontSize: fontSize(24),
    fontWeight: FontWeight.w500,
    color: _primaryColor(context),
    fontFamily: _font,
  );

  // ==================== Special Styles ====================
  static TextStyle header(BuildContext context) {
    return TextStyle(
      fontSize: fontSize(16),
      fontWeight: FontWeight.w700,
      color: _textPrimary(context),
      fontFamily: _font,
    );
  }

  static TextStyle shop(BuildContext context) {
    return TextStyle(
      fontSize: fontSize(16),
      fontWeight: FontWeight.w700,
      color: ColorsManager.white,
      fontFamily: _font,
    );
  }

  static TextStyle brand(BuildContext context) {
    return TextStyle(
      fontSize: fontSize(16),
      fontWeight: FontWeight.w700,
      color: _textPrimary(context),
      fontFamily: _font,
    );
  }

  static TextStyle customStyle(BuildContext context) {
    return TextStyle(
      fontSize: fontSize(14),
      fontWeight: FontWeight.w600,
      color: _textPrimary(context),
      fontFamily: _font,
    );
  }
}
