import 'package:flutter/material.dart';
import 'package:mi_vision/Utils/custom%20colors.dart';

class AppTextStyle {
  static String _appFont = 'CircularStd';
  String get appFont => _appFont;
  TextStyle heading = TextStyle(
    fontFamily: _appFont,
    fontSize: 25,
    fontWeight: FontWeight.normal,
    color: CustomColors.firebaseAmber,
  );
  TextStyle headingBold = TextStyle(
    fontFamily: _appFont,
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: CustomColors.firebaseAmber,
  );
  TextStyle heading2 = TextStyle(
    fontFamily: _appFont,
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: CustomColors.firebaseAmber,
  );
  TextStyle heading2Bold = TextStyle(
    fontFamily: _appFont,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: CustomColors.firebaseAmber,
  );
  TextStyle body = TextStyle(
    fontFamily: _appFont,
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: CustomColors.firebaseAmber,
  );
  TextStyle bodyBold = TextStyle(
    fontFamily: _appFont,
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: CustomColors.firebaseAmber,
  );
}