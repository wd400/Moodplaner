import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:moodplaner/core/mediatype.dart';
import 'package:moodplaner/core/metrictype.dart';
import 'package:moodplaner/core/synchronization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moodplaner/utils/track_graph_widget.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:select_dialog/select_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;
import '../../login.dart';




class SmallMusicPlayer  extends StatefulWidget{
  final Track track;
  //{metricid:[[values],setbyuser]}


  SmallMusicPlayer({required this.track});

  @override
  _SmallMusicPlayerState createState() => _SmallMusicPlayerState();
}

class FractionPlayed extends ChangeNotifier {
  Duration value=new Duration();
  void update({required Duration value}) {
    this.value = value;
    this.notifyListeners();
  }
}

final fractionPlayedProvider=ChangeNotifierProvider.autoDispose<FractionPlayed>(
      (context) => FractionPlayed(),
);


class _SmallMusicPlayerState extends State<SmallMusicPlayer> {

  late AudioPlayer  advancedPlayer ;
  bool playing=false;
  // late AudioCache audioCache;
  late Duration _duration;

  late String audioSource;

  void seekToSecond(int second){
    Duration newDuration = Duration(seconds: second);

    advancedPlayer.seek(newDuration);
  }

  @override
  void initState() {
    super.initState();

    audioSource =  widget.track.filePath??'$SERVER_IP/songs/${widget.track.hash}';
    print('"'+audioSource+'"');

    _duration = new Duration();

    initPlayer();
  }

  void initPlayer(){
    advancedPlayer = new AudioPlayer();
//     audioCache = new AudioCache(fixedPlayer: advancedPlayer,prefix: '');
    advancedPlayer.onDurationChanged.listen((d) => setState(() {
      _duration = d;
    }));

    advancedPlayer.onAudioPositionChanged.listen((p) => setState(() {
      context.read(fractionPlayedProvider).update(value: p);
    }));

    advancedPlayer.onPlayerCompletion.listen((event) {
      setState(() {playing=false;});

    });

  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return       Row(children:[    IconButton(
      icon: Icon( playing ? Icons.pause : Icons.play_arrow),
      onPressed: ()

      {
        //here we will add the functionality of the play button
        if (!playing) {
          //now let's play the song
          advancedPlayer.play(audioSource);
          //       audioCache.play(audioSource);
        } else {
          advancedPlayer.pause();
        }


        setState(() {
          playing = !playing;
        });
      },),
    Expanded(child:

    Consumer(builder: (BuildContext context, T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {


      return Slider(
          value: watch(fractionPlayedProvider).value.inSeconds.toDouble(),
          min: 0.0,
          max: _duration.inSeconds.toDouble(),
          onChanged: (double value) {
            setState(() {
              seekToSecond(value.toInt());
              //TODO:l'enlever?
 //             value = value;

            });});
    },
     )

    )]);
  }

}