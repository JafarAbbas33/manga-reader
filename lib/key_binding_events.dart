import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/manga_reader_debug_print.dart';
import 'package:manga_reader/manga_reader_state.dart';
import 'package:manga_reader/providers.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:window_manager/window_manager.dart';

void bindKeys(final window, final WidgetRef ref, ItemScrollController scrollController, ItemPositionsListener itemPositionsListener) {
  final fullScreen = ref.watch(fullScreenProvider.state);
  final scrollSpeed = ref.watch(scrollSpeedProvider.state);
  final mangaImageSize = ref.watch(mangaImageSizeProvider.state);

  window.onKeyData = (final keyData) {
    debugPrint('${keyData.logical} ******************************************');

    if (keyData.logical == LogicalKeyboardKey.space.keyId && keyData.type == KeyEventType.down) {
      scrollController.scrollTo(index: 3, duration: const Duration(milliseconds: 500), alignment: 0.4);
      final visiblePages = itemPositionsListener.itemPositions.value;
      int lastItemIndex = (visiblePages.isEmpty) ? 0 : visiblePages.first.index;
      mangaReaderDebugPrint(lastItemIndex);
      // mangaReaderDebugPrint(itemPositionsListener.itemPositions.value);
      //   MangaReaderState.currentScrollPosition = scrollController.position.pixels + scrollSpeed.state;
      //   mangaReaderDebugPrint(MangaReaderState.currentScrollPosition);

      //   scrollController.animateTo(scrollController.position.pixels + scrollSpeed.state, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
      return true;
    }

    // 'home' pressed
    else if (keyData.logical == 4294968070 && keyData.type == KeyEventType.down) {
      // scrollController.animateTo(0.0, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
    }

    // 'l' pressed
    else if (keyData.logical == 108 && keyData.type == KeyEventType.down) {
      double tempMaxScrollPosition = MangaReaderState.maxScrollPosition;
      for (int i = 0; i < 4; ++i) {
        // sleep(const Duration(seconds: 4));
        Future.delayed(const Duration(seconds: 4), () {
          mangaReaderDebugPrint(tempMaxScrollPosition);
          // scrollController.animateTo(tempMaxScrollPosition, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
          mangaReaderDebugPrint(tempMaxScrollPosition);
        });
      }
    }

    // 'end' pressed
    else if (keyData.logical == 4294968069 && keyData.type == KeyEventType.down) {
      // scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
    }

    // '+' pressed
    else if (keyData.logical == 61 && keyData.type == KeyEventType.down) {
      mangaImageSize.state -= 0.1;
    }

    // 'f' pressed
    else if (keyData.logical == 102 && keyData.type == KeyEventType.down) {
      debugPrint('f Pressed');
      WindowManager.instance.isFullScreen().then((value) {
        fullScreen.state = !value;
        WindowManager.instance.setFullScreen(!value);
      });
    }

    // '-' pressed
    else if (keyData.logical == 45 && keyData.type == KeyEventType.down) {
      mangaImageSize.state += 0.1;

      return true;
    }
    return false;
  };
}
