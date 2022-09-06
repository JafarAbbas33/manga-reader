import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/config.dart';
import 'package:window_manager/window_manager.dart';

void bindKeys(final window, final WidgetRef ref, ScrollController scrollController) {
  final fullScreen = ref.watch(Config.fullScreenProvider.state);
  final scrollSpeed = ref.read(Config.scrollSpeedProvider.state);
  final fasterScrollSpeed = ref.read(Config.fasterScrollSpeedProvider.state);
  final mangaImageSize = ref.watch(Config.mangaImageSizeProvider.state);

  window.onKeyData = (final keyData) {
    debugPrint('${keyData.logical} ******************************************');

    // 'space' or 'down' pressed
    if ((keyData.logical == LogicalKeyboardKey.space.keyId || keyData.logical == LogicalKeyboardKey.arrowDown.keyId) && keyData.type == KeyEventType.down) {
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
