import 'package:flutter/material.dart';

ThemeData getTheme() {
  Color primary = Colors.deepOrange.shade300;
  Color cardColor = Colors.grey.shade50;
  Color back = Colors.pink.shade50;
  Color tn = Colors.pink.shade100;

  ThemeData mData = ThemeData(
    fontFamily: 'Raleway',
    primaryColor: primary,
    accentColor: Colors.purple,
    cardColor: cardColor,
    backgroundColor: back,
    buttonColor: tn,
  );

  return mData;
}
