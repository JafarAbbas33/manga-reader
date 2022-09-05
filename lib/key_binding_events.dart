import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/providers.dart';
import 'package:window_manager/window_manager.dart';

void bindKeys(final window, final WidgetRef ref, ScrollController scrollController) {
  final fullScreen = ref.watch(fullScreenProvider.state);
  final scrollSpeed = ref.watch(scrollSpeedProvider.state);
  final mangaImageSize = ref.watch(mangaImageSizeProvider.state);

  window.onKeyData = (final keyData) {
    // debugPrint('${keyData.logical} ******************************************');

    if (keyData.logical == LogicalKeyboardKey.space.keyId && keyData.type == KeyEventType.down) {
      scrollController.animateTo(scrollController.position.pixels + scrollSpeed.state, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
      return true;
    }
    // '+' pressed
    else if (keyData.logical == 61 && keyData.type == KeyEventType.down) {
      mangaImageSize.state -= 0.1;
      // setState(() {
      //   debugPrint('+ Pressed');
      //   sizeIncrease
      // });
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
      // setState(() {
      //   debugPrint('- Pressed');
      //   sizeIncrease += 0.1;
      // });

      return true;
    }
    return false;
  };
}
