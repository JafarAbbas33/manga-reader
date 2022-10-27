// ignore_for_file: prefer_final_fields, prefer_const_declarations

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/app/utils.dart';

class MangaReaderState {
  MangaReaderState._();

  static late WidgetRef ref;
  static List<String> arguments = [];

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
    // echo(jsonData);
    // echo(jsonData.runtimeType);

    // echo('Updating states state 0');
    ref.read(currentMangaChapterIndexProvider.state).state = jsonData['currentMangaChapterIndex'];
    ref.read(currentMangaTitleProvider.state).state = jsonData['currentMangaTitle'];
    // echo('Updating states state 1');

    echo('Printing...');
    // var t = jsonData['mangaImagesList'].map((item) => item.toString()).toList(); // as List<String>;

    // final t1 = (;

    // echo(t1.runtimeType);

    ref.read(chaptersPathsProvider.state).state = (jsonData["chaptersPaths"] as List).map((e) => e as String).toList();
    // ref.read(mangaImagesListProvider.state).state = (jsonData["mangaImagesList"] as List).map((e) => e as String).toList();
    // echo('Updating states state 2');
  }

  static Map<String, dynamic> toJson() {
    return {
      'currentMangaChapterIndex': ref.read(currentMangaChapterIndexProvider.state).state,
      'currentMangaTitle': ref.read(currentMangaTitleProvider.state).state,
      // 'mangaImagesList': ref.read(mangaImagesListProvider.state).state,
      'chaptersPaths': ref.read(chaptersPathsProvider.state).state,
    };
  }

  static bool saveSettings() {
    try {
      echo('Saving state file...');
      return saveJsonFile('state.json', MangaReaderState.toJson());
    } catch (_) {
      showSnackbar('Error while saving state file!'); //: $e');

      return false;
    }
  }

  static void loadSettings() {
    try {
      echo('Loading state file...');
      Map<String, dynamic> data = loadJsonFile('state.json');

      (data.entries.isEmpty) ? echo('No state file found.') : MangaReaderState.fromJson(data);
      // echo(MangaReaderState.toJson());
    } catch (_) {
      showSnackbar('Error while loading state file!'); //: $e');
      // rethrow;
    }
  }
}
