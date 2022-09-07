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
      // printFromMangaReader(File(imageList[i]));
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

    debugPrint('Building home page...');

    ScrollController scrollController = useScrollController();

    final fullScreen = ref.watch(Config.fullScreenProvider.state);
    final mangaImageSize = ref.watch(Config.mangaImageSizeProvider.state);
    final imageList = ref.watch(MangaReaderState.mangaImagesListProvider.state);
    ref.watch(MangaReaderState.currentMangaChapterIndexProvider.state);

    bool dragAndDropDialogOpen = false;

    // printFromMangaReader(imageList.state);

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
                      return const _PopUpDialog();
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
                    return const _DragAndDropDialog();
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
                    'You can add mangas by dragging and dropping!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )
              : ListView(
                  shrinkWrap: true,
                  controller: scrollController,
                  children: [
                    ...imageList.state.map((e) {
                      // printFromMangaReader('Loading: $e');
                      return MangaImage(file: File(e), maxWidth: maxWidth);
                    }).toList(),
                  ],
                  // File file = File(imageList.state[i]);

                  // return ;
                )
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

class _PopUpDialog extends HookConsumerWidget {
  const _PopUpDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    TextEditingController currentMangaChapterIndexTextEditingController = useTextEditingController();

    return Dialog(
      child: SizedBox(
        width: 700,
        height: 380,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              _PopUpDialogOptions(
                title: 'Load state from file',
                callback: () {
                  loadFiles();
                },
              ),
              // _PopUpDialogOptions(
              //   title: 'Load config from file',
              //   callback: () {
              //     Config.loadSettings();
              //   },
              // ),
              // const Divider(thickness: 2),
              // _PopUpDialogOptions(
              //   title: 'Load manga reader state from file',
              //   callback: () {
              //     MangaReaderState.loadSettings();
              //   },
              // ),
              const Divider(thickness: 2),
              _PopUpDialogOptions(
                title: 'Save state to file',
                callback: () {
                  saveFiles();
                },
              ),
              // const Divider(thickness: 2),
              // _PopUpDialogOptions(
              //   title: 'Save config to file',
              //   callback: () {
              //     Config.saveSettings();
              //   },
              // ),
              // const Divider(thickness: 2),
              // _PopUpDialogOptions(
              //   title: 'Save manga reader state to file',
              //   callback: () {
              //     MangaReaderState.saveSettings();
              //   },
              // ),
              const Divider(thickness: 2),
              // const _CurrentMangaChapterSetter(),
              // const Divider(thickness: 2),
              // const Divider(thickness: 2),
              _PopUpDialogOptions(
                title: 'Change current chapter index',
                callback: () {
                  MangaReaderState.saveSettings();
                },
                child: SizedBox(
                  width: 70,
                  child: TextField(
                    controller: currentMangaChapterIndexTextEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: ref.read(MangaReaderState.currentMangaChapterIndexProvider.state).state.toString(),
                    ),
                    onEditingComplete: () {
                      int index = int.parse(currentMangaChapterIndexTextEditingController.value.text);
                      MangaFileHandler.setMangaChapterIndex(index);
                      ref.read(MangaReaderState.currentMangaChapterIndexProvider.state).state = index;
                    },
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const Divider(thickness: 2),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopUpDialogOptions extends StatelessWidget {
  // ignore: unused_element
  const _PopUpDialogOptions({Key? key, required this.title, required this.callback, this.child}) : super(key: key);

  final String title;
  final Function callback;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => callback(),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    // fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const Spacer(),
            if (child != null) child ?? const SizedBox(),
            if (child != null) const Padding(padding: EdgeInsets.only(right: 10)),
          ],
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
