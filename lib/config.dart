import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/utils.dart';

class Config {
  Config._();
  static late WidgetRef ref;

  static const double _mangaImageSize = 1.5; // 1.5 Default

  static final mangaImageSizeProvider = StateProvider((ref) {
    return _mangaImageSize;
  });

// =============================================================================================================================

  static void fromJson(Map<String, dynamic> jsonData) {
    ref.read(mangaImageSizeProvider.state).state = jsonData['mangaImageSize'];
  }

  static Map<String, dynamic> toJson() {
    return {
      'mangaImageSize': _mangaImageSize,
    };
  }

  static bool saveSettings() {
    try {
      printFromMangaReader('Saving config file...');
      return saveJsonFile('config.json', Config.toJson());
    } catch (_) {
      printFromMangaReader('Error while saving config file!'); //: $e');

      return false;
    }
  }

  static void loadSettings() {
    try {
      printFromMangaReader('Loading config file...');
      Map<String, dynamic> data = loadJsonFile('config.json');
      (data == <String, dynamic>{}) ? null : Config.fromJson(data);
      // printFromMangaReader(Config.toJson());
    } catch (_, e) {
      printFromMangaReader('Error while loading config file: $e');
    }
  }
}
