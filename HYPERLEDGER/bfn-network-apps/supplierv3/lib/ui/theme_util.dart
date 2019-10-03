import 'package:flutter/material.dart';

ThemeData getTheme() {
  Color primary = Colors.teal.shade400;
  Color cardColor = Colors.brown.shade50;
  Color back = Colors.indigo.shade50;
  Color tn = Colors.pink.shade500;

  ThemeData mData = ThemeData(
    fontFamily: 'Raleway',
    primaryColor: primary,
    accentColor: Colors.deepOrange,
    accentIconTheme: IconThemeData(color: Colors.white),
    cardColor: cardColor,
    backgroundColor: back,
    buttonColor: tn,
  );

  return mData;
}
