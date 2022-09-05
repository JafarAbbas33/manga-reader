import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:manga_reader/providers.dart';

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
    final fullScreen = ref.watch(fullScreenProvider.state);
    final scrollSpeed = ref.watch(scrollSpeedProvider.state);
    final mangaImageSize = ref.watch(mangaImageSizeProvider.state);
    // debugPrint('Rebuilding widget page...');
    Size size = ImageSizeGetter.getSize(FileInput(file));

    double imageHeight = size.height.toDouble();
    double imageWidth = size.width.toDouble();

    Size newSize = getNewSize(size, mangaImageSize.state);

    // debugPrint('---- OLD: $imageHeight || NEW: ${newSize.height} ---- || PATH: ${file.path} || INC: ${mangaImageSize.state}');
    // debugPrint('---- SB_W: ${maxWidth.toDouble()} || SB_H: ${newSize.height.toDouble()} ---- || IM_W: ${newSize.width.toDouble()} || IM_H: ${newSize.height.toDouble()}');

    // return SizedBox(
    //     width: widget.maxWidth.toDouble(),
    //     height: size.height.toDouble(),
    //     child:
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 200 * mangaImageSize.state),
      // decoration: BoxDecoration(
      //   color: Colors.deepPurpleAccent,
      //   border: Border.all(),
      // ),
      child: Image.file(
        file,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        // width: newSize.width.toDouble(),
        // height: newSize.height.toDouble(),
        scale: 0.5,
      ),
    );
    // );
  }
}

// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------

// class _MangaImage extends StatelessWidget {
//   const _MangaImage({Key? key, required this.file, required this.maxWidth}) : super(key: key);

//   final int maxWidth;
//   final File file;

//   @override
//   Widget build(BuildContext context) {
//     // debugPrint('Rebuilding widget page...');
//     Size size = ImageSizeGetter.getSize(FileInput(file));

//     double imageHeight = size.height.toDouble();
//     double imageWidth = size.width.toDouble();

//     Size newSize = getNewSize(size);

//     debugPrint('OLD: $imageWidth || NEW: ${newSize.width}');

//     return SizedBox(
//       width: maxWidth.toDouble(),
//       height: imageHeight,
//       child: Image.file(
//         file,
//         width: newSize.width.toDouble(),
//         height: newSize.height.toDouble(),
//         scale: sizeIncrease,
//       ),
//     );
//   }
// }

