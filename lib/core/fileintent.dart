import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:moodplaner/core/playback.dart';
import 'package:path/path.dart' as path;

import 'mediatype.dart';


late FileIntent fileIntent;


const _methodChannel = const MethodChannel('com.alexmercerind.harmonoid/openFile');


class FileIntent {
  int? tabIndex;
  Track? openedTrack;

  FileIntent({this.tabIndex, this.openedTrack});

  static Future<void> init() async {

      fileIntent = new FileIntent(
        tabIndex: 1,
      );

  }

  static Future<File> _getOpenFile() async {
    String? response = await _methodChannel.invokeMethod('getOpenFile', {});
    String filePath = response!;
    File file = new File(filePath);
    if (await file.exists()) return file;
    else throw FileSystemException("File does not exists.");
  }

  Future<void> play() async {
    /*
    !kIsWeb

      MetadataRetriever retriever = new MetadataRetriever();
      await retriever.setFile(this.openedFile!);
      Track track = Track.fromMap((await retriever.metadata).toMap())!;
      track.trackName = path
          .basename(this.openedFile!.path)
          .split('.')
          .first;

      track.filePath = this.openedFile!.path;

     */
    if (this.openedTrack != null) {
      Playback.play(
        tracks: <Track>[this.openedTrack!],
        index: 0,
      );
    }
  }
}
