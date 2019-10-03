import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:businesslibrary/util/lookups.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageAPI {
  static FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  static Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);

  // ignore: missing_return
  static uploadFile(
      String folderName, String path, UploadListener listener) async {
    print('StorageAPI.uploadFile $folderName path: $path');
    rand = new Random(new DateTime.now().millisecondsSinceEpoch);
    var index = path.lastIndexOf('.');
    var extension = path.substring(index + 1);
    var name = 'BFN' + getUTCDate() + '_${rand.nextInt(1000)} +.$extension';

    try {
      File file = new File(path);
      final StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(folderName).child(name);

      var task = firebaseStorageRef.putFile(file);
      task.events.listen((event) {
        var totalByteCount = event.snapshot.totalByteCount;
        var bytesTransferred = event.snapshot.bytesTransferred;
        var bt = (bytesTransferred / 1024).toStringAsFixed(2) + ' KB';
        var tot = (totalByteCount / 1024).toStringAsFixed(2) + ' KB';
        print(
            'StorageAPI.uploadFile:  progress ******* $bt KB of $tot KB transferred');

        listener.onProgress(tot, bt);
      });
      task.onComplete.then((snap) {
        var totalByteCount = snap.totalByteCount;
        var bytesTransferred = snap.bytesTransferred;
        var bt = (bytesTransferred / 1024).toStringAsFixed(2) + ' KB';
        var tot = (totalByteCount / 1024).toStringAsFixed(2) + ' KB';
        print(
            'StorageAPI.uploadFile:  complete ******* $bt KB of $tot KB transferred');

        listener.onComplete(
            firebaseStorageRef.getDownloadURL().toString(), tot, bt);
      }).catchError((e) {
        print(e);
        listener.onError('File upload failed');
      });
    } catch (e) {
      print(e);
      listener.onError('Houston, we have a problem $e');
    }
  }

  // ignore: missing_return
  static Future<int> deleteFolder(String folderName) async {
    print('StorageAPI.deleteFolder ######## deleting $folderName');
    var task = _firebaseStorage.ref().child(folderName).delete();
    await task.then((f) {
      print('StorageAPI.deleteFolder $folderName deleted from FirebaseStorage');
      return 0;
    }).catchError((e) {
      print('StorageAPI.deleteFolder ERROR $e');
      return 1;
    });
  }

  // ignore: missing_return
  static Future<int> deleteFile(String folderName, String name) async {
    print('StorageAPI.deleteFile ######## deleting $folderName : $name');
    var task = _firebaseStorage.ref().child(folderName).child(name).delete();
    task.then((f) {
      print(
          'StorageAPI.deleteFile $folderName : $name deleted from FirebaseStorage');
      return 0;
    }).catchError((e) {
      print('StorageAPI.deleteFile ERROR $e');
      return 1;
    });
  }
}

abstract class UploadListener {
  onProgress(String totalByteCount, String bytesTransferred);
  onComplete(String url, String totalByteCount, String bytesTransferred);
  onError(String message);
}
