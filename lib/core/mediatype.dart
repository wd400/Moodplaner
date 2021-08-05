import 'dart:core';
import 'dart:ffi';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:path/path.dart' as path;

import 'dart:convert';
import 'package:crypto/crypto.dart';



import 'package:hive/hive.dart';
import 'package:path/path.dart';

part 'mediatype.g.dart';

class MediaType extends HiveObject {
  late String? type;
}

@HiveType(typeId: 1)
class Track extends MediaType {
  @HiveField(0)
  String? hash;
  @HiveField(1)
  String? filePath;
  @HiveField(2)
  bool? todel;

  @HiveField(3)
  bool synced=false;

  @HiveField(4)
  String? trackName;
  @HiveField(5)
  String? albumArtistName;
  

  String? type = 'Track';

  @override
  Map<String, dynamic> toMap() {
    return {
      'hash': this.hash,
      'todel': this.todel,
      'type': this.type,
    };

  }

  String getName(){
return trackName??basename(filePath!);
  }
  
  static Track? fromMap(Map<String, dynamic>? trackMap) {
    if (trackMap == null) return null;
    return new Track(
      hash: trackMap['hash'],
      filePath: trackMap['filePath'],
      todel: trackMap['todel'],
    );
  }

  Track({this.hash, this.filePath, this.todel, this.trackName,this.albumArtistName});

  @override
  bool operator == (Object other) =>
      other is Track &&
          other.hash == hash;

  static Future<Track> fromFile(File object) async {
    final algorithm = crypto.Sha512();
    final crypto.Hash  hash = await algorithm.hash(object.readAsBytesSync());
    MetadataRetriever retriever = new MetadataRetriever();
    await retriever.setFile(object);
    Metadata metadata = await retriever.metadata;
    return new Track(filePath: object.path,
        todel: false,
        hash: hash.toString(),
    trackName: metadata.trackName,
    albumArtistName: metadata.albumArtistName,
    );
  }




  }


@HiveType(typeId: 4)
class Playlist extends MediaType {
  @HiveField(0)
  late String? playlistName;
  @HiveField(1)
  late int? playlistId;
  @HiveField(2)
  List<Track> tracks = <Track>[];
  @HiveField(3)
  DateTime lastModif=DateTime.now();
  @HiveField(4)
  DateTime? lastSync;
  @HiveField(5)
  bool todel=false;

  var type = 'Playlist';

  @override
  Map<String, dynamic> toMap() {
    return {
      'playlistName': this.playlistName,
      'playlistId': this.playlistId,
      'tracks': tracks,
      'type': this.type,
    };
  }

  Playlist({this.playlistName, this.playlistId});
}

@HiveType(typeId: 5)
class Generator extends MediaType {
  @HiveField(0)
  String? generatorName;
  @HiveField(1)
  int? generatorId;
  @HiveField(2)
  Map<int,List<double?>> measures;

  @HiveField(3)
  DateTime lastModif=DateTime.now();
  @HiveField(4)
  DateTime? lastSync;
  @HiveField(5)
  bool todel=false;


  String? type = 'Generator';

  @override
  Map<String, dynamic> toMap() {
    return {
      'generatorName': this.generatorName,
      'generatorId': this.generatorId,
      'measures':measures,
      'lastModif':lastModif,
      'lastSync':lastSync

    };

  }

  Generator({this.generatorName,this.generatorId, this.measures=const {}} );
}



