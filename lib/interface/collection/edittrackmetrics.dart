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
import 'package:moodplaner/utils/small_music_player.dart';
import 'package:moodplaner/utils/track_graph_widget.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:select_dialog/select_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:http/http.dart' as http;
import '../../login.dart';

class MusicMetricData extends ChangeNotifier {
   String? metricName;
  updateCurentMetric(String mn) {
    this.metricName=mn;
    notifyListeners();
  }
}

final musicMetricNameProvider=ChangeNotifierProvider.autoDispose<MusicMetricData>(
      (context) => MusicMetricData(),
);

class ZoomTrack extends ChangeNotifier {
  double value;
  ZoomTrack({required this.value});
  void update({required double value}) {
    this.value = value;
    this.notifyListeners();
  }
}

final zoomTrackProvider=ChangeNotifierProvider.autoDispose<ZoomTrack>(
      (context) => ZoomTrack(value: 0.5),
);

class PaintSettings extends ChangeNotifier {
  bool bargraph=false;

  PaintSettings();

  void updatebargraph({required bool value}) {
    this.bargraph = value;
    this.notifyListeners();
  }

}

final paintSettingsProvider=ChangeNotifierProvider.autoDispose<PaintSettings>(
      (context) => PaintSettings(),
);

class EditTrackMetrics  extends StatefulWidget{
  final Track track;
  //{metricid:[[values],setbyuser]}


  EditTrackMetrics({required this.track});

  @override
  _EditTrackMetricsState createState() => _EditTrackMetricsState();
}

class _EditTrackMetricsState extends State<EditTrackMetrics> {
   Map<String,dynamic> trackMetrics={};

   @override
   void initState() {
     super.initState();

     SystemChrome.setPreferredOrientations([
       DeviceOrientation.landscapeRight,
       DeviceOrientation.landscapeLeft,
       //   DeviceOrientation.portraitUp,
       //   DeviceOrientation.portraitDown,
     ]);


   }


   @override
  void dispose()  {


    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

//TODO:await

    storage.read(key: "token").then((value) =>

        post(
            Uri.parse('$SERVER_IP/uploadmetric'),
            body: {'musicId': widget.track.hash,

              'data':json.encode(trackMetrics['usermetrics'])
            },
            headers: {"token": value ?? ''
            }
        )

    );
    super.dispose();

  }








  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(

      ///If future is null then API will not be called as soon as the screen
      ///loads. This can be used to make this Future Builder dependent
      ///on a button click.
        future: authNeeded(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data) {
              case 2:
                return LoginPage();
              case 1:
                ScaffoldMessenger.of(context).showSnackBar(noInternet);
                return Icon(Icons.wifi_off);
              case 0:
                return

                  Column(

                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  SafeArea(child:  Row(children:[

                    IconButton(
                      icon: Icon(Icons.list),
                      onPressed: () {


                            SelectDialog.showModal<String>(
                              context,
                              label: "Select a metric",
                              selectedValue: "",
                              items: METRICS.values.map((e) => e.name).toList(),
                              onChange: (String selected) {
                                for (String metricId in METRICS.keys) {
                                  if (METRICS[metricId]?.name==selected){
                                    context.read(musicMetricNameProvider).updateCurentMetric(metricId);
                                    break;
                                  }
                                }
                              },
                            );


                      },
                    ),


          Text(widget.track.getName(), textAlign: TextAlign.center),

     Expanded(child:                SmallMusicPlayer(track: widget.track,))


                  ])),
                      Flexible(child:   FutureBuilder(
                          future:storage.read(key: "token").then((value) => http.read(Uri.parse('$SERVER_IP/getmetrics/'+widget.track.hash!), headers: {"token": value??''}  )),
                          builder: (context, AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData ) {
                              //
                                trackMetrics = json.decode(snapshot.data!);
                              final deltaTime = Duration(microseconds: (trackMetrics['step']*1000000).floor());
                              //usermetrics
                              //{'m1':[...],'m2':[...],'bpm':[...]}
                              //default
                              //{'m1':[...],'m2':[...],'bpm':[...],'duration':[...]}
                              //List available=result['default'].keys.toList();
                              return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Flexible(
                                        child: Row(
//      mainAxisAlignment: MainAxisAlignment.center,
//     crossAxisAlignment: CrossAxisAlignment.end,
                                            children: <Widget>[
                                              SizedBox(width:   35,
                                                  child:Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      children: <Widget>[
                                                        const Icon(Icons.zoom_in),
                                                        Flexible(child:
                                                        RotatedBox(
                                                          quarterTurns: -1,
                                                          child: Consumer(
                                                            builder: (BuildContext context, T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {
                                                              var value=watch(zoomTrackProvider).value;
                                                              return Slider(
                                                                value:  value,
                                                                onChanged: (newValue) {
                                                                  context.read(zoomTrackProvider).update(value:newValue);
                                                                },
                                                                onChangeEnd:  (newValue) {
                                                                  //TODO: code redondant
                                                                  context.read(zoomTrackProvider).update(value:newValue);
                                                                } ,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        ),
                                                        const Icon(Icons.zoom_out),

                                                      ])),

                                              Flexible(
                                                  child: Container(
                                                      margin: const EdgeInsets.all(15.0),
                                                      padding: const EdgeInsets.all(3.0),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.blueAccent)
                                                      ),
                                                      child: Stack(fit: StackFit.expand, children: <Widget>[

                                                        ClipRect(
                                                          //  borderRadius: BorderRadius.circular(10),
                                                            child:

                                                            Container(
//     color: Colors.tealAccent,
                                                                child: LayoutBuilder(
                                                                    builder: (context, constraints) {
                                                                      return DrawableMusicBoard(constraints: constraints,trackMetrics: trackMetrics,
                                                                          deltaTime:deltaTime );

                                                                    }

                                                                )

                                                            )),
                                                        Align(
                                                          alignment: Alignment.topRight,
                                                          child: MouseRegion(
                                                            cursor: SystemMouseCursors.click,
                                                            child:
      ToggleSwitch(

                                                              minHeight: 30,
                                                              minWidth: 40.0,

//       cornerRadius: 20.0,
//   activeBgColors: [[Colors.cyan], [Colors.redAccent]],
//   activeFgColor: Colors.white,
//  inactiveBgColor: Colors.grey,
//   inactiveFgColor: Colors.white,
                                                              totalSwitches: 2,
                                                              icons: const [
                                                                FontAwesomeIcons.chartLine,
                                                                FontAwesomeIcons.chartBar
                                                              ],

                                                              onToggle: (index) {
                                                                context.read(paintSettingsProvider).updatebargraph(value: index==1);

                                                              },
                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment.bottomRight,
                                                          child: MouseRegion(
                                                            cursor: SystemMouseCursors.click,
                                                            child:
    Consumer(
    builder: (BuildContext context, T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {
    String? name=watch(musicMetricNameProvider).metricName;
    int initialIndex=(trackMetrics['usermetrics'][name]?[1]??true)?1:0;
    print(initialIndex);
                      return                                      ToggleSwitch(
//     minWidth: 90.0,
//       cornerRadius: 20.0,
//   activeBgColors: [[Colors.cyan], [Colors.redAccent]],
//   activeFgColor: Colors.white,
//  inactiveBgColor: Colors.grey,
//   inactiveFgColor: Colors.white,
                                                              initialLabelIndex: initialIndex,
                                                              totalSwitches: 2,
                                                              icons: const [

                                                                FontAwesomeIcons.cogs,
                                                                FontAwesomeIcons.user
                                                              ],
                                                              onToggle: (index) {
                                                                String? metricName=context.read(musicMetricNameProvider).metricName;
                                                                if (metricName!=null) {
                                                                  trackMetrics['usermetrics'][metricName][1] =
                                                                      index == 1;
                                                                }

                                                              },
                                                            );}),
                                                          ),
                                                        ),
                                                      ]))),
                                            ])
                                    ),


                                    //  Flexible(child:Container())






                                  Text('Engine version: ' + ((trackMetrics['version']==null)?  'Not yet analyzed':trackMetrics['version'].toString() ),textAlign: TextAlign.center,),]);
                            } else if (snapshot.hasError) {
                              return Text("An error occurred");
                            } else {
                              return  Center(child: CircularProgressIndicator());
                            }
                          }      )),


                    ]);
              default:
                return Icon(Icons.error);
            }
          } else if (snapshot.hasError) {
            return Icon(Icons.error);
          } else {
            return Center(child: SizedBox(width:60, height:60,child: CircularProgressIndicator()));

          }



        });
  }
}


