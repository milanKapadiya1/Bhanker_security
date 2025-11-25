import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static const primaryColor = Color(0xFF4F46E5); // Indigo
  static const secondaryColor = Color(0xFF10B981); // Emerald
  static const backgroundColor = Color(0xFFF9FAFB); // Gray 50
  static const surfaceColor = Colors.white;
  static const textPrimary = Color(0xFF111827); // Gray 900
  static const textSecondary = Color(0xFF6B7280); // Gray 500

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: TextStyle(
          fontSize: 32.sp, fontWeight: FontWeight.bold, color: textPrimary),
      displayMedium: TextStyle(
          fontSize: 28.sp, fontWeight: FontWeight.bold, color: textPrimary),
      displaySmall: TextStyle(
          fontSize: 24.sp, fontWeight: FontWeight.bold, color: textPrimary),
      headlineMedium: TextStyle(
          fontSize: 20.sp, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: TextStyle(fontSize: 16.sp, color: textPrimary),
      bodyMedium: TextStyle(fontSize: 14.sp, color: textSecondary),
      bodySmall: TextStyle(fontSize: 12.sp, color: textSecondary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: EdgeInsets.only(bottom: 16.h),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: TextStyle(color: textSecondary, fontSize: 14.sp),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
