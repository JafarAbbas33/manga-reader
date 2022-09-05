import 'dart:io';
import 'dart:ui';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:flutter/material.dart';
import 'package:manga_reader/config.dart';
import 'package:manga_reader/key_binding_events.dart';
import 'package:manga_reader/manga_files_handler.dart';
import 'package:manga_reader/manga_reader_app_bar.dart';
import 'package:manga_reader/manga_reader_state.dart';
import 'package:manga_reader/providers.dart';
import 'package:manga_reader/manga_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/utils.dart';

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  Size getNewSize(Size size, double mangaImageSize) {
    double newWidth = size.width * mangaImageSize;
    double widthChangePercent = (newWidth / size.width);
    double newHeight = size.height * widthChangePercent;

    return Size(newWidth.toInt(), newHeight.toInt());
  }

  int getMaxWidth(List<String> imageList, mangaImageSize) {
    int max = 999990;

    for (int i = 0; i < imageList.length; ++i) {
      Size size = ImageSizeGetter.getSize(FileInput(File(imageList[i])));
      Size newSize = getNewSize(size, mangaImageSize);

      if (max > newSize.width) max = newSize.width.toInt();
    }

    return max;
  }

  @override
  Widget build(BuildContext context, ref) {
    debugPrint('Building home page...');

    MangaFileHandler.ref = ref;

    ScrollController scrollController = useScrollController();
    final fullScreen = ref.watch(fullScreenProvider.state);
    final mangaImageSize = ref.watch(mangaImageSizeProvider.state);
    final imageList = ref.watch(mangaImagesListProvider.state);

    // printFromMangaReader(imageList.state);

    useEffect(
      () {
        Config.loadSettings();
        MangaReaderState.loadSettings();
        bindKeys(window, ref, scrollController);

        return null;
      },
      const [],
    );

    int maxWidth = getMaxWidth(imageList.state, mangaImageSize.state);

    return Scaffold(
      floatingActionButton: (!fullScreen.state)
          ? FloatingActionButton(
              onPressed: () {
                printFromMangaReader('Called');

                Config.saveSettings();
                MangaReaderState.saveSettings();

                // ref.refresh(mangaImageSizeProvider);
                // MangaReaderState.saveState();
              },
              child: const Icon(Icons.settings),
            )
          : null,
      backgroundColor: Colors.black,
      appBar: (!fullScreen.state) ? const MangaReaderAppBar().build(context, ref) : null,
      body: DropTarget(
        onDragDone: (detail) {
          printFromMangaReader('path');
          String path = detail.files[0].path;
          printFromMangaReader(path);
          MangaFileHandler.setNewMangaChapter(path);
        },
        child: (imageList.state.isEmpty)
            ? const Align(
                alignment: Alignment.center,
                child: Text(
                  'You can add mangas by dragging and dropping a manga chapter (NOT THE FULL MANGA!)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                controller: scrollController,
                itemCount: imageList.state.length,
                itemBuilder: (context, i) {
                  File file = File(imageList.state[i]);

                  return MangaImage(file: file, maxWidth: maxWidth);
                }),
      ),
    );
  }
}
