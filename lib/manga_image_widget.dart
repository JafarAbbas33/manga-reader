import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';

// class MyWidget extends StatefulWidget {
//   const MyWidget({Key? key, required this.file, required this.maxWidth}) : super(key: key);

//   final int maxWidth;
//   final File file;

//   @override
//   State<MyWidget> createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<MyWidget> {
//   @override
//   Widget build(BuildContext context) {
//     // debugPrint('Rebuilding widget page...');
//     Size size = ImageSizeGetter.getSize(FileInput(widget.file));

//     double imageHeight = size.height.toDouble();
//     double imageWidth = size.width.toDouble();

//     Size newSize = getNewSize(size);

<<<<<<< HEAD:lib/manga_image.dart
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
=======
//     debugPrint('---- OLD: $imageHeight || NEW: ${newSize.height} ---- || PATH: ${widget.file.path} || INC: $sizeIncrease');
//     debugPrint('---- SB_W: ${widget.maxWidth.toDouble()} || SB_H: ${newSize.height.toDouble()} ---- || IM_W: ${newSize.width.toDouble()} || IM_H: ${newSize.height.toDouble()}');

//     // return SizedBox(
//     //     width: widget.maxWidth.toDouble(),
//     //     height: size.height.toDouble(),
//     //     child:
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 270),
//       decoration: BoxDecoration(
//         color: Colors.deepPurpleAccent,
//         border: Border.all(),
//       ),
//       child: Image.file(
//         widget.file,
//         // width: newSize.width.toDouble(),
//         // height: newSize.height.toDouble(),
//         scale: sizeIncrease,
//       ),
//     );
//     // );
//   }
// }
>>>>>>> parent of 732ab36... MAJOR: Separated into modules:lib/manga_image_widget.dart

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

class MangaImage extends StatelessWidget {
  const MangaImage({Key? key, required this.file, required this.sizeIncrease, required this.maxWidth}) : super(key: key);

  final int maxWidth;
  final File file;
  final double sizeIncrease;

  @override
  Widget build(BuildContext context) {
    // debugPrint('Rebuilding widget page...');
    Size size = ImageSizeGetter.getSize(FileInput(file));

    double imageHeight = size.height.toDouble();
    double imageWidth = size.width.toDouble();

    // Size newSize = getNewSize(size);

    // debugPrint('OLD: $imageWidth || NEW: ${newSize.width}');

    Image im = Image.file(
      file,
      // width: newSize.width.toDouble(),
      // height: newSize.height.toDouble(),
      scale: sizeIncrease,
    );

    return SizedBox(
      width: maxWidth.toDouble(),
      height: imageHeight,
      child: im,
    );
  }
}
