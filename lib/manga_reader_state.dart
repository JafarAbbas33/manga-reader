import 'package:manga_reader/utils.dart';

class MangaReaderState {
  MangaReaderState._();

  static double maxScrollPosition = 0;
  static double _currentScrollPosition = 0;

  static set currentScrollPosition(double position) {
    if (maxScrollPosition < position) {
      maxScrollPosition = position;
    }

    _currentScrollPosition = position;
  }

  static double get currentScrollPosition {
    return _currentScrollPosition;
  }

  static double fewSecondsBeforeScrollPosition = 0;

  static String currentMangaTitle = 'Manga Reader';
  static List<String> mangaImagesList = [];

// =============================================================================================================================

  static void fromJson(Map<String, dynamic> jsonData) {
    printFromMangaReader(jsonData);
    printFromMangaReader(jsonData.runtimeType);

    maxScrollPosition = jsonData['maxScrollPosition'];
    _currentScrollPosition = jsonData['_currentScrollPosition'];
    maxScrollPosition = jsonData['maxScrollPosition'];
    _currentScrollPosition = jsonData['_currentScrollPosition'];
    fewSecondsBeforeScrollPosition = jsonData['fewSecondsBeforeScrollPosition'];
    currentMangaTitle = jsonData['currentMangaTitle'];
    mangaImagesList = jsonData['mangaImagesList'];
  }

  static Map<String, dynamic> toJson() {
    return {
      'maxScrollPosition': maxScrollPosition,
      '_currentScrollPosition': _currentScrollPosition,
      'fewSecondsBeforeScrollPosition': fewSecondsBeforeScrollPosition,
      'currentMangaTitle': currentMangaTitle,
      'mangaImagesDirectory': mangaImagesList,
    };
  }

  static bool saveSettings() {
    try {
      printFromMangaReader('Writing state file...');
      return saveJsonFile('state.json', MangaReaderState.toJson());
    } catch (_, e) {
      printFromMangaReader('Error while saving state file: $e');

      return false;
    }
  }

  static void loadSettings() {
    try {
      printFromMangaReader('Reading state file...');
      Map<String, dynamic> data = loadJsonFile('state.json');

      (data.entries.isEmpty) ? printFromMangaReader('No state file found.') : MangaReaderState.fromJson(data);
      // printFromMangaReader(MangaReaderState.toJson());
    } catch (_) {
      printFromMangaReader('Error while loading state file'); //: $e');
      // rethrow;
    }
  }
}
