import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moodplaner/core/mediatype.dart';
import 'package:moodplaner/core/metrictype.dart';
import 'package:moodplaner/core/synchronization.dart';

import '../../login.dart';

class EditTrackMetrics  extends StatelessWidget{
final Track track;
  EditTrackMetrics({required this.track});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
          return Column(children: [
            SafeArea(child: Text(track.getName(), textAlign: TextAlign.center))
            , Flexible(child: ListView.builder(
              itemCount: METRICS.length,
              itemBuilder: (context, index) {
                return MetricTile(track: track,
                  metricInfo: METRICS[index],
                  metricValue: 0.5,
                  setByUser: true,);
              },
            ))
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
  MetricTile({Key? key,required this.track,required this.metricInfo,required this.metricValue,required this.setByUser}) : super(key: key);
  MetricTileState createState() => MetricTileState();

}

class MetricTileState extends State<MetricTile> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build


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

