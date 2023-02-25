import 'package:flutter/material.dart';

class SecondPallete {
  static const MaterialColor kToDark = MaterialColor(
    0xffe0b22c, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xffd4a929), //10%
      100: Color(0xffcca227), //20%
      200: Color(0xffbf9824), //30%
      300: Color(0xffb59022), //40%
      400: Color(0xffa07f1c), //50%
      500: Color(0xff967718), //60%
      600: Color(0xff8f7216), //70%
      700: Color(0xff856914), //80%
      800: Color(0xff725a11), //90%
      900: Color(0xff68520f), //100%
    },
  );
} // you can define define int 500 as the default shade and add your lighter tints above and darker tints below. 