// ignore_for_file: prefer_final_fields

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/app/utils.dart';

class Config {
  Config._();
  static late WidgetRef ref;

  static double _mangaImageSize = 1.5; // 1.5 Default
  static final mangaImageSizeProvider = StateProvider((ref) {
    return _mangaImageSize;
  });

  static bool _fullScreen = false;
  static final fullScreenProvider = StateProvider((ref) {
    return _fullScreen;
  });

  static int _timesRequiredToClickSpaceBeforeOpenningNewManga = 5;
  static final timesRequiredToClickSpaceBeforeOpenningNewMangaProvider = StateProvider((ref) {
    return _timesRequiredToClickSpaceBeforeOpenningNewManga;
  });

  static double _fasterScrollSpeed = 2000.0;
  static final fasterScrollSpeedProvider = StateProvider((ref) {
    return _fasterScrollSpeed;
  });

  static double _scrollSpeed = 500.0;
  static final scrollSpeedProvider = StateProvider((ref) {
    return _scrollSpeed;
  });

// =============================================================================================================================

// --------------------TO JSON--------------------

  static Map<String, dynamic> toJson() {
    return {
      '_mangaImageSize': ref.read(mangaImageSizeProvider.state).state,
      // '_fullScreen': ref.read(fullScreenProvider.state).state,
      '_fasterScrollSpeed': ref.read(fasterScrollSpeedProvider.state).state,
      '_scrollSpeed': ref.read(scrollSpeedProvider.state).state,
      '_timesRequiredToClickSpaceBeforeOpenningNewManga': ref.read(timesRequiredToClickSpaceBeforeOpenningNewMangaProvider.state).state,
    };
  }

// --------------------FROM JSON--------------------

  static void fromJson(Map<String, dynamic> jsonData) {
    ref.read(mangaImageSizeProvider.state).state = jsonData['_mangaImageSize'];
    // ref.read(fullScreenProvider.state).state = jsonData['_fullScreen'];
    ref.read(fasterScrollSpeedProvider.state).state = jsonData['_fasterScrollSpeed'];
    ref.read(scrollSpeedProvider.state).state = jsonData['_scrollSpeed'];
    ref.read(timesRequiredToClickSpaceBeforeOpenningNewMangaProvider.state).state = jsonData['_timesRequiredToClickSpaceBeforeOpenningNewManga'];
  }

  static bool saveSettings() {
    try {
      echo('Saving config file...');
      return saveJsonFile('config.json', Config.toJson());
    } catch (_) {
      showSnackbar('Error while saving config file!'); //: $e');

      return false;
    }
  }

  static void loadSettings() {
    try {
      echo('Loading config file...');
      Map<String, dynamic> data = loadJsonFile('config.json');
      (data == <String, dynamic>{}) ? null : Config.fromJson(data);
      // echo(Config.toJson());
    } catch (_) {
      showSnackbar('Error while loading config file!'); //: $e');
    }
  }
}
