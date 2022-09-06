// ignore_for_file: prefer_final_fields

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

// =============================================================================================================================

  static void fromJson(Map<String, dynamic> jsonData) {
    printFromMangaReader(jsonData);
    printFromMangaReader(jsonData.runtimeType);

    printFromMangaReader('Updating states state 0');
    ref.read(currentMangaTitleProvider.state).state = jsonData['currentMangaTitle'];
    printFromMangaReader('Updating states state 1');
    ref.read(mangaImagesListProvider.state).state = jsonData['mangaImagesList'];
    printFromMangaReader('Updating states state 2');
  }

  static Map<String, dynamic> toJson() {
    return {
      'currentMangaTitle': ref.read(currentMangaTitleProvider.state).state,
      'mangaImagesDirectory': ref.read(mangaImagesListProvider.state).state,
    };
  }

  static bool saveSettings() {
    try {
      printFromMangaReader('Writing state file...');
      return saveJsonFile('state.json', MangaReaderState.toJson());
    } catch (_) {
      printFromMangaReader('Error while saving state file!'); //: $e');

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
      printFromMangaReader('Error while loading state file!'); //: $e');
      // rethrow;
    }
  }
}
