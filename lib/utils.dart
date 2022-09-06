import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:manga_reader/config.dart';
import 'package:manga_reader/manga_reader_state.dart';

late BuildContext context_in_utils_file;

void printFromMangaReader(dynamic val) {
  // try {
  String out = '';
  final re = RegExp(r'^#1[ \t]+.+:(?<line>[0-9]+):[0-9]+\)$', multiLine: true);
  final match = re.firstMatch(StackTrace.current.toString());

  if (val is List) {
    out = '---JDebug--- ${(match == null) ? -1 : int.parse(match.namedGroup('line')!)} ';
    for (dynamic element in val) {
      out += "$element ";
    }
  } //
  else {
    out = "---JDebug--- ${(match == null) ? -1 : int.parse(match.namedGroup('line')!)} $val";
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
  printFromMangaReader('Writing json file...');

  final file = File(filePath);
  if (file.existsSync()) {
    file.createSync(recursive: true);
  }

  // printFromMangaReader(data);

  String jsonString = getPrettyJSONString(data);
  try {
    file.writeAsStringSync(jsonString);
    return true;
  } catch (_, e) {
    printFromMangaReader(e);
    return false;
  }
}

// =============================================================================================================================

Map<String, dynamic> loadJsonFile(String filePath) {
  printFromMangaReader('Reading json file...');

  final file = File(filePath);
  if (!file.existsSync()) {
    return {};
  }

  try {
    String data = file.readAsStringSync();
    // printFromMangaReader(data);

    return jsonDecode(data);
  } catch (_, e) {
    printFromMangaReader(e);

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
    printFromMangaReader(path);
    throw Exception('File type not supported!');
  }
}

// =============================================================================================================================

int lexSorter(String a, String b) {
  int aInt = int.parse(a.split('/').last.replaceAll(RegExp(r'[^0-9]'), ''));
  int bInt = int.parse(b.split('/').last.replaceAll(RegExp(r'[^0-9]'), ''));
  return aInt.compareTo(bInt);
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
  ScaffoldMessenger.of(context_in_utils_file).showSnackBar(snackBar);
  // });
}

// =============================================================================================================================

void loadFiles() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    MangaReaderState.loadSettings();
    Config.loadSettings();
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
