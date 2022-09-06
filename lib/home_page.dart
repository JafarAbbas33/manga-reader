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
    Config.ref = ref;

    ScrollController scrollController = useScrollController();
    final fullScreen = ref.watch(fullScreenProvider.state);
    final mangaImageSize = ref.watch(Config.mangaImageSizeProvider.state);
    final imageList = ref.watch(mangaImagesListProvider.state);

    bool dragAndDropDialogOpen = false;

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
                showDialog(
                    context: context,
                    builder: (_) {
                      return const PopUpDialog();
                    });
              },
              child: const Icon(Icons.settings),
            )
          : null,
      backgroundColor: Colors.black,
      appBar: (!fullScreen.state) ? const MangaReaderAppBar().build(context, ref) : null,
      body: DropTarget(
        onDragEntered: (details) {
          // printFromMangaReader('Opening drag & Drop...');

          if (!dragAndDropDialogOpen) {
            showDialog(
                context: context,
                builder: (_) {
                  dragAndDropDialogOpen = true;
                  return const DragAndDropDialog();
                });
          }
        },
        onDragExited: (details) {
          if (dragAndDropDialogOpen) {
            // printFromMangaReader('Closing drag & Drop...');
            Navigator.of(context).pop();
            dragAndDropDialogOpen = false;
          }
        },
        onDragDone: (detail) {
          String path = detail.files[0].path;
          if (detail.localPosition.dx < MediaQuery.of(context).size.width / 2) {
            printFromMangaReader('Dropped on left side! Setting new manga chapter...');
            MangaFileHandler.setNewMangaChapter(path);
          } //
          else {
            printFromMangaReader('Dropped on right side! Setting new manga directory...');
            MangaFileHandler.setNewMangaDirectory(path);
          }
          // printFromMangaReader('${MediaQuery.of(context).size.width}||${detail.localPosition.dx}');

          printFromMangaReader('Drag done. Closing drag & Drop...');
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
                cacheExtent: 4000,
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

class DragAndDropDialog extends StatelessWidget {
  const DragAndDropDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: GridView.count(
        // childAspectRatio: 1,
        crossAxisCount: 2,
        children: const [
          _DragAndDropDialogOptions(title: 'Drop Manga chapter here'),
          _DragAndDropDialogOptions(title: 'Drop full manga folder here'),
        ],
      ),
    );
  }
}

class PopUpDialog extends StatelessWidget {
  const PopUpDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 380,
        height: 380,
        child: Column(
          children: [
            _PopUpDialogOptions(
                title: 'Load config from file',
                callback: () {
                  Config.loadSettings();
                }),
            _PopUpDialogOptions(
                title: 'Load manga reader state from file',
                callback: () {
                  MangaReaderState.loadSettings();
                }),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text("Loading..."),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopUpDialogOptions extends StatelessWidget {
  const _PopUpDialogOptions({Key? key, required this.title, required this.callback}) : super(key: key);

  final String title;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.blueAccent), borderRadius: BorderRadius.circular(20)),
        child: TextButton(
          onPressed: callback(),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _DragAndDropDialogOptions extends StatelessWidget {
  const _DragAndDropDialogOptions({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.blueAccent), borderRadius: BorderRadius.circular(20)),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
