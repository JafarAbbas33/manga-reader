import 'dart:io';
import 'dart:ui';
import 'package:archive/archive_io.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/services.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// -------------------------------------------------------------------------------------------------------------------------------

double sizeIncrease = 1.5;

class _MyHomePageState extends State<MyHomePage> {
  Directory _photoDir = Directory('/home/jafarabbas33/Documents/New folder');
  double scrollSpeed = 500.0;
  List<Image> mangaPagesList = [];
  late ScrollController scrollController;
  bool isFullScreen = false;

  int toInteger(String value) {
    return int.parse(value.split('/').last.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  int lexSorter(String a, String b) {
    int aInt = int.parse(a.split('/').last.replaceAll(RegExp(r'[^0-9]'), ''));
    int bInt = int.parse(b.split('/').last.replaceAll(RegExp(r'[^0-9]'), ''));
    return aInt.compareTo(bInt);
  }

  int getMaxWidth(List<String> imageList) {
    // final size = ImageSizeGetter.getSize(FileInput(File(imageList[0])));
    int max = 999990;
    int width = 0;

    for (int i = 0; i < imageList.length; ++i) {
      Size size = ImageSizeGetter.getSize(FileInput(File(imageList[i])));
      Size newSize = getNewSize(size);

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
  void initState() {
    scrollController = ScrollController();
    // int currentScrollPosition

    window.onKeyData = (final keyData) {
      // debugPrint('${keyData.logical} ******************************************');

      if (keyData.logical == LogicalKeyboardKey.space.keyId && keyData.type == KeyEventType.down) {
        scrollController.animateTo(scrollController.position.pixels + scrollSpeed, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
        return true;
      }
      // '+' pressed
      else if (keyData.logical == 61 && keyData.type == KeyEventType.down) {
        setState(() {
          debugPrint('+ Pressed');
          sizeIncrease -= 0.1;
        });
      }
      // 'f' pressed
      else if (keyData.logical == 102 && keyData.type == KeyEventType.down) {
        debugPrint('f Pressed');
        WindowManager.instance.isFullScreen().then((value) {
          isFullScreen = !value;
          WindowManager.instance.setFullScreen(!value);
        });
      }
      // '-' pressed
      else if (keyData.logical == 45 && keyData.type == KeyEventType.down) {
        setState(() {
          debugPrint('- Pressed');
          sizeIncrease += 0.1;
        });

        return true;
      }
      return false;
    };

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Rebuilding home page...');
    List<String> imageList = _photoDir.listSync().map((item) => item.path).where((item) => item.endsWith(".jpg") || item.endsWith(".png")).toList(growable: false);

    imageList.sort((a, b) => lexSorter(a, b));

    // debugPrint(imageList.toString());
    int maxWidth = getMaxWidth(imageList);
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
        floatingActionButton: (!isFullScreen)
            ? FloatingActionButton(
                onPressed: () {
                  // setState(() {});
                  if (_photoDir.existsSync() && _photoDir.path.startsWith('/tmp')) {
                    // _photoDir.delete(recursive: true);
                  }
                },
                child: const Icon(Icons.settings),
              )
            : null,
        backgroundColor: Colors.black,
        appBar: (!isFullScreen)
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

                      setState(() {
                        _photoDir = Directory(path);
                      });

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
                          setState(() {
                            _photoDir = Directory(targetDir);
                          });
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
              setState(() {
                debugPrint('*************************************************************${detail.files.length}');
                debugPrint('*************************************************************${detail.files[0].path}');
              });
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

                        return MyWidget(file: file, maxWidth: maxWidth);
                        // return Image.file(
                        //   file,
                        //   scale: sizeIncrease,
                        // );
                      }),
              // )
            )));
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key, required this.file, required this.maxWidth}) : super(key: key);

  final int maxWidth;
  final File file;

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    // debugPrint('Rebuilding widget page...');
    Size size = ImageSizeGetter.getSize(FileInput(widget.file));

    double imageHeight = size.height.toDouble();
    double imageWidth = size.width.toDouble();

    Size newSize = getNewSize(size);

    debugPrint('---- OLD: $imageHeight || NEW: ${newSize.height} ---- || PATH: ${widget.file.path} || INC: $sizeIncrease');
    debugPrint('---- SB_W: ${widget.maxWidth.toDouble()} || SB_H: ${newSize.height.toDouble()} ---- || IM_W: ${newSize.width.toDouble()} || IM_H: ${newSize.height.toDouble()}');

    // return SizedBox(
    //     width: widget.maxWidth.toDouble(),
    //     height: size.height.toDouble(),
    //     child:
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 200 * sizeIncrease),
      // decoration: BoxDecoration(
      //   color: Colors.deepPurpleAccent,
      //   border: Border.all(),
      // ),
      child: Image.file(
        widget.file,
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

class _MangaImage extends StatelessWidget {
  const _MangaImage({Key? key, required this.file, required this.maxWidth}) : super(key: key);

  final int maxWidth;
  final File file;

  @override
  Widget build(BuildContext context) {
    // debugPrint('Rebuilding widget page...');
    Size size = ImageSizeGetter.getSize(FileInput(file));

    double imageHeight = size.height.toDouble();
    double imageWidth = size.width.toDouble();

    Size newSize = getNewSize(size);

    debugPrint('OLD: $imageWidth || NEW: ${newSize.width}');

    return SizedBox(
      width: maxWidth.toDouble(),
      height: imageHeight,
      child: Image.file(
        file,
        width: newSize.width.toDouble(),
        height: newSize.height.toDouble(),
        scale: sizeIncrease,
      ),
    );
  }
}

Size getNewSize(Size size) {
  double newWidth = size.width * sizeIncrease;
  double widthChangePercent = (newWidth / size.width);
  double newHeight = size.height * widthChangePercent;

  return Size(newWidth.toInt(), newHeight.toInt());
}
