import 'dart:io';
import 'dart:ui';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:flutter/material.dart';
import 'package:manga_reader/app/services/key_binding_events.dart';
import 'package:manga_reader/app/manga_image.dart';
import 'package:manga_reader/app/manga_reader_app_bar.dart';
import 'package:manga_reader/app/views/settings_page.dart';
import 'package:manga_reader/app/utils.dart';
import 'package:manga_reader/app/models/config.dart';
import 'package:manga_reader/app/models/manga_files_handler.dart';
import 'package:manga_reader/app/models/manga_reader_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
      // echo(File(imageList[i]));
      // echo(imageList[i]);
      // echo('=' * 80);
      Size size = ImageSizeGetter.getSize(FileInput(File(imageList[i])));
      Size newSize = getNewSize(size, mangaImageSize);

      if (max > newSize.width) max = newSize.width.toInt();
    }

    return max;
  }

  @override
  Widget build(BuildContext context, ref) {
    contextInUtilsFile = context;
    refInUtilsFile = ref;
    MangaFileHandler.ref = ref;
    MangaReaderState.ref = ref;
    Config.ref = ref;

    echo('Building home page...');

    ScrollController scrollController = useScrollController();

    final fullScreen = ref.watch(Config.fullScreenProvider.state);
    final mangaImageSize = ref.watch(Config.mangaImageSizeProvider.state);
    final imageList = ref.watch(MangaReaderState.mangaImagesListProvider.state);
    ref.watch(MangaReaderState.currentMangaChapterIndexProvider.state);

    bool dragAndDropDialogOpen = false;

    // echo(imageList.state);

    useEffect(
      () {
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
                      return const SettingsDialog();
                    });
              },
              child: const Icon(Icons.settings),
            )
          : null,
      backgroundColor: Colors.black,
      drawer: const _Drawer(),
      appBar: (!fullScreen.state) ? const MangaReaderAppBar().build(context, ref) : null,
      body: DropTarget(
        onDragEntered: (details) {
          // echo('Opening drag & Drop...');

          if (!dragAndDropDialogOpen) {
            showDialog(
                context: context,
                builder: (_) {
                  dragAndDropDialogOpen = true;
                  return const _DragAndDropDialog();
                });
          }
        },
        onDragExited: (details) {
          if (dragAndDropDialogOpen) {
            // echo('Closing drag & Drop...');
            Navigator.of(context).pop();
            dragAndDropDialogOpen = false;
          }
        },
        onDragDone: (detail) {
          String path = detail.files[0].path;
          if (detail.localPosition.dx < MediaQuery.of(context).size.width / 2) {
            echo('Dropped on left side! Setting new manga chapter...');
            MangaFileHandler.setNewMangaChapter(path);
          } //
          else {
            echo('Dropped on right side! Setting new manga directory...');
            MangaFileHandler.setNewMangaDirectory(path);
          }
          // echo('${MediaQuery.of(context).size.width}||${detail.localPosition.dx}');

          echo('Drag done. Closing drag & Drop...');
        },
        child: (imageList.state.isEmpty)
            ? const Align(
                alignment: Alignment.center,
                child: Text(
                  'You can add mangas by dragging and dropping!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              )
            :
            // MediaQuery.removePadding(
            //     context: context,
            //     removeTop: true,
            //     child:
            ListView(
                cacheExtent: 10000,
                shrinkWrap: true,
                controller: scrollController,
                // padding: EdgeInsets.zero,
                children: [
                  ...imageList.state.map((e) {
                    // echo('Loading: $e');
                    return MangaImage(file: File(e), maxWidth: maxWidth);
                  }).toList(),
                ],
                // File file = File(imageList.state[i]);

                // return ;
              ),
        // )
        // ListView.builder(
        //     cacheExtent: 4000,
        //     shrinkWrap: true,
        //     controller: scrollController,
        //     itemCount: imageList.state.length,
        //     itemBuilder: (context, i) {
        //       File file = File(imageList.state[i]);

        //       return MangaImage(file: file, maxWidth: maxWidth);
        //     }),
      ),
    );
  }
}

class _DragAndDropDialog extends StatelessWidget {
  const _DragAndDropDialog({Key? key}) : super(key: key);

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

class _DragAndDropDialogOptions extends StatelessWidget {
  const _DragAndDropDialogOptions({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border.all(width: 3, color: Colors.blueAccent), borderRadius: BorderRadius.circular(20)),
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

class _Drawer extends ConsumerWidget {
  const _Drawer();

  @override
  Widget build(BuildContext context, ref) {
    final chaptersPaths = ref.read(MangaReaderState.chaptersPathsProvider.state).state;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const ColoredBox(
            color: Colors.blue,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
              child: Text('Select chapter to open'),
            ),
          ),
          ...chaptersPaths.map((e) => ListTile(
                title: Text(e.split('/').last.replaceAll('.cbz', '').replaceAll('.zip', '')),
                // tileColor: (MangaFileHandler.currentMangaChapterPath == e) ? Colors.blue : null,
                onTap: () {
                  MangaFileHandler.setMangaChapterIndex(chaptersPaths.indexOf(e));
                },
              )),

          // ListTile(
          //   title: const Text('Item 2'),
          //   onTap: () {
          //     // Update the state of the app.
          //     // ...
          //   },
          // ),
        ],
      ),
    );
  }
}
