import 'package:flutter/material.dart';

class PrimaryPalette {
  static const MaterialColor kToDark = MaterialColor(
    0xff00b4e7, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xff00abd9), //10%
      100: Color(0xff00a7d4), //20%
      200: Color(0xff00a0cc), //30%
      300: Color(0xff0094bc), //40%
      400: Color(0xff0085aa), //50%
      500: Color(0xff007799), //60%
      600: Color(0xff006a89), //70%
      700: Color(0xff006482), //80%
      800: Color(0xff005a75), //90%
      900: Color(0xff004256), //100%
    },
  );
} // you can define define int 500 as the default shade and add your lighter tints above and darker tints below. 
