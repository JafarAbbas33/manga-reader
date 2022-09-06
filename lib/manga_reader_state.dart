// ignore_for_file: prefer_final_fields, prefer_const_declarations

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/utils.dart';

class MangaReaderState {
  MangaReaderState._();

  static late WidgetRef ref;

  static const String _currentMangaTitle = 'Manga Reader';
  static final currentMangaTitleProvider = StateProvider((ref) {
    return _currentMangaTitle;
  });

  static final List<String> _mangaImagesList = [];
  static final mangaImagesListProvider = StateProvider((ref) {
    return _mangaImagesList;
  });

  static List<String> _chaptersPaths = [];
  static final chaptersPathsProvider = StateProvider((ref) {
    return _chaptersPaths;
  });

  static final int _currentMangaChapterIndex = 0;
  static final currentMangaChapterIndexProvider = StateProvider((ref) {
    return _currentMangaChapterIndex;
  });

// =============================================================================================================================

  static void fromJson(Map<String, dynamic> jsonData) {
    // printFromMangaReader(jsonData);
    // printFromMangaReader(jsonData.runtimeType);

    // printFromMangaReader('Updating states state 0');
    ref.read(currentMangaChapterIndexProvider.state).state = jsonData['currentMangaChapterIndex'];
    ref.read(currentMangaTitleProvider.state).state = jsonData['currentMangaTitle'];
    // printFromMangaReader('Updating states state 1');

    printFromMangaReader('Printing...');
    // var t = jsonData['mangaImagesList'].map((item) => item.toString()).toList(); // as List<String>;

    // final t1 = (;

    // printFromMangaReader(t1.runtimeType);

    ref.read(chaptersPathsProvider.state).state = (jsonData["chaptersPaths"] as List).map((e) => e as String).toList();
    ref.read(mangaImagesListProvider.state).state = (jsonData["mangaImagesList"] as List).map((e) => e as String).toList();
    // printFromMangaReader('Updating states state 2');
  }

  static Map<String, dynamic> toJson() {
    return {
      'currentMangaChapterIndex': ref.read(currentMangaChapterIndexProvider.state).state,
      'currentMangaTitle': ref.read(currentMangaTitleProvider.state).state,
      'mangaImagesList': ref.read(mangaImagesListProvider.state).state,
      'chaptersPaths': ref.read(chaptersPathsProvider.state).state,
    };
  }

  static bool saveSettings() {
    try {
      printFromMangaReader('Saving state file...');
      return saveJsonFile('state.json', MangaReaderState.toJson());
    } catch (_) {
      printFromMangaReader('Error while saving state file!'); //: $e');

      return false;
    }
  }

  static void loadSettings() {
    // try {
    printFromMangaReader('Loading state file...');
    Map<String, dynamic> data = loadJsonFile('state.json');

    (data.entries.isEmpty) ? printFromMangaReader('No state file found.') : MangaReaderState.fromJson(data);
    // printFromMangaReader(MangaReaderState.toJson());
    // } catch (_) {
    //   printFromMangaReader('Error while loading state file!'); //: $e');
    //   // rethrow;
    // }
  }
}
