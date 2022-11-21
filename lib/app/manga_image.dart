import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:manga_reader/app/models/config.dart';
import 'package:manga_reader/app/models/manga_reader_state.dart';
import 'package:manga_reader/app/utils.dart';

// TODO: Implement settings, fix open directory, try column, implement goto image, implement constant scroll with space, load all

// bool startedCache = false;

class MangaImage extends HookConsumerWidget {
  const MangaImage({Key? key, required this.file, required this.maxWidth}) : super(key: key);

  final int maxWidth;
  final File file;

  Size getNewSize(Size size, double mangaImageSize) {
    double newWidth = size.width * mangaImageSize;
    double widthChangePercent = (newWidth / size.width);
    double newHeight = size.height * widthChangePercent;

    return Size(newWidth.toInt(), newHeight.toInt());
  }

  @override
  Widget build(BuildContext context, ref) {
    final img = Image.file(
      file,
      cacheHeight: 999999999,
      cacheWidth: 999999999,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      scale: 0.5,
    );
    final mangaImageSize = ref.watch(Config.mangaImageSizeProvider.state);

    // if (!startedCache) {
    //   echo('Start caching...');
    //   precacheImage(img.image, context).whenComplete(() => echo('Loaded!'));
    //   echo('Started caching...');
    //   startedCache = true;
    // }

    // precacheImage(img.image, context);
    precacheImage(img.image, context).whenComplete(() {
      MangaReaderState.imagesCached += 1;

      // int mangaImagesListCount = -1;

      // try {
      //   final st = MangaReaderState.mangaImagesListProvider.state;
      //   final mangaImagesList = ref.read(st);
      //   mangaImagesListCount = mangaImagesList.state.length;
      // } catch (_) {
      //   echo('Error while retrieving "mangaImagesListCount".');
      // }

      echo('Images cached: ${MangaReaderState.imagesCached}');
    });

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 200 * mangaImageSize.state),
      child: img,
    );
  }
}
