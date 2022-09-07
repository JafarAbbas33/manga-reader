import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/config.dart';
import 'package:manga_reader/manga_files_handler.dart';
import 'package:manga_reader/utils.dart';
import 'package:window_manager/window_manager.dart';

void bindKeys(final window, final WidgetRef ref, ScrollController scrollController) {
  int noOfTimesSpaceClicked = 0;
  final fullScreen = ref.watch(Config.fullScreenProvider.state);
  final scrollSpeed = ref.read(Config.scrollSpeedProvider.state);
  final fasterScrollSpeed = ref.read(Config.fasterScrollSpeedProvider.state);
  final mangaImageSize = ref.watch(Config.mangaImageSizeProvider.state);
  final timesRequiredToClickSpaceBeforeOpenningNewManga = ref.read(Config.timesRequiredToClickSpaceBeforeOpenningNewMangaProvider.state);

  window.onKeyData = (final keyData) {
    // debugPrint('${keyData.logical} ******************************************');

    // 'space' or 'down' pressed
    if ((keyData.logical == LogicalKeyboardKey.space.keyId || keyData.logical == LogicalKeyboardKey.arrowDown.keyId) && keyData.type == KeyEventType.down) {
      printFromMangaReader([scrollController.position.pixels, '||', scrollController.position.maxScrollExtent]);
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (noOfTimesSpaceClicked >= timesRequiredToClickSpaceBeforeOpenningNewManga.state) {
          showSnackbar('Openning new manga...');
          noOfTimesSpaceClicked = 0;
          Future.delayed(
              const Duration(seconds: 2),
              () async => {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      MangaFileHandler.requestNextManga();
                      scrollController.jumpTo(0);
                    })
                  });
        }
        noOfTimesSpaceClicked += 1;
        printFromMangaReader('Click ${timesRequiredToClickSpaceBeforeOpenningNewManga.state - noOfTimesSpaceClicked + 1} next manga...');
      }
      scrollController.animateTo(scrollController.position.pixels + scrollSpeed.state, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
      return true;
    }

    // 'up' pressed
    if (keyData.logical == LogicalKeyboardKey.arrowUp.keyId && keyData.type == KeyEventType.down) {
      scrollController.animateTo(scrollController.position.pixels - scrollSpeed.state, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
      return true;
    }

    // 'page down' pressed
    else if (keyData.logical == 4294968071 && keyData.type == KeyEventType.down) {
      scrollController.animateTo(scrollController.position.pixels + fasterScrollSpeed.state, duration: const Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);

      return true;
    }

    // 'page up' pressed
    else if (keyData.logical == 4294968072 && keyData.type == KeyEventType.down) {
      scrollController.animateTo(scrollController.position.pixels - fasterScrollSpeed.state, duration: const Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);

      return true;
    }

    // 'home' pressed
    else if (keyData.logical == 4294968070 && keyData.type == KeyEventType.down) {
      scrollController.animateTo(0.0, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);

      return true;
    }

    // 'end' pressed
    else if (keyData.logical == 4294968069 && keyData.type == KeyEventType.down) {
      scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);

      return true;
    }

    // '+' pressed
    else if (keyData.logical == 61 && keyData.type == KeyEventType.down) {
      mangaImageSize.state -= 0.1;

      return true;
    }

    // 'f' pressed
    else if (keyData.logical == 102 && keyData.type == KeyEventType.down) {
      debugPrint('f Pressed');
      WindowManager.instance.isFullScreen().then((value) {
        fullScreen.state = !value;
        WindowManager.instance.setFullScreen(!value);
      });
      return true;
    }

    // '-' pressed
    else if (keyData.logical == 45 && keyData.type == KeyEventType.down) {
      mangaImageSize.state += 0.1;

      return true;
    }
    return false;
  };
}
