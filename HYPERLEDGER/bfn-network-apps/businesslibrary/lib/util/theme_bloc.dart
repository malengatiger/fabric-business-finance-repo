import 'dart:async';
import 'dart:math';

import 'package:businesslibrary/api/shared_prefs.dart';
import 'package:flutter/material.dart';

final ThemeBloc themeBloc = ThemeBloc();

class ThemeBloc {
  ThemeBloc() {
    initialize();
  }

  final StreamController<int> _themeController = StreamController<int>();
  final _rand = Random(DateTime.now().millisecondsSinceEpoch);
  get changeToTheme0 => _themeController.sink.add(0);
  get changeToTheme1 => _themeController.sink.add(1);
  get changeToTheme2 => _themeController.sink.add(2);

  initialize() async {
    var index = await SharedPrefs.getThemeIndex();
    print('📌 📌 📌 📌️ initialize:: adding index to stream ....index: $index');
    _themeController.sink.add(index);
  }

  changeToTheme(int index) {
    print('✈️✈️ changeToTheme: adding index to stream ....');
    _themeController.sink.add(index);
  }

  changeToRandomTheme() {
    var index = _rand.nextInt(ThemeUtil.getThemeCount() - 1);
    _themeController.sink.add(index);
    print('✈️✈️ changeToRandomTheme: adding index to stream ....');
    SharedPrefs.saveThemeIndex(index);
  }

  closeStream() {
    _themeController.close();
  }

  get newThemeStream => _themeController.stream;
}

class ThemeUtil {
  static List<ThemeData> _themes = List();

  static int index;
  static ThemeData getTheme({int themeIndex}) {
    print('🌈 🌈 getting theme with index: 🌈 $index');
    if (_themes.isEmpty) {
      _setThemes();
    }
    if (themeIndex == null) {
      if (index == null) {
        index = 0;
      } else {
        index++;
        if (index == _themes.length) {
          index = 0;
        }
      }
    } else {
      index = themeIndex;
    }
    return _themes.elementAt(index);
  }

  static int getThemeCount() {
    _setThemes();
    return _themes.length;
  }

  static var _rand = Random(DateTime.now().millisecondsSinceEpoch);

  static ThemeData getRandomTheme() {
    if (_themes.isEmpty) _setThemes();
    var index = _rand.nextInt(_themes.length - 1);
    return _themes.elementAt(index);
  }

  static ThemeData getThemeByIndex(int index) {
    if (index >= _themes.length || index < 0) index = 0;
    return _themes.elementAt(index);
  }

  static void _setThemes() {
    _themes.clear();
    var aTheme = AppBarTheme(color: Colors.blue.shade300);

    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.indigo.shade400,
      accentColor: Colors.pink,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      appBarTheme: AppBarTheme(
          color: Colors.indigo.shade300, brightness: Brightness.dark),
      buttonColor: Colors.blue,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.pink,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      appBarTheme: AppBarTheme(color: Colors.pink.shade200),
      buttonColor: Colors.indigo,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.teal,
      accentColor: Colors.purple,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      appBarTheme: AppBarTheme(color: Colors.teal.shade300),
      buttonColor: Colors.pink,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.brown,
      accentColor: Colors.yellow.shade900,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      appBarTheme: AppBarTheme(color: Colors.brown.shade300),
      buttonColor: Colors.blue,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.lime.shade800,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      appBarTheme: AppBarTheme(color: Colors.lime.shade300),
      buttonColor: Colors.brown,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.blue,
      accentColor: Colors.red,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      appBarTheme: AppBarTheme(color: Colors.blue.shade300),
      buttonColor: Colors.blue,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.blueGrey,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      appBarTheme: AppBarTheme(color: Colors.blueGrey.shade300),
      buttonColor: Colors.pink,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.purple,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      appBarTheme: AppBarTheme(color: Colors.purple.shade300),
      buttonColor: Colors.pink,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.amber.shade700,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      appBarTheme: AppBarTheme(color: Colors.amber.shade300),
      buttonColor: Colors.pink,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.deepOrange,
      accentColor: Colors.brown,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      appBarTheme: AppBarTheme(color: Colors.deepOrange.shade300),
      buttonColor: Colors.deepOrange,
    ));
    _themes.add(ThemeData(
      fontFamily: 'Raleway',
      primaryColor: Colors.orange,
      accentColor: Colors.teal,
      cardColor: Colors.white,
      backgroundColor: Colors.brown.shade100,
      appBarTheme: AppBarTheme(color: Colors.orange.shade300),
      buttonColor: Colors.pink,
    ));
  }
}
