import 'dart:io';
import 'dart:math';

import 'package:document_organizer/models/file.dart';

class FileUtils {
  static String waPath = "/storage/emulated/0/WhatsApp/Media/.Statuses";

  /// Convert Byte to KB, MB, .......
  static String formatBytes(bytes, decimals) {
    if (bytes == 0) return "0.0 KB";
    var k = 1000,
        dm = decimals <= 0 ? 0 : decimals,
        sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
        i = (log(bytes) / log(k)).floor();
    return (((bytes / pow(k, i)).toStringAsFixed(dm)) + ' ' + sizes[i]);
    //return bytes.toString();
  }

  static List<FileD> sortList(
      List<FileD> list, int sort) {
    switch (sort) {
      case 0:
          return list
            ..sort((f1, f2) => (f1.name)
                .toLowerCase()
                .compareTo((f2.name).toLowerCase()));

        break;
      case 3:
        list.sort((f1, f2) => (f1.name)
            .toLowerCase()
            .compareTo((f2.name).toLowerCase()));
        return list.reversed.toList();
        break;

      case 1:
        return list
          ..sort((f1, f2) => FileSystemEntity.isFileSync(f1.path) &&
                  FileSystemEntity.isFileSync(f2.path)
              ? File(f1.path)
                  .lastModifiedSync()
                  .compareTo(File(f2.path).lastModifiedSync())
              : 1);
        break;

      case 4:
        list
          ..sort((f1, f2) => FileSystemEntity.isFileSync(f1.path) &&
                  FileSystemEntity.isFileSync(f2.path)
              ? File(f1.path)
                  .lastModifiedSync()
                  .compareTo(File(f2.path).lastModifiedSync())
              : 1);
        return list.reversed.toList();
        break;

      case 5:
        list
          ..sort((f1, f2) => FileSystemEntity.isFileSync(f1.path) &&
                  FileSystemEntity.isFileSync(f2.path)
              ? File(f1.path).lengthSync().compareTo(File(f2.path).lengthSync())
              : 0);
        return list.reversed.toList();
        break;

      case 2:
        return list
          ..sort((f1, f2) => FileSystemEntity.isFileSync(f1.path) &&
                  FileSystemEntity.isFileSync(f2.path)
              ? File(f1.path).lengthSync().compareTo(File(f2.path).lengthSync())
              : 0);
        break;

      default:
        return list..sort();
    }
  }
}
