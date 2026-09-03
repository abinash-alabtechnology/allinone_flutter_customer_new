import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppFonts {
  AppFonts._(); 

  // FONT FAMILY
  static const String fontFamily = 'Poppins'; 

  // FONT SIZES
  static const double fontSizeExtraSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeDefault = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeExtraLarge = 18.0;
  static const double fontSizeOverLarge = 24.0;

  // TEXT STYLES
  static const TextStyle regular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: fontSizeDefault,
    color: AppColors.textColor,
  );

  static const TextStyle medium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: fontSizeDefault,
    color: AppColors.textColor,
  );

  static const TextStyle semiBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: fontSizeDefault,
    color: AppColors.textColor,
  );

  static const TextStyle bold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: fontSizeDefault,
    color: AppColors.textColor,
  );

  static const TextStyle extraBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: fontSizeDefault,
    color: AppColors.textColor,
  );
}
