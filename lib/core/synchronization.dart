
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';


import 'package:hive/hive.dart';
import 'package:http/http.dart';

import '../login.dart';
import 'mediatype.dart';

final noInternet = SnackBar(content: Text('No internet'));

 sendFile(String filename, String url) async {
  var request = MultipartRequest('POST', Uri.parse(url));
  request.files.add(
      await MultipartFile.fromPath(
          'music',
          filename
      )
  );
  request.headers.addAll( {"Authorization": (await storage.read(key: "token"))!});
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
   if (token==null){
     return false;
   }
  var res = await get( Uri.parse( '$SERVER_IP/ping'),   headers: {"Authorization": token});
   if (res.statusCode==200){
     return true;
   }
   return false;
}


void syncTracks() async {
  Box<Track> trackBox=Hive.box<Track>('tracks');
List<Track> tracks = trackBox.values.toList();
tracks.removeWhere((element) => element.todel!);

var res = await post(
    Uri.parse( '$SERVER_IP/synctracks'),
    body:  tracks.map((e) => e.hash).toList() , headers: {"Authorization": (await storage.read(key: "token"))!}
);
if(res.statusCode == 200) {
  var hashs=jsonDecode(res.body);
  for (String trackHash in hashs) {
    Track track = trackBox.get(trackHash)!;
    res = await sendFile(track.filePath!, '$SERVER_IP/synctracks');
    if (res.statusCode == 200) {
      track.synced = true;
      track.save();
    } else {
      //fail
      return;
    }
  }
} else {
//fail
return;
}
 }

 void syncPlaylists()async {
   Box<Playlist> playlistBox=Hive.box<Playlist>('playlists');

   List<Playlist> playlists = playlistBox.values.toList();
   playlists.retainWhere((element) => ((element.lastSync==null)?true:element.lastModif.isAfter(element.lastSync!)));
   var res = await post(
       Uri.parse( '$SERVER_IP/syncplaylists'),
       body:  playlists.map((e) => [e.playlistId,e.playlistName,e.tracks,e.todel,e.lastModif] ).toSet() , headers: {"Authorization": (await storage.read(key: "token")).toString()}
   );

   //renvoi {playlists:[playlistId,name,tracks,last,lastModified],time:lastSync(=Date du serv)}

   var jsonRes = jsonDecode(res.body.toString());
   var syncDate=DateTime.tryParse(jsonRes['time']);

   if (res.statusCode==200) {
     for (Playlist playlist in playlists){
       if (playlist.todel) {
         playlistBox.delete(playlist.playlistId);
       } else {
         playlist.lastSync=syncDate;
         playlist.save();
       }

       for (List ret in jsonRes['playlists']){
         Playlist newplaylist;
         if (playlistBox.keys.contains(ret[0])) {
           newplaylist = playlistBox.get(ret[0])!;
         } else {
           newplaylist=new Playlist(playlistId: ret[0]);
           playlistBox.put(ret[0], newplaylist);
         }
           newplaylist.todel=false;
           newplaylist.playlistName=ret[1];
           newplaylist.tracks=ret[2];
           newplaylist.lastModif=ret[3];
           newplaylist.lastSync=syncDate;
           newplaylist.save();
         }
       }

   } else {
     //fail
     return;
   }
 }

void syncGenerators()async {
  Box<Generator> generatorBox=Hive.box<Generator>('generators');

  List<Generator> generators = generatorBox.values.toList();
  generators.retainWhere((element) => ((element.lastSync==null)?true:element.lastModif.isAfter(element.lastSync!)));
  var res = await post(
      Uri.parse( '$SERVER_IP/syncplaylists'),
      body:  generators.map((e) => [e.generatorId,e.generatorId,e.measures,e.todel,e.lastModif] ).toSet() , headers: {"Authorization": (await storage.read(key: "token")).toString()}
  );

  //renvoi {playlists:[playlistId,name,tracks,last,lastModified],time:lastSync(=Date du serv)}

  var jsonRes = jsonDecode(res.body.toString());
  var syncDate=DateTime.tryParse(jsonRes['time']);

  if (res.statusCode==200) {
    for (Generator generator in generators){
      if (generator.todel) {
        generatorBox.delete(generator.generatorId);
      } else {
        generator.lastSync=syncDate;
        generator.save();
      }

      for (List ret in jsonRes['playlists']){
        Generator newgenerator;
        if (generatorBox.keys.contains(ret[0])) {
          newgenerator = generatorBox.get(ret[0])!;
        } else {
          newgenerator=new Generator(generatorId: ret[0]);
          generatorBox.put(ret[0], newgenerator);
        }
        newgenerator.todel=false;
        newgenerator.generatorName=ret[1];
        newgenerator.measures=ret[2];
        newgenerator.lastModif=ret[3];
        newgenerator.lastSync=syncDate;
        newgenerator.save();
      }
    }

  } else {
    //fail
    return;
  }
}


Future<bool> generatePlaylist(Generator generator) async {
  String token=(await storage.read(key: "token"))!;
  syncGenerators();
  var res = await get( Uri.parse( '$SERVER_IP/generate/'+generator.generatorId.toString()),   headers: {"Authorization": token});
  if (res.statusCode==200){
    //todo:pas optim
    syncPlaylists();
    return true;
  }
  return false;
}