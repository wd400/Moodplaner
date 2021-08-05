import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:moodplaner/core/playback.dart';
import 'package:path/path.dart' as path;

import 'mediatype.dart';


late FileIntent fileIntent;


const _methodChannel = const MethodChannel('com.alexmercerind.harmonoid/openFile');


class FileIntent {
  int? tabIndex;
  File? openedFile;

  FileIntent({this.tabIndex, this.openedFile});

  static Future<void> init() async {
    try {
      File file = await FileIntent._getOpenFile();
      fileIntent = new FileIntent(
        tabIndex: 0,
        openedFile: file,
      );
    }
    catch(exception) {
      fileIntent = new FileIntent(
        tabIndex: 1,
      );
    }
  }

  static Future<File> _getOpenFile() async {
    String? response = await _methodChannel.invokeMethod('getOpenFile', {});
    String filePath = response!;
    File file = new File(filePath);
    if (await file.exists()) return file;
    else throw FileSystemException("File does not exists.");
  }

  Future<void> play() async {
    MetadataRetriever retriever = new MetadataRetriever();
    await retriever.setFile(this.openedFile!);
    Track track = Track.fromMap((await retriever.metadata).toMap())!;
    track.trackName = path.basename(this.openedFile!.path).split('.').first;

    track.filePath = this.openedFile!.path;

    Playback.play(
      tracks: <Track>[track],
      index: 0,
    );
  }
}
