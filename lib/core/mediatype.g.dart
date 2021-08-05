// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mediatype.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackAdapter extends TypeAdapter<Track> {
  @override
  final int typeId = 1;

  @override
  Track read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Track(
      hash: fields[0] as String?,
      filePath: fields[1] as String?,
      todel: fields[2] as bool?,
      trackName: fields[4] as String?,
      albumArtistName: fields[5] as String?,
    )..synced = fields[3] as bool;
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.hash)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.todel)
      ..writeByte(3)
      ..write(obj.synced)
      ..writeByte(4)
      ..write(obj.trackName)
      ..writeByte(5)
      ..write(obj.albumArtistName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlaylistAdapter extends TypeAdapter<Playlist> {
  @override
  final int typeId = 4;

  @override
  Playlist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Playlist(
      playlistName: fields[0] as String?,
      playlistId: fields[1] as int?,
    )
      ..tracks = (fields[2] as List).cast<Track>()
      ..lastModif = fields[3] as DateTime
      ..lastSync = fields[4] as DateTime?
      ..todel = fields[5] as bool;
  }

  @override
  void write(BinaryWriter writer, Playlist obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.playlistName)
      ..writeByte(1)
      ..write(obj.playlistId)
      ..writeByte(2)
      ..write(obj.tracks)
      ..writeByte(3)
      ..write(obj.lastModif)
      ..writeByte(4)
      ..write(obj.lastSync)
      ..writeByte(5)
      ..write(obj.todel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GeneratorAdapter extends TypeAdapter<Generator> {
  @override
  final int typeId = 5;

  @override
  Generator read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Generator(
      generatorName: fields[0] as String?,
      generatorId: fields[1] as int?,
      measures: (fields[2] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as int, (v as List).cast<double?>())),
    )
      ..lastModif = fields[3] as DateTime
      ..lastSync = fields[4] as DateTime?
      ..todel = fields[5] as bool;
  }

  @override
  void write(BinaryWriter writer, Generator obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.generatorName)
      ..writeByte(1)
      ..write(obj.generatorId)
      ..writeByte(2)
      ..write(obj.measures)
      ..writeByte(3)
      ..write(obj.lastModif)
      ..writeByte(4)
      ..write(obj.lastSync)
      ..writeByte(5)
      ..write(obj.todel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneratorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
