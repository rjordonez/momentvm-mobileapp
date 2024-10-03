import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/courses.json');
  }

  // Read data from the local file
  static Future<Map<String, dynamic>> readCoursesData() async {
    try {
      final file = await _localFile;

      if (await file.exists()) {
        // Read the file
        String contents = await file.readAsString();
        return jsonDecode(contents);
      } else {
        // If the file doesn't exist, load from assets and save it locally
        String jsonString = await rootBundle.loadString('assets/courses.json');
        Map<String, dynamic> data = jsonDecode(jsonString);
        await writeCoursesData(data);
        return data;
      }
    } catch (e) {
      print('Error reading courses data: $e');
      return {};
    }
  }

  // Write data to the local file
  static Future<void> writeCoursesData(Map<String, dynamic> data) async {
    try {
      final file = await _localFile;

      // Write the file
      String jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error writing courses data: $e');
    }
  }
}
