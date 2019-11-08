import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColorsStyle {
  static getColorBotton() => new LinearGradient(
      colors: [Colors.amber, Colors.amber],
      tileMode: TileMode.repeated);

  static getColorBackGround() => new LinearGradient(
      colors: [Colors.white.withOpacity(0.1), Colors.white],
      begin: const FractionalOffset(0.0, 0.0),
      end: const FractionalOffset(5.0, 0.0),
      stops: [0.0, 2.0],
      tileMode: TileMode.repeated);

  static getColorCategory() => new LinearGradient(
      colors: [Colors.amberAccent, Colors.white],
      begin: const FractionalOffset(0.0, 0.0),
      end: const FractionalOffset(5.0, 0.0),
      stops: [0.0, 0.0],
      tileMode: TileMode.repeated);

  Color black = Colors.black;
  Color white = Colors.white;
}
