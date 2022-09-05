import 'dart:io';

import 'package:flutter/material.dart';

class MangaReaderState {
  MangaReaderState({Key? key});

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

  static String currentMangaTitle = '';
  static List<Image> mangaPagesList = [];
  static Directory mangaImagesDirectory = Directory('/home/jafarabbas33/Documents/New folder');
}
