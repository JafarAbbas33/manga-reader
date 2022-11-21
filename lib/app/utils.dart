import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_reader/app/models/config.dart';
import 'package:manga_reader/app/models/manga_files_handler.dart';
import 'package:manga_reader/app/models/manga_reader_state.dart';

late BuildContext contextInUtilsFile;
late WidgetRef refInUtilsFile;

void echo(dynamic val) {
  // try {
  String out = '';
  // final re = RegExp(r'^#1[ \t]+.+:(?<line>[0-9]+):[0-9]+\)$', multiLine: true); // Old reg which printed only line nos
  final re = RegExp(r'^#1[ \t]+.+\/(?<file>.+):(?<line>[0-9]+):[0-9]+\)$', multiLine: true); // New reg which prints line nos with file names
  final match = re.firstMatch(StackTrace.current.toString());

  if (val is List) {
    final String lineWithFile = '${(match == null) ? -1 : match.namedGroup('line')!} | ${(match == null) ? -1 : match.namedGroup('file')!}'.padRight(36);
    out = '---JDebug--- $lineWithFile | ';
    for (dynamic element in val) {
      out += "$element ";
    }
  } //
  else {
    // out = '---JDebug--- ${(match == null) ? -1 : int.parse(match.namedGroup('line')!)} ';
    final String lineWithFile = '${(match == null) ? -1 : match.namedGroup('line')!} | ${(match == null) ? -1 : match.namedGroup('file')!}'.padRight(36);
    out = "---JDebug--- $lineWithFile | $val";
    // out = "---JDebug--- ${(match == null) ? -1 : int.parse(match.namedGroup('line')!)} $val";
    // out = '---JDebug--- ${StackTrace.current.toString()} ';
  } //
  debugPrint(out);

  // } catch (e) {
  // return;
  // }

  // debugPrint('---JDebug--- ${CustomTrace(StackTrace.current).lineNumber} --- ' + str);
}

// =============================================================================================================================

String getPrettyJSONString(jsonObject) {
  return JsonEncoder.withIndent(' ' * 4).convert(jsonObject);
}

// =============================================================================================================================

bool saveJsonFile(String filePath, Map<String, dynamic> data) {
  echo('Writing json file...');

  final file = File(filePath);
  if (file.existsSync()) {
    file.createSync(recursive: true);
  }

  // echo(data);

  String jsonString = getPrettyJSONString(data);
  try {
    file.writeAsStringSync(jsonString);
    return true;
  } catch (_, e) {
    echo(e);
    return false;
  }
}

// =============================================================================================================================

Map<String, dynamic> loadJsonFile(String filePath) {
  echo('Reading json file...');

  final file = File(filePath);
  if (!file.existsSync()) {
    return {};
  }

  try {
    String data = file.readAsStringSync();
    // echo(data);

    return jsonDecode(data);
  } catch (_, e) {
    echo(e);

    return {};
  }
}

// =============================================================================================================================

String extractMangaChapter(String path) {
  if (path.endsWith('.cbz') || path.endsWith('.zip')) {
    final bytes = File(path).readAsBytesSync();

    // Decode the Zip file
    final archive = ZipDecoder().decodeBytes(bytes);

    // Extract the contents of the Zip archive to disk.
    final String targetDir = '/tmp/manga_reader/${path.split('/').last.replaceAll('.cbz', '').replaceAll('.zip', '')}';
    for (final file in archive) {
      final filename = file.name;
      String targetPath = '$targetDir/$filename';
      if (file.isFile) {
        final data = file.content as List<int>;
        File(targetPath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    }
    return targetDir;
  } else {
    echo(path);
    throw Exception('File type not supported!');
  }
}

// =============================================================================================================================

int lexSorter(String a, String b) {
  try {
    // String aLast = a.split('/').last;

    // var doubleRE = RegExp(r"-?(?:\d*\.)?\d+(?:[eE][+-]?\d+)?");
    // var numbers = doubleRE.allMatches(aLast).map((m) => double.parse(m[0]!)).toList();
    // if (a.contains('39.5') || b.contains('39.5')) echo(['@', numbers]);

    // String aReped = aLast.replaceAll(RegExp(r"-?(?:\d*\.)?\d+(?:[eE][+-]?\d+)?"), '');
    // // if (a.contains('39.5') || b.contains('39.5')) echo(['@', aReped]);
    // double aInt = double.parse(aReped);

    // String bLast = b.split('/').last;

    // String bReped = bLast.replaceAll(RegExp(r"-?(?:\d*\.)?\d+(?:[eE][+-]?\d+)?"), '');

    // if (a.contains('39.5') || b.contains('39.5')) echo(['@', aReped, bReped]);
    // // echo(['@', a]);
    // double bInt = double.parse(bReped);

    // if (aInt > bInt) {
    //   return 1;
    // } else {
    //   return -1;
    // }

    var doubleRE = RegExp(r"-?(?:\d*\.)?\d+(?:[eE][+-]?\d+)?");

    String aLast = a.split('/').last;
    double aInt = doubleRE.allMatches(aLast).map((m) => double.parse(m[0]!)).toList()[0];
    // if (a.contains('39.5') || b.contains('39.5')) echo(['@', aInt]);

    String bLast = b.split('/').last;
    double bInt = doubleRE.allMatches(bLast).map((m) => double.parse(m[0]!)).toList()[0];
    // if (a.contains('39.5') || b.contains('39.5')) echo(['@', aInt, bInt]);

    if (aInt > bInt) {
      return 1;
    } else {
      return -1;
    }
    // int aInt = int.parse(a.split('/').last.replaceAll(RegExp(r'[^0-9]'), ''));
    // int bInt = int.parse(b.split('/').last.replaceAll(RegExp(r'[^0-9]'), ''));
    // return aInt.compareTo(bInt);
  } catch (_) {
    // echo(['@', '#################', a]);
    return 1;
  }
}

// =============================================================================================================================

void showSnackbar(String text) {
  // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //   content: Text(text),
  // ));

  var snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'Notification!',
      message: text,
      contentType: ContentType.help,
    ),
  );

  // WidgetsBinding.instance.addPostFrameCallback((_) {
  ScaffoldMessenger.of(contextInUtilsFile).showSnackBar(snackBar);
  // });
}

// =============================================================================================================================

void loadFiles() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final currentMangaChapterIndex = refInUtilsFile.read(MangaReaderState.currentMangaChapterIndexProvider.state);
    MangaReaderState.loadSettings();
    Config.loadSettings();
    MangaFileHandler.setMangaChapterIndex(currentMangaChapterIndex.state);
  });
}

// =============================================================================================================================

void saveFiles() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    MangaReaderState.saveSettings();
    Config.saveSettings();
  });
}

// =============================================================================================================================

void loadFromArguments() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final args = MangaReaderState.arguments;
    if (args.length < 2) return;

    String path = args.last.replaceFirst('file://', '').replaceAll('%20', ' ');
    echo([' ***************** Path:\n', path]);

    if (args.contains('--directory')) {
      MangaFileHandler.setNewMangaDirectory(path);
    } else if (args.contains('--chapter')) {
      MangaFileHandler.setNewMangaChapter(path);
    }
  });
}

// =============================================================================================================================

// =============================================================================================================================
