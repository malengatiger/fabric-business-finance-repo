import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileUtil {
  static File jsonFile;
  static Directory dir;
  static bool fileExists;

  static Future<int> test() async {
    dir = await getApplicationDocumentsDirectory();
    var f = await getExternalStorageDirectory();
    var ents = f.list(recursive: true, followLinks: true);
    print('Filetest FileSystemEntities ######## ');
    ents.forEach((fsEnt) {
      print('Filetest FileSystemEntity: ${fsEnt.path}');
    });
    return 0;

//    jsonFile = new File(dir.path + "/wallety.json");
//    fileExists = await jsonFile.exists();

//    if (fileExists) {
//      print("FileUtil ## file exists, reading ...");
//      String string = await jsonFile.readAsString();
//      Map map = json.decode(string);
//      Wallets w = new Wallets.fromJson(map);
//      var cnt = w.wallets.length;
//      print('FileUtil ## returning wallets found: $cnt');
//      return w.wallets;
//    } else {
//      print('FileUtil ## file does not exist. returning empty list');
//      Wallets w = new Wallets.create();
//      w.wallets = new List();
//      return w.wallets;
//    }
  }
}
