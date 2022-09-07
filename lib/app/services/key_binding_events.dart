import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/app/utils.dart';
import 'package:manga_reader/app/models/config.dart';
import 'package:manga_reader/app/models/manga_files_handler.dart';
import 'package:window_manager/window_manager.dart';

void bindKeys(final window, final WidgetRef ref, ScrollController scrollController) {
  int noOfTimesSpaceClicked = 0;
  int noOfTimesRightClicked = 0;
  int noOfTimesLeftClicked = 0;
  final fullScreen = ref.watch(Config.fullScreenProvider.state);
  final scrollSpeed = ref.read(Config.scrollSpeedProvider.state);
  final fasterScrollSpeed = ref.read(Config.fasterScrollSpeedProvider.state);
  final mangaImageSize = ref.watch(Config.mangaImageSizeProvider.state);
  final timesRequiredToClickSpaceBeforeOpenningNewManga = ref.read(Config.timesRequiredToClickSpaceBeforeOpenningNewMangaProvider.state);

  window.onKeyData = (final keyData) {
    // debugPrint('${keyData.logical} ******************************************');

    // 'space' or 'down' pressed
    if ((keyData.logical == LogicalKeyboardKey.space.keyId || keyData.logical == LogicalKeyboardKey.arrowDown.keyId) && keyData.type == KeyEventType.down) {
      // printFromMangaReader([scrollController.position.pixels, '||', scrollController.position.maxScrollExtent]);
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (noOfTimesSpaceClicked >= timesRequiredToClickSpaceBeforeOpenningNewManga.state) {
          showSnackbar('Opening next manga...');
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

    // 'right' pressed
    if (keyData.logical == LogicalKeyboardKey.arrowRight.keyId && keyData.type == KeyEventType.down) {
      if (noOfTimesRightClicked >= timesRequiredToClickSpaceBeforeOpenningNewManga.state) {
        showSnackbar('Opening next manga...');
        noOfTimesRightClicked = 0;
        Future.delayed(
            const Duration(seconds: 2),
            () async => {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    MangaFileHandler.requestNextManga();
                    scrollController.jumpTo(0);
                  })
                });
      }
      noOfTimesRightClicked += 1;
      printFromMangaReader('Click ${timesRequiredToClickSpaceBeforeOpenningNewManga.state - noOfTimesRightClicked + 1} next manga...');

      return true;
    }

    // 'left' pressed
    if (keyData.logical == LogicalKeyboardKey.arrowLeft.keyId && keyData.type == KeyEventType.down) {
      if (noOfTimesLeftClicked >= timesRequiredToClickSpaceBeforeOpenningNewManga.state) {
        showSnackbar('Opening previous manga...');
        noOfTimesLeftClicked = 0;
        Future.delayed(
            const Duration(seconds: 2),
            () async => {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    MangaFileHandler.requestPreviousManga();
                    scrollController.jumpTo(0);
                  })
                });
      }
      noOfTimesLeftClicked += 1;
      printFromMangaReader('Click ${timesRequiredToClickSpaceBeforeOpenningNewManga.state - noOfTimesLeftClicked + 1} previous manga...');

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
      // debugPrint('f Pressed');
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
