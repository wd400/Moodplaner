import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:moodplaner/core/mediatype.dart';
import 'package:moodplaner/core/metrictype.dart';
import 'package:moodplaner/core/synchronization.dart';

import 'package:http/http.dart' as http;
import '../../login.dart';

class EditTrackMetrics  extends StatelessWidget{
final Track track;
  EditTrackMetrics({required this.track});
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
          return Column(

              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            SafeArea(child: Text(track.getName(), textAlign: TextAlign.center)),
         Flexible(child:   FutureBuilder(
                future:storage.read(key: "token").then((value) => http.read(Uri.parse('$SERVER_IP/getmetrics/'+track.hash!), headers: {"token": value??''}  )),
                builder: (context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData ) {
                    //
                    final Map<String, dynamic>  result = json.decode(snapshot.data!);

                    return ListView.builder(
                      itemCount: METRICS.length,
                      itemBuilder: (context, index) {
                        return    MetricTile(track: track,
                          metricInfo: METRICS[index],
                          metricValue: result[index.toString()]?[0]??0.5,
                          setByUser: result[index.toString()]?[1]??true,);
                      },
                    );
                  } else if (snapshot.hasError) {
                  return Text("An error occurred");
                  } else {
                  return   CircularProgressIndicator();
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


class MetricTile  extends StatefulWidget {
  final Track track;
  final MetricInfo metricInfo;
  double metricValue;
  bool setByUser;

  late final double initmetricValue;
 late final bool initsetByUser;

  MetricTile({Key? key,required this.track,required this.metricInfo,required this.metricValue,required this.setByUser}) : super(key: key) {
    initmetricValue=metricValue;
    initsetByUser=setByUser;
  }
  MetricTileState createState() => MetricTileState();




}

class MetricTileState extends State<MetricTile> {

  @override
  void dispose()  {
//TODO:await
  if (widget.initsetByUser!=widget.setByUser || widget.initmetricValue!=widget.metricValue) {

    storage.read(key: "token").then((value) =>

        post(
            Uri.parse('$SERVER_IP/uploadmetric'),
            body: {'musicId': widget.track.hash,
              'metricId': widget.metricInfo.metricId.toString(),
              'metricValue': widget.metricValue.toString(),
              'setByUser': widget.setByUser.toString()},
            headers: {"token": value ?? ''
            }
        )

    );
  }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Container(height: 100, child:
    Row(children:
    [
      Flexible(child: Column(children: [
        Flexible(child:
        Text(widget.metricInfo.name, textAlign: TextAlign.center),
        ),
        Flexible(child: Slider(activeColor: widget.metricInfo.color,
            value: widget.metricValue,
            onChanged: widget.setByUser ? (double value) {
              setState(() {
                widget.metricValue = value;
              });
            } : null))

      ])),
      Column(children: [
        Icon(Icons.mode_edit),
        Checkbox(
          value: widget.setByUser,
          onChanged: (bool? value) {
            if (value != null) {
              setState(() {
                widget.setByUser = value;
              });
            }
          }
          ,)
      ])
    ]

    ));
  }
}

