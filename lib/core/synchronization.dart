
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'package:queue/queue.dart';

import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:moodplaner/constants/language.dart';
import 'package:moodplaner/main.dart';

import '../login.dart';
import 'mediatype.dart';

final queue = Queue(parallel: 2,timeout: Duration(minutes: 5));

final noInternet = SnackBar(content: Text(language!.STRING_NO_INTERNET));

 sendFile(String filename, String url) async {
  var request = MultipartRequest('POST', Uri.parse(url));
  request.files.add(
      await MultipartFile.fromPath(
          'music',
          filename
      )
  );
  request.headers.addAll( {"token": (await storage.read(key: "token"))!});
  return await request.send();
}

 Future<int> authNeeded() async {
   var connectivityResult = await (Connectivity().checkConnectivity());
   if (connectivityResult == ConnectivityResult.none) {
     return 1;
   }
   if (await goodToken()) {
     return 0;
   }
   return 2;
}

Future<bool> goodToken() async{
   String? token=await storage.read(key: "token");
   if (token==null || token==''){
     return false;
   }
  var res = await get( Uri.parse( '$SERVER_IP/ping'),   headers: {"token": token});
   if (res.statusCode==200){
     return true;
   }
   return false;
}

Future<void> sendTrackRequest(Track track) async {
  var res2 = await sendFile(track.filePath!, '$SERVER_IP/synctrack');
  if (res2.statusCode == 200) {
    track.synced = true;
    track.save();
  }
}
bool disableCheck=false;



Future<bool>  checkNewVersion() async {
  if (disableCheck) {
    return false;
  }
  var res = await get( Uri.parse( '$SERVER_IP/version'));
  print(res.body);
  if (res.statusCode == 200 && res.body!=VERSION) {
    disableCheck=true;
    return true;

  }
  return false;
}


Future<void> syncAll() async {

  if (await storage.read(key: "token")!=null) {
  syncTracks();
  syncPlaylists();
  syncGenerators();
  }

}

void syncTracks() async {
  Box<Track> trackBox=Hive.box<Track>('tracks');
//tracks.removeWhere((element) => element.todel!);
var res = await post(
    Uri.parse( '$SERVER_IP/synctracks'),
    body:  {'setData':(trackBox.values.toList()..removeWhere((element) => element.filePath==null)).map((e) => ['"'+e.hash!+'"',e.todel]).toList().toString()} , headers: {"token": (await storage.read(key: "token"))??''}
);
if(res.statusCode == 200) {
  List hashs=jsonDecode(res.body);
  for (Track alreadySynced in trackBox.values.toList()..removeWhere((element) => (hashs.contains(element.hash)))) {

    alreadySynced.synced=true;
    alreadySynced.save();

  }
  List<Future> futures = hashs.map((e) => sendTrackRequest(trackBox.get(e)!)).toList();
  await Future.wait(futures);

  for (String trackHash in hashs) {
    Track track = trackBox.get(trackHash)!;
    queue.add(()=>sendTrackRequest(track));
  }
} else {
//fail
return;
}
 }


 void syncPlaylists() async {
   Box<Playlist> playlistBox=Hive.box<Playlist>('playlists');

   List<Playlist> playlists = playlistBox.values.toList();
   DateTime localLastSync=Hive.box('configuration').get('lastGeneratorSync')??DateTime.fromMillisecondsSinceEpoch(0);
   playlists.retainWhere((element) => (element.lastModif.isAfter(localLastSync)));
       var res = await post(
       Uri.parse( '$SERVER_IP/syncplaylists'),
       body:  {'setData':playlists.map((e) => json.encode(e.toMap()) ).toList().toString(),
       'lastSync':localLastSync.toIso8601String()} ,
       headers: {"token": (await storage.read(key: "token"))??'' }
   );

   //renvoi {playlists:[playlistId,name,tracks,lastModified],time:lastSync(=Date du serv)}



   if (res.statusCode==200) {
     var jsonRes = jsonDecode(res.body.toString());
     var syncDate=DateTime.tryParse(jsonRes['time']);

     for (Playlist playlist in playlists) {
       if (playlist.todel) {
         playlistBox.delete(playlist.playlistId);
       } else {
  //       playlist.lastSync = syncDate;
         playlist.save();
       }
     }
     Box<Track> tracksBox=Hive.box<Track>('tracks');



       for (Map<String,dynamic>  ret in jsonRes['playlists']){

/*
           for (String hash in ret['tracks']) {
             if (!tracksBox.containsKey(hash)) {

               download.addTask(new DownloadTask(fileUri:  Uri.parse('$SERVER_IP/songs/$hash'),
                   saveLocation: Hive.box('configuration').get('collectionDirectory')+'/$hash'));

               tracksBox.put(hash, Track(hash:hash,todel: false));
             }
           }

*/
         Playlist newplaylist;
         if (playlistBox.keys.contains(ret['id'])) {
           newplaylist = playlistBox.get(ret['id'])!;
         } else {
           newplaylist=new Playlist(playlistId: ret['id']);
           playlistBox.put(ret['id'], newplaylist);
         }
           newplaylist.todel=false;
           newplaylist.playlistName=ret['title'];

           newplaylist.tracks=ret['tracks'].map<Track>((e)=> tracksBox.containsKey(e)? tracksBox.get(e)! : new Track(hash:e,todel: false)).toList();

           newplaylist.lastModif=DateTime.parse(ret['lastmodified']);
    //       newplaylist.lastSync=syncDate;
           newplaylist.save();
         }
     Hive.box('configuration').put('lastPlaylistSync',syncDate);
   } else if (res.statusCode==403) {
     //fail
     return;
   } else {

     return;
   }
   }


void syncGenerators()async {
  Box<Generator> generatorBox=Hive.box<Generator>('generators');

  List<Generator> generators = generatorBox.values.toList();
  DateTime localLastSync=Hive.box('configuration').get('lastGeneratorSync')??DateTime.fromMillisecondsSinceEpoch(0);
  generators.retainWhere((element) => element.lastModif.isAfter(localLastSync));

 // print( generators.map((e)=>e.toJson()).toSet().toString());
  print(generators.toList());
  var res = await post(
      Uri.parse( '$SERVER_IP/syncgenerators'),

      body:  {'setData':generators.map((e) => json.encode(e.toJson()) ).toList().toString(),
      'lastSync':localLastSync.toIso8601String()} , headers: {"token": (await storage.read(key: "token")).toString()}
  );

  if (res.statusCode==200) {

  //  print(res.body.toString());
    var jsonRes = jsonDecode(res.body.toString());
    print(jsonRes);
    var syncDate=DateTime.tryParse(jsonRes['time']);
    for (Generator generator in generators) {
      if (generator.todel) {
        generatorBox.delete(generator.generatorId);
      } else {
    //    generator.lastSync = syncDate;
        print(generator.measures);
       // generator.save();
      }
    }
      for (Map<String,dynamic> ret in jsonRes['generators']){
        print("ret");
        print(ret);
        Generator newgenerator;
        if (generatorBox.keys.contains(ret['id'])) {
          newgenerator = generatorBox.get(ret['id'])!;
        } else {
          newgenerator=new Generator(generatorId: ret['id']);
          generatorBox.put(ret['id'], newgenerator);
        }
        newgenerator.todel=false;
        newgenerator.generatorName=ret['title'];
        newgenerator.measures=ret['metrics'].map<String, List<double?>>((k, v) => MapEntry<String, List<double?>>(k,  v.cast<double?>()   ));
        newgenerator.lastModif=DateTime.parse(ret['lastmodified']);
 //       newgenerator.lastSync=syncDate;
        newgenerator.save();
      }

    Hive.box('configuration').put('lastGeneratorSync',syncDate);
  } else {
    //fail
    return;
  }
}


Future<bool> generatePlaylist(Generator generator) async {
  String token=(await storage.read(key: "token"))!;
  syncGenerators();
  var res = await get( Uri.parse( '$SERVER_IP/generate/'+generator.generatorId.toString()),   headers: {"token": token});
  if (res.statusCode==200){
    //todo:pas optim
    syncPlaylists();
    return true;
  }
  return false;
}