import 'package:flutter/material.dart';

class AppColors {
  //0xFF272E93
  static const Color primaryColor = Color(0xFFb17223);
  static const Color primaryLightColor = Color(0xffcfd5d9);
  static const Color secondaryColor = Color(0xFFb17223);
  static const Color secondaryLightColor = Color(0xFFe4c269);
  static const Color botomNavColor = Color(0xFF231f20);
  static const Color secondaryTextColor = Color(0xFF333333);
  static const Color hintColor = Color(0xFFC6C6C6);
  static const Color hintColorLight = Color(0xA8CCCCCC);
  static const Color bg = Color(0xfff3f5f8);
  static const Color defaultColor = Colors.white;
  static const Color textColor = Colors.black;
  static const Color primaryTextColor = Color(0XFF883225);
  static const Color green = Colors.green;
  static const Color red = Colors.red;
  static const Color transparent = Colors.transparent;

  static const boxShadow = BoxShadow(
    color: AppColors.hintColorLight,
    blurRadius: 40,
    offset: Offset(0, 10),
    spreadRadius: 0,
  );
  static const primaryGradient=LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      secondaryColor,
      secondaryLightColor,
      secondaryColor,
    ],
    stops: [0.0, 0.51, 1.0],
  );
  static const secondaryGradient=LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0XFF202639),
      Color(0XFF3F4C77),
      Color(0XFF202639),
    ],
    stops: [0.0, 0.51, 1.0],
  );
}
