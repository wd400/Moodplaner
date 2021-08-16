import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:moodplaner/core/synchronization.dart';
import 'package:moodplaner/utils/methods.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import '../login.dart';
import 'mediatype.dart';

import 'package:hive/hive.dart';

import 'dart:math';

const int intMaxValue = 4294967296;

Random random = new Random();

enum CollectionSort {
  dateAdded,
  aToZ,
}


const List<String> SUPPORTED_FILE_TYPES = [
  'OGG',
  'OGA',
  'OGX',
  'AAC',
  'M4A',
  'MP3',
  'WMA',
  'WAV',
  'FLAC',
  'OPUS',
];


class Collection extends ChangeNotifier {

  static Collection? get() => _collection; 

  static Future<void> init({required Directory collectionDirectory, required Directory cacheDirectory, required CollectionSort collectionSortType}) async {
    _collection = new Collection();
    _collection.collectionDirectory = collectionDirectory;
    _collection.cacheDirectory = cacheDirectory;
    _collection.collectionSortType = collectionSortType;
    if (!await _collection.collectionDirectory.exists()) await _collection.collectionDirectory.create(recursive: true);
    if (!await Directory(path.join(_collection.cacheDirectory.path, 'albumArts')).exists()) {
      await Directory(path.join(_collection.cacheDirectory.path, 'albumArts')).create(recursive: true);
      await new File(
        path.join(cacheDirectory.path, 'albumArts', 'defaultAlbumArt' + '.PNG'),
      ).writeAsBytes((await rootBundle.load('assets/images/collection-album.jpg')).buffer.asUint8List());
    }
    await _collection.refresh();
  }

  late Directory collectionDirectory;
  late Directory cacheDirectory;
  late CollectionSort collectionSortType;
 // List<Playlist> playlists = <Playlist>[];
 // List<Generator> generators = <Generator>[];
 // List<Track> tracks = <Track>[];

  Future<void> setDirectories({required Directory? collectionDirectory, required Directory? cacheDirectory, void Function(int, int, bool)? onProgress}) async {
    _collection.collectionDirectory = collectionDirectory!;
    _collection.cacheDirectory = cacheDirectory!;
    if (!await _collection.collectionDirectory.exists()) await _collection.collectionDirectory.create(recursive: true);
    if (!await Directory(path.join(_collection.cacheDirectory.path, 'albumArts')).exists()) {
      await Directory(path.join(_collection.cacheDirectory.path, 'albumArts')).create(recursive: true);
      await new File(
        path.join(cacheDirectory.path, 'albumArts', 'defaultAlbumArt' + '.PNG'),
      ).writeAsBytes((await rootBundle.load('assets/images/collection-album.jpg')).buffer.asUint8List());
    }
    await _collection.index(onProgress: onProgress);
    this.notifyListeners();
  }

  Future<List<MediaType>> search(String query) async {
    if (query == '') return <MediaType>[];

    List<MediaType> result = <MediaType>[];

    final tracksBox = Hive.box<Track>('tracks');
   for (Track track in tracksBox.values) {
        if (track.getName().toLowerCase().contains(query.toLowerCase())) {
          result.add(track);
        }

    }
print(result);
    return result;
  }

  Future<List<MediaType>> searchServer(String query) async {
    if (query == '') return <MediaType>[];


    var res = await http.post( Uri.parse( '$SERVER_IP/search'), body:{'query':query},  headers: {"token": (await storage.read(key: "token"))??''});
    if (res.statusCode==200){
      print("iiiiiici");
      Box<Track> tracksBox=Hive.box<Track>('tracks');
      return convert.jsonDecode(res.body).map<Track>((e)=> tracksBox.get( e['hash'])?? Track(hash:e['hash'],trackName: e['title'], todel: false)).toList();
    }
    //TODO: search
    return <MediaType>[];
  }

  Future<void> add({required File file}) async {
    if (Methods.isFileSupported(file)) {
      final tracksBox = Hive.box<Track>('tracks');



      try {
        Track newTrack = await Track.fromFile(file);

        if (!tracksBox.containsKey(newTrack.hash)) {
          await tracksBox.put(newTrack.hash, newTrack);
        } else {
          tracksBox.get(newTrack.hash)!.filePath=newTrack.filePath;
          //save?
        }

      } catch (e){
        print(e);
        return;
      }
      }

    this.notifyListeners();
  }

  Future<void> delete(Track track) async {
    final tracksBox = Hive.box<Track>('tracks');
    final playlistsBox = Hive.box<Playlist>('playlists');

    (track..todel=true).save();

      for (Playlist playlist in playlistsBox.values) {
        for (Track track in playlist.tracks) {
          if (track.filePath == track.filePath && track.hash == track.hash) {
            this.playlistRemoveTrack(playlist, track);
       //     break;
          }
        }
      }
      if (await File(track.filePath!).exists()) {
        await File(track.filePath!).delete();

    }
      tracksBox.close();
      playlistsBox.close();


    this.notifyListeners();
  }


  Future<void> refresh({void Function(int completed, int total, bool isCompleted)? onProgress}) async {
    if (! await this.cacheDirectory.exists()) await this.cacheDirectory.create(recursive: true);
    if (! await this.collectionDirectory.exists()) await this.collectionDirectory.create(recursive: true);


  //  if (!await File(path.join(this.cacheDirectory.path, 'collection.JSON')).exists()) {
  //    await this.index();
  //    onProgress?.call(0, 0, true);
//    }
  //  else {
      List<File> collectionDirectoryContent = <File>[];
      for (FileSystemEntity object in this.collectionDirectory.listSync(recursive: true)) {
        if (Methods.isFileSupported(object) && object is File) {
          collectionDirectoryContent.add(object);
        }
      }
 //     if (collectionDirectoryContent.length != this._tracks.length) {
        for (int index = 0; index < collectionDirectoryContent.length; index++) {
          File file = collectionDirectoryContent[index];

            await this.add(
              file: file,
            );
          onProgress?.call(index + 1, collectionDirectoryContent.length, false);
        }
     // }
      onProgress?.call(collectionDirectoryContent.length, collectionDirectoryContent.length, true);
   // }
    if (await storage.read(key: "token")!=null) {
      syncTracks();
      syncPlaylists();
      syncGenerators();
    }
    this.notifyListeners();
  }


  Future<void> index({void Function(int completed, int total, bool isCompleted)? onProgress}) async {
    List<FileSystemEntity> directory = this.collectionDirectory.listSync(recursive: true);
    for (int index = 0; index < directory.length; index++) {
      FileSystemEntity object = directory[index];
      if (Methods.isFileSupported(object)) {
          Track.fromFile(object as File);

      }
      onProgress?.call(index + 1, directory.length, true);
    }


    onProgress?.call(directory.length, directory.length, true);
    this.notifyListeners();
  }

  Future<void> playlistAdd(Playlist playlist) async {
    final playlistsBox = Hive.box<Playlist>('playlists');
      playlistsBox.add(playlist);
    playlistsBox.close();
    this.notifyListeners();
  }

  Future<void> playlistRemove(int playlistIdx) async {
    final playlistsBox = Hive.box<Track>('tracks');
    playlistsBox.deleteAt(playlistIdx);
  playlistsBox.close();
    this.notifyListeners();
  }

  Future<void> playlistAddTrack(Playlist playlist, Track track) async {

    playlist.tracks.add(track);
    playlist.lastModif=DateTime.now();
  }

  Future<void> playlistRemoveTrack(Playlist playlist, Track track) async {

    final tracksBox = Hive.box<Track>('tracks');
    final playlistsBox = Hive.box<Playlist>('playlists');
    playlist.tracks.removeWhere((item) => item.hash == track.hash);
    playlist.lastModif=DateTime.now();

    playlistsBox.close();

    this.notifyListeners();
  }




 // List<TrackSyncInfo> _tracks = <TrackSyncInfo>[];
 // List<List<String>> _foundAlbums = <List<String>>[];
 // List<String> _foundArtists = <String>[];


  Future<void> generatorAdd(Generator generator) async {
    final generatorsBox = Hive.box<Generator>('generators');
    generatorsBox.put(generator.generatorId,generator);
//TODO: add date?+ try sync
    this.notifyListeners();
  }

  Future<void> generatorRemove(Generator generator) async {
    (generator..todel=true..lastModif=DateTime.now()).save();
    this.notifyListeners();
  }




}


late Collection _collection;
