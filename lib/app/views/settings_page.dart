import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/app/utils.dart';
import 'package:manga_reader/app/models/manga_files_handler.dart';
import 'package:manga_reader/app/models/manga_reader_state.dart';

class SettingsDialog extends HookConsumerWidget {
  const SettingsDialog({Key? key}) : super(key: key);

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
