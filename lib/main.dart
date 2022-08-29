import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:flutter/material.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  final Directory _photoDir = Directory('/home/jafarabbas33/Documents/New folder');
  List<Image> mangaPagesList = [];
  late ScrollController scrollController;

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
    int max = 0;
    int width = 0;

    for (int i = 0; i < imageList.length; ++i) {
      width = ImageSizeGetter.getSize(FileInput(File(imageList[i]))).width;
      if (max < width) max = width;
      //Image.file(File(imageList[i])).width.toString());
    }

    return max;
  }

  @override
  void initState() {
    scrollController = ScrollController();
    // int currentScrollPosition

    window.onKeyData = (final keyData) {
      if (keyData.logical == LogicalKeyboardKey.space.keyId && keyData.type == KeyEventType.down) {
        scrollController.animateTo(scrollController.position.pixels + 200.0, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
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
    List<String> imageList = _photoDir.listSync().map((item) => item.path).where((item) => item.endsWith(".jpg") || item.endsWith(".png")).toList(growable: false);

    imageList.sort((a, b) => lexSorter(a, b));

    // debugPrint(imageList.toString());
    int maxWidth = getMaxWidth(imageList);
    // debugPrint(maxWidth.toString());

    // -----------------------------------------------------------------------------------------

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Manga Reader'),
        ),
        body: SizedBox(
            width: maxWidth.toDouble(),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                  controller: scrollController,
                  itemCount: imageList.length,
                  itemBuilder: (context, i) {
                    return Image.file(File(imageList[i]));
                  }),
            )));
  }
}
