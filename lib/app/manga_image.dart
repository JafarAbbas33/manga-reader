import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:manga_reader/app/models/config.dart';

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
    final mangaImageSize = ref.watch(Config.mangaImageSizeProvider.state);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 200 * mangaImageSize.state),
      child: Image.file(
        file,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        scale: 0.5,
      ),
    );
  }
}
