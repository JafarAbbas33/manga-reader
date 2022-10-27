import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/app/models/config.dart';
import 'package:manga_reader/app/models/manga_reader_state.dart';
import 'package:manga_reader/app/views/home_page.dart';
import 'package:manga_reader/app/utils.dart';

void main(List<String> arguments) {
  MangaReaderState.arguments = arguments;

  final container = ProviderContainer();
  runApp(UncontrolledProviderScope(
    container: container,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    echo('Loading files...');
    echo(['Loading stuff:', MangaReaderState.arguments]);

    loadFiles();
    loadFromArguments();

    // if (MangaReaderState.arguments.isEmpty) {
    //   loadFiles();
    // } else {
    //   Config.loadSettings();
    //   loadFromArguments();
    // }

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}
