import 'dart:core';
import 'dart:io';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

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
  bool todel=false;

  @HiveField(3)
  bool synced=false;

  @HiveField(4)
  String? trackName;
  @HiveField(5)
  String? albumArtistName;
  

  String? type = 'Track';

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

  Track({this.hash, this.filePath, required this.todel, this.trackName,this.albumArtistName});

  @override
  bool operator == (Object other) =>
      other is Track &&
          other.hash == hash;

  static Future<Track> fromFile(File object) async {
  //  final algorithm = crypto.Sha512();
  //  final crypto.Hash  hash = await algorithm.hash(object.readAsBytesSync());
    var digest = sha256.convert(object.readAsBytesSync());
    Metadata metadata = await MetadataRetriever.fromFile(object);
    return new Track(filePath: object.path,
        todel: false,
        hash: digest.toString(),
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
//  DateTime? lastSync;
//  @HiveField(5)
  bool todel=false;

  var type = 'Playlist';

  Map<String, dynamic> toMap() {
    return {
      'playlistName': this.playlistName,
      'playlistId': this.playlistId,
      'tracks': tracks.map((e) => e.hash).toList(),
      'lastModif':this.lastModif.toIso8601String(),
      'todel':todel
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
  Map<String,List<double?>> measures;

  @HiveField(3)
  DateTime lastModif=DateTime.now();
  @HiveField(4)
//  DateTime? lastSync;
//  @HiveField(5)
  bool todel=false;


  String? type = 'Generator';

  Generator.fromJson(Map<String, dynamic> json)
      : generatorName = json['generatorName'],
        generatorId = json['generatorId'],
        measures= json['measures'],
        lastModif=json['lastModif']
   //     lastSync=json['lastSync']
  ;

  Map<String, dynamic> toJson() {
    return {
      'generatorName': this.generatorName,
      'generatorId': this.generatorId,
      'measures':measures.map((key, value) => MapEntry(key.toString(), value) ),
      'lastModif':lastModif.toIso8601String(),
     // 'lastSync':lastSync?.toIso8601String(),
      'todel':todel

    };

  }

  Generator({this.generatorName,this.generatorId, this.measures=const {}} );
}





