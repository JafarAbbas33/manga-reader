import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/manga_files_handler.dart';
import 'package:manga_reader/manga_reader_state.dart';
import 'package:manga_reader/utils.dart';

class MangaReaderAppBar extends HookConsumerWidget {
  const MangaReaderAppBar({Key? key}) : super(key: key);

  @override
  AppBar build(BuildContext context, ref) {
    return AppBar(
      title: Text((MangaReaderState.mangaImagesList.isEmpty) ? 'Manga Reader' : MangaReaderState.currentMangaTitle),
      leading: IconButton(
        icon: const Icon(Icons.add),
        onPressed: (() {
          printFromMangaReader('===========' * 80);
          String path = '/home/jafarabbas33/Documents/Tachiyomi Mangas/MangaDex (EN)/Regina Rena – To the Unforgiven';
          // String path = '/tmp/manga_reader/Destiny Scans_Ch.1.cbz';
          // String path = '/tmp/manga_reader/Flame Scans_Ch.21.cbz';
          // MangaFileHandler.setNewMangaChapter(path);
          MangaFileHandler.setNewMangaDirectory(path);
          // MangaFileHandler.requestNextManga();
        }),
      ),
    );
  }
}
