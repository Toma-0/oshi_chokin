import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Size {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;
  static double? w;
  static double? h;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    w = screenWidth! / 100;
    h = screenHeight! / 100;
  }
}
