import 'package:manga_reader/utils.dart';

class Config {
  Config._();
  static double mangaImageSize = 1.5; // 1.5 Default

// =============================================================================================================================

  static void fromJson(Map<String, dynamic> jsonData) {
    mangaImageSize = jsonData['mangaImageSize'];
  }

  static Map<String, dynamic> toJson() {
    return {
      'mangaImageSize': mangaImageSize,
    };
  }

  static bool saveSettings() {
    try {
      printFromMangaReader('Saving settings file...');
      return saveJsonFile('config.json', Config.toJson());
    } catch (_, e) {
      printFromMangaReader('Error while saving settings file: $e');

      return false;
    }
  }

  static void loadSettings() {
    try {
      printFromMangaReader('Loading settings file...');
      Map<String, dynamic> data = loadJsonFile('config.json');
      (data == <String, dynamic>{}) ? null : Config.fromJson(data);
      // printFromMangaReader(Config.toJson());
    } catch (_, e) {
      printFromMangaReader('Error while loading settings file: $e');
    }
  }
}
