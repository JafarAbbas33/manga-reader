import 'dart:io';
import 'dart:ui';
import 'package:archive/archive_io.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:flutter/material.dart';
import 'package:manga_reader/key_binding_events.dart';
import 'package:manga_reader/providers.dart';
import 'package:manga_reader/manga_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// -------------------------------------------------------------------------------------------------------------------------------

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  int toInteger(String value) {
    return int.parse(value.split('/').last.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  int lexSorter(String a, String b) {
    int aInt = int.parse(a.split('/').last.replaceAll(RegExp(r'[^0-9]'), ''));
    int bInt = int.parse(b.split('/').last.replaceAll(RegExp(r'[^0-9]'), ''));
    return aInt.compareTo(bInt);
  }

  Size getNewSize(Size size, double mangaImageSize) {
    double newWidth = size.width * mangaImageSize;
    double widthChangePercent = (newWidth / size.width);
    double newHeight = size.height * widthChangePercent;

    return Size(newWidth.toInt(), newHeight.toInt());
  }

  int getMaxWidth(List<String> imageList, mangaImageSize) {
    // final size = ImageSizeGetter.getSize(FileInput(File(imageList[0])));
    int max = 999990;
    // int width = 0;

    for (int i = 0; i < imageList.length; ++i) {
      Size size = ImageSizeGetter.getSize(FileInput(File(imageList[i])));
      Size newSize = getNewSize(size, mangaImageSize);

      // double newWidth = size.width * sizeIncrease;
      // double widthChangePercent = (newWidth / size.width);
      // double newHeight = size.height * widthChangePercent;

      // final double aspectRatio = size.height / size.width;
      // int newWidth = size.height

      // double imageHeight = size.height.toDouble();
      // double imageWidth = size.width.toDouble();

      if (max > newSize.width) max = newSize.width.toInt();
      //Image.file(File(imageList[i])).width.toString());
    }

    return max;
  }

  @override
  Widget build(BuildContext context, ref) {
    ScrollController scrollController = useScrollController();
    final mangaImagesDirectory = ref.watch(mangaImagesDirectoryProvider.state);
    final fullScreen = ref.watch(fullScreenProvider.state);
    final mangaImageSize = ref.watch(mangaImageSizeProvider.state);

    useEffect(
      () {
        bindKeys(window, ref, scrollController);

        return null;
      },
      const [],
    );

    debugPrint('Rebuilding home page...');
    List<String> imageList = mangaImagesDirectory.state.listSync().map((item) => item.path).where((item) => item.endsWith(".jpg") || item.endsWith(".png")).toList(growable: false);

    imageList.sort((a, b) => lexSorter(a, b));

    // debugPrint(imageList.toString());
    int maxWidth = getMaxWidth(imageList, mangaImageSize.state);
    // debugPrint(maxWidth.toString());

    // -----------------------------------------------------------------------------------------

    debugPrint('---- MINUS: ${MediaQuery.of(context).size.width - maxWidth.toDouble()} || NEW: ${MediaQuery.of(context).size.width} ---- || PATH: ${maxWidth.toDouble()}');

    // Image image = Image.file(File(imageList[0]), scale: 1.9);
    // Completer<Size> completer = Completer();
    // image.image.resolve(const ImageConfiguration()).addListener(
    //   ImageStreamListener(
    //     (ImageInfo image, bool synchronousCall) {
    //       var myImage = image.image;
    //       Size size = Size(myImage.width, myImage.height);
    //       debugPrint('--00-- ${myImage.width} || ${myImage.height}');
    //       completer.complete(size);
    //     },
    //   ),
    // );

    // debugPrint('--000-- ${image.width} || ${image.height}');

    return Scaffold(
        floatingActionButton: (!fullScreen.state)
            ? FloatingActionButton(
                onPressed: () {
                  // setState(() {});
                  if (mangaImagesDirectory.state.existsSync() && mangaImagesDirectory.state.path.startsWith('/tmp')) {
                    // _photoDir.delete(recursive: true);
                  }
                },
                child: const Icon(Icons.settings),
              )
            : null,
        backgroundColor: Colors.black,
        appBar: (!fullScreen.state)
            ? AppBar(
                title: const Text('Manga Reader'),
                leading: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: (() async {
                    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
                    String path = data?.text ?? '';

                    String snackBarText = 'Exists!';
                    if (await Directory(path).exists()) {
                      snackBarText = 'Exists!';

                      // setState(() {
                      mangaImagesDirectory.state = Directory(path);
                      // });

                      // if (text.endsWith('cbz') || text.endsWith('jpg')) {
                      //   // debugPrint(text.endsWith('cbz') || text.endsWith('cbz'));
                      // }
                    } else if (File(path).existsSync()) {
                      if (path.endsWith('.cbz')) {
                        final bytes = File(path).readAsBytesSync();

                        // Decode the Zip file
                        final archive = ZipDecoder().decodeBytes(bytes);

                        // Extract the contents of the Zip archive to disk.
                        final String targetDir = '/tmp/manga_reader/${path.split('/').last}';
                        for (final file in archive) {
                          final filename = file.name;
                          String targetPath = '$targetDir/$filename';
                          if (file.isFile) {
                            final data = file.content as List<int>;
                            File(targetPath)
                              ..createSync(recursive: true)
                              ..writeAsBytesSync(data);
                          } else {
                            Directory dir = Directory(targetPath);
                            dir.create(recursive: true);
                            debugPrint('888: ${dir.absolute.path}');
                            snackBarText = 'Does not exist!';
                          }
                          // setState(() {
                          mangaImagesDirectory.state = Directory(targetDir);
                          // });
                        }
                        // path =
                      }
                    } else {
                      snackBarText = 'Does not exist!';
                    }
                    SnackBar snackBar = SnackBar(
                      content: Text(snackBarText),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }),
                ),
              )
            : null,
        body: DropTarget(
            onDragDone: (detail) {
              // setState(() {
              debugPrint('*************************************************************${detail.files.length}');
              debugPrint('*************************************************************${detail.files[0].path}');
              // });
            },
            // color: Colors.blueGrey,
            // padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width - maxWidth.toDouble()),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child:
                  // Expanded(
                  //   child:
                  ListView.builder(
                      shrinkWrap: true,
                      controller: scrollController,
                      itemCount: imageList.length,
                      itemBuilder: (context, i) {
                        File file = File(imageList[i]);

                        return MangaImage(file: file, maxWidth: maxWidth);
                        // return Image.file(
                        //   file,
                        //   scale: sizeIncrease,
                        // );
                      }),
              // )
            )));
  }
}
