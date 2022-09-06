import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/manga_reader_state.dart';
import 'package:manga_reader/utils.dart';

class MangaFileHandler {
  static late WidgetRef ref;
  static String currentMangaChapterPath = '';
  static String currentMangaChapterDataPath = '';

  static bool checkIsCurrentMangaPathChapter(String path) {
    return path.contains(RegExp(r'[0-9]'));
  }

  static void _retrieveMangaImagesPathsAndUpdateUI(String path) {
    final mangaImagesList = ref.read(MangaReaderState.mangaImagesListProvider.state);
    final currentMangaTitle = ref.read(MangaReaderState.currentMangaTitleProvider.state);

    List<FileSystemEntity> directoryList = Directory(path).listSync();

    List<String> imageList = directoryList.map((item) => item.path).where((item) => item.endsWith(".jpg") || item.endsWith(".png")).toList(growable: false);

    imageList.sort((a, b) => lexSorter(a, b));

    currentMangaTitle.state = path.split('/').last.replaceAll('.cbz', '').replaceAll('.zip', '');
    mangaImagesList.state = imageList;

    saveFiles();
  }

  static void setNewMangaChapter(String path) {
    final currentMangaChapterIndex = ref.read(MangaReaderState.currentMangaChapterIndexProvider.state);
    printFromMangaReader(currentMangaChapterIndex.state);
    // final chaptersPaths = ref.read(MangaReaderState.chaptersPathsProvider.state);
    // chaptersPaths.state = [];
    // Check if current manga chapter is Directory
    if (Directory(path).existsSync()) {
      currentMangaChapterPath = path;
      currentMangaChapterDataPath = path;
      _retrieveMangaImagesPathsAndUpdateUI(path);
    }
    // Check if current manga chapter is file
    else if (File(path).existsSync()) {
      currentMangaChapterPath = path;
      currentMangaChapterDataPath = extractMangaChapter(path);
      _retrieveMangaImagesPathsAndUpdateUI(currentMangaChapterDataPath);
    }
    // Path not found
    else {
      showSnackbar('Path not found.');
    }
  }

  static void setNewMangaDirectory(String path) {
    final currentMangaChapterIndex = ref.read(MangaReaderState.currentMangaChapterIndexProvider.state);
    final chaptersPaths = ref.read(MangaReaderState.chaptersPathsProvider.state);

    List<FileSystemEntity> directoryList = Directory(path).listSync();
    chaptersPaths.state = directoryList.map((item) => item.path).toList();

    chaptersPaths.state.sort((a, b) => lexSorter(a, b));

    // printFromMangaReader('0' * 80);
    // for (String element in chaptersPaths.state) {
    //   printFromMangaReader(element);
    // }

    currentMangaChapterIndex.state = 0;

    // printFromMangaReader('chaptersPaths.length ------------------------ 0');
    // printFromMangaReader(chaptersPaths.state.length);

    setNewMangaChapter(chaptersPaths.state[currentMangaChapterIndex.state]);
  }

  static void setMangaChapterIndex(int index) {
    final currentMangaChapterIndex = ref.read(MangaReaderState.currentMangaChapterIndexProvider.state);
    final chaptersPaths = ref.read(MangaReaderState.chaptersPathsProvider.state);

    if (chaptersPaths.state.isNotEmpty && index < chaptersPaths.state.length) {
      currentMangaChapterIndex.state = index;
      setNewMangaChapter(chaptersPaths.state[currentMangaChapterIndex.state]);
    } // Empty
    else {
      printFromMangaReader('chaptersPaths.length ------------------------');
      // printFromMangaReader(chaptersPaths.state.length);
      // requestNextManga();
      showSnackbar('Invalid request!');
    }
  }

  static void requestNextManga() {
    final currentMangaChapterIndex = ref.read(MangaReaderState.currentMangaChapterIndexProvider.state);
    final chaptersPaths = ref.read(MangaReaderState.chaptersPathsProvider.state);

    if (chaptersPaths.state.isNotEmpty && currentMangaChapterIndex.state < chaptersPaths.state.length) {
      currentMangaChapterIndex.state += 1;
      // printFromMangaReader(chaptersPaths.state[currentReadingChapterIndex]);
      // printFromMangaReader(chaptersPaths.state);
      setNewMangaChapter(chaptersPaths.state[currentMangaChapterIndex.state]);
    } // Empty
    else {
      showSnackbar('No next chapter found!');
    }
  }
}
