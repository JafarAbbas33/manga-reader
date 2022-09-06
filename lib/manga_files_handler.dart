import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/manga_reader_state.dart';
import 'package:manga_reader/utils.dart';

class MangaFileHandler {
  static late WidgetRef ref;
  static String currentMangaChapterPath = '';
  static String currentMangaChapterDataPath = '';
  static List<String> chaptersPaths = [];
  static int currentReadingChapterIndex = 0;

  static bool checkIsCurrentMangaPathChapter(String path) {
    return path.contains(RegExp(r'[0-9]'));
  }

  static void _retrieveMangaImagesPathsAndUpdateUI(String path) {
    final mangaImagesList = ref.read(MangaReaderState.mangaImagesListProvider.state);
    final currentMangaTitle = ref.read(MangaReaderState.currentMangaTitleProvider.state);

    List<FileSystemEntity> directoryList = Directory(path).listSync();

    // for (FileSystemEntity element in directoryList) {
    //   printFromMangaReader(element);
    // }

    List<String> imageList = directoryList.map((item) => item.path).where((item) => item.endsWith(".jpg") || item.endsWith(".png")).toList(growable: false);

    // printFromMangaReader('0' * 80);
    // printFromMangaReader(path);
    // printFromMangaReader(imageList);

    imageList.sort((a, b) => lexSorter(a, b));

    printFromMangaReader('MFH 0');
    currentMangaTitle.state = path.split('/').last.replaceAll('.cbz', '').replaceAll('.zip', '');
    printFromMangaReader('MFH 1');
    mangaImagesList.state = imageList;
    printFromMangaReader('MFH 2');
  }

  static void setNewMangaChapter(String path) {
    chaptersPaths = [];
    // Check if current manga chapter is Directory
    if (Directory(path).existsSync()) {
      currentMangaChapterPath = path;
      currentMangaChapterDataPath = path;
      _retrieveMangaImagesPathsAndUpdateUI(path);
    }
    // Check if current manga chapter is file
    else if (File(path).existsSync()) {
      printFromMangaReader('2' * 80);
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
    List<FileSystemEntity> directoryList = Directory(path).listSync();
    chaptersPaths = directoryList.map((item) => item.path).toList();

    chaptersPaths.sort((a, b) => lexSorter(a, b));

    // for (String element in chaptersPaths) {
    //   printFromMangaReader(element);
    // }

    // printFromMangaReader('=' * 150);
    // for (FileSystemEntity element in directoryList) {
    //   chaptersPaths.add(element.path);
    // }

    printFromMangaReader('0' * 80);
    for (String element in chaptersPaths) {
      printFromMangaReader(element);
      // printFromMangaReader('0' * 8);
    }

    currentReadingChapterIndex = 0;
    setNewMangaChapter(chaptersPaths[currentReadingChapterIndex]);

    // printFromMangaReader('=' * 150);
  }

  static void setMangaChapterIndex(int index) {
    if (chaptersPaths.isNotEmpty && index < chaptersPaths.length - 1) {
      currentReadingChapterIndex = index;
      setNewMangaChapter(chaptersPaths[currentReadingChapterIndex]);
    } // Empty
    else {
      throw Exception('Invalid request!');
    }
  }

  static void requestNextManga() {
    if (chaptersPaths.isNotEmpty && currentReadingChapterIndex < chaptersPaths.length - 1) {
      currentReadingChapterIndex += 1;
      setNewMangaChapter(chaptersPaths[currentReadingChapterIndex]);
    } // Empty
    else {
      throw Exception('No next chapter found!');
    }
  }
}