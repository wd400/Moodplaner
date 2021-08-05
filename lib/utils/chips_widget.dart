import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moodplaner/core/metrictype.dart';
import 'graph_widget.dart';



class ChipWidget extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ChipDemoState();
}

class _ChipDemoState extends State<ChipWidget> {


  int? _choiceIndex;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (BuildContext context, T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {
     GraphData graphData = watch(graphDataProvider);
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: graphData.generator.measures.length,
        itemBuilder: (BuildContext context, int index) {
          int key = graphData.generator.measures.keys.elementAt(index);
          return InputChip(
            selected: _choiceIndex == index,
            padding: EdgeInsets.all(2.0),
            label: Text(METRICS[key].name),
            backgroundColor: METRICS[key].color,
            selectedColor: METRICS[key].color,



            onSelected: (bool selected) {
              setState(() {
                _choiceIndex = selected ? index : null;
                print("NEW KEY");
                print(key);
                context.read(currentMetricIdProvider).update(metricId: selected?key:null);
                print("SET KEY");
                print(context.read(currentMetricIdProvider).metricId);
              });
            },
            onDeleted: () {
              context.read(graphDataProvider).delMetric(key);
              if (index==_choiceIndex){
    setState(() {
      _choiceIndex = null;
    });
                context.read(currentMetricIdProvider).update(metricId: null);
              }
            },
          );
        },
      );
    });
  }
}

class CompanyWidget {
  const CompanyWidget(this.name);
  final String name;
}