import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:moodplaner/core/mediatype.dart';

import 'package:hive_flutter/hive_flutter.dart';


class BlacklistTracks  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Blacklist'),
        ),
        body: ValueListenableBuilder(

        valueListenable: Hive.box<Track>('tracks').listenable(),


        builder: (BuildContext context, Box<dynamic> trackBox,
            Widget? child) {
          List tracksKeys = trackBox.keys.toList();

          tracksKeys.retainWhere((element) =>
          (trackBox.get(element) as Track).todel == true);

          return ListView.builder(
            itemCount: tracksKeys.length,
            itemBuilder: (BuildContext context, int index) {
              Track track = trackBox.get(tracksKeys[index]);

              return ListTile(
                title: Text(track.getName()),
                trailing: IconButton(icon: Icon(Icons.remove), onPressed: () {
                  track.todel = false;
                  track.save();
                },

                ),

              );
            },

          );
        }));
  }
}