import 'package:manga_reader/config.dart';
import 'package:manga_reader/manga_reader_state.dart';
import 'package:riverpod/riverpod.dart';

final mangaImageSizeProvider = StateProvider((ref) {
  return Config.mangaImageSize;
});

bool _fullScreen = false;
final fullScreenProvider = StateProvider((ref) {
  return _fullScreen;
});

double _fasterScrollSpeed = 2000.0;
final fasterScrollSpeedProvider = StateProvider((ref) {
  return _fasterScrollSpeed;
});

double _scrollSpeed = 500.0;
final scrollSpeedProvider = StateProvider((ref) {
  return _scrollSpeed;
});

final mangaImagesDirectoryProvider = StateProvider((ref) {
  return MangaReaderState.mangaImagesDirectory;
});
