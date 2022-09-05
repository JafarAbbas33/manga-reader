import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:manga_reader/config.dart';

void printFromMangaReader(dynamic val) {
  debugPrint('$val');
}

// =============================================================================================================================

String getPrettyJSONString(jsonObject) {
  return JsonEncoder.withIndent(' ' * Config.jsonLocalDataSaveIndent).convert(jsonObject);
}

// =============================================================================================================================

Future<bool> saveJsonFile(String filePath, Map<String, dynamic> data) async {
  printFromMangaReader('Writing settings file...');

  final file = File(filePath);
  if (!await file.exists()) {
    await file.create(recursive: true);
  }
  printFromMangaReader(data);

  String jsonString = getPrettyJSONString(data);
  try {
    file.writeAsString(jsonString);
    return true;
  } catch (_, e) {
    printFromMangaReader(e);
    return false;
  }
}

// =============================================================================================================================

Map<String, dynamic> loadJsonFile(String filePath) {
  printFromMangaReader('Writing settings file...');

  final file = File(filePath);
  if (!file.existsSync()) {
    return {};
  }

  try {
    String data = file.readAsStringSync();
    printFromMangaReader(data);

    return jsonDecode(data);
  } catch (_, e) {
    printFromMangaReader(e);

    return {};
  }
}

// =============================================================================================================================
