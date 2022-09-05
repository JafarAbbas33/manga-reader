import 'dart:io';

import 'package:flutter/material.dart';

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

  static String currentMangaTitle = '';
  static List<Image> mangaPagesList = [];
  static Directory mangaImagesDirectory = Directory('/home/jafarabbas33/Documents/New folder');

  // factory Config22.fromJson(Map<String, dynamic> json) {
  //   Config22._photoDir = json['name'] as Directory;

  //   return Config22();
  // }

  // static Map<String, dynamic> toJson() {
  //   return {
  //     'name': Config22._photoDir.path,
  //   };
  // }
}
