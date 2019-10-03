import 'package:flutter/material.dart';

ThemeData getTheme() {
  Color primary = Colors.blueGrey.shade400;
  Color cardColor = Colors.grey.shade50;
  Color back = Colors.pink.shade400;
  Color tn = Colors.pink.shade300;

  ThemeData mData = ThemeData(
    fontFamily: 'Raleway',
    primaryColor: primary,
    accentColor: back,
    accentIconTheme: IconThemeData(color: Colors.white),
    cardColor: cardColor,
    backgroundColor: back,
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      contentPadding: const EdgeInsets.all(8.0),
      border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.elliptical(2.0, 2.0))),
    ),
    buttonColor: tn,
  );

  return mData;
}
