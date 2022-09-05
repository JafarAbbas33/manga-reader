import 'dart:io';
import 'package:manga_reader/utils.dart';

class Config {
  Config._();

  static int jsonLocalDataSaveIndent = 4;
  static double mangaImageSize = 1.5; // 1.5 Default
  static Directory photoDir = Directory('/home/jafarabbas33/Documents/New folder');

// =============================================================================================================================

  static void fromJson(Map<String, dynamic> jsonData) {
    jsonLocalDataSaveIndent = jsonData['jsonLocalDataSaveIndent'];
    mangaImageSize = jsonData['mangaImageSize'];
    photoDir = Directory(jsonData['photoDir']);
  }

  static Map<String, dynamic> toJson() {
    return {
      'jsonLocalDataSaveIndent': jsonLocalDataSaveIndent,
      'mangaImageSize': mangaImageSize,
      'photoDir': photoDir.path,
    };
  }

  static Future<bool> saveSettings() {
    printFromMangaReader('Writing settings file...');
    return saveJsonFile('config.json', Config.toJson());
  }

  static void loadSettings() {
    printFromMangaReader('Reading settings file...');
    Map<String, dynamic> data = loadJsonFile('config.json');
    Config.fromJson(data);
    printFromMangaReader(Config.toJson());
  }
}
