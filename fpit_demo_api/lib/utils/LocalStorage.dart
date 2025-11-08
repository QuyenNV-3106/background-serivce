import 'dart:io';

import 'package:path_provider/path_provider.dart';

class MyLocalStorage {
  static Future<String> getlocalPath() async {
    final directory = await getExternalStorageDirectory();

    return directory!.path;
  }

  static Future<File> getlocalFile() async {
    final path = await getlocalPath();
    return File('$path/logFile.txt');
  }

  Future<String> readFile() async {
    try {
      final file = await getlocalFile();

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "Empty file";
    }
  }

  static Future<void> writeFile(String content) async {
    final file = await getlocalFile();
    print(file.uri);
    

    // Write the file
    file.writeAsStringSync("$content${Platform.lineTerminator}", mode: FileMode.append, flush:true );
  }
}
