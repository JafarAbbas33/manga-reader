import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/manga_reader_state.dart';
import 'package:manga_reader/utils.dart';

class MangaFileHandler {
  static late WidgetRef ref;
  static String currentMangaChapterPath = '';
  static String currentMangaChapterDataPath = '';
  static int currentReadingChapterIndex = 0;

  static bool checkIsCurrentMangaPathChapter(String path) {
    return path.contains(RegExp(r'[0-9]'));
  }

  static void _retrieveMangaImagesPathsAndUpdateUI(String path) {
    final mangaImagesList = ref.read(MangaReaderState.mangaImagesListProvider.state);
    final currentMangaTitle = ref.read(MangaReaderState.currentMangaTitleProvider.state);

    List<FileSystemEntity> directoryList = Directory(path).listSync();

    List<String> imageList = directoryList.map((item) => item.path).where((item) => item.endsWith(".jpg") || item.endsWith(".png")).toList(growable: false);

    imageList.sort((a, b) => lexSorter(a, b));

    printFromMangaReader('MFH 0');
    currentMangaTitle.state = path.split('/').last.replaceAll('.cbz', '').replaceAll('.zip', '');
    printFromMangaReader('MFH 1');
    mangaImagesList.state = imageList;
    printFromMangaReader('MFH 2');
  }

  static void setNewMangaChapter(String path) {
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
      throw Exception('Path not found.');
    }
  }

  static void setNewMangaDirectory(String path) {
    final chaptersPaths = ref.read(MangaReaderState.chaptersPathsProvider.state);
    List<FileSystemEntity> directoryList = Directory(path).listSync();
    chaptersPaths.state = directoryList.map((item) => item.path).toList();

    chaptersPaths.state.sort((a, b) => lexSorter(a, b));

    // printFromMangaReader('0' * 80);
    // for (String element in chaptersPaths.state) {
    //   printFromMangaReader(element);
    // }

    currentReadingChapterIndex = 0;

    printFromMangaReader('chaptersPaths.length ------------------------ 0');
    printFromMangaReader(chaptersPaths.state.length);

    setNewMangaChapter(chaptersPaths.state[currentReadingChapterIndex]);
  }

  static void setMangaChapterIndex(int index) {
    final chaptersPaths = ref.read(MangaReaderState.chaptersPathsProvider.state);
    if (chaptersPaths.state.isNotEmpty && index < chaptersPaths.state.length) {
      currentReadingChapterIndex = index;
      setNewMangaChapter(chaptersPaths.state[currentReadingChapterIndex]);
    } // Empty
    else {
      printFromMangaReader('chaptersPaths.length ------------------------');
      printFromMangaReader(chaptersPaths.state.length);
      // requestNextManga();
      throw Exception('Invalid request!');
    }
  }

  static void requestNextManga() {
    final chaptersPaths = ref.read(MangaReaderState.chaptersPathsProvider.state);
    if (chaptersPaths.state.isNotEmpty && currentReadingChapterIndex < chaptersPaths.state.length) {
      currentReadingChapterIndex += 1;
      printFromMangaReader(chaptersPaths.state[currentReadingChapterIndex]);
      printFromMangaReader(chaptersPaths.state);
      setNewMangaChapter(chaptersPaths.state[currentReadingChapterIndex]);
    } // Empty
    else {
      throw Exception('No next chapter found!');
    }
  }
}
