import 'dart:collection';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moodplaner/constants/language.dart';
import 'package:path/path.dart' as path;

class MetricInfo {
   late final String name;
   late final int metricId;
   late final MaterialColor color;
  MetricInfo({required this.name,required this.metricId,required this.color});
}

 List<MetricInfo> METRICS = [
    MetricInfo(name:language!.STRING_METRIC_ROCK,
              metricId: 0,color:Colors.brown),

   MetricInfo(name:language!.STRING_METRIC_BLUES,
       metricId: 1,color:Colors.blue),

   MetricInfo(name:language!.STRING_METRIC_HAPPY,
       metricId: 2,color:Colors.yellow),

 ];

class Measure {
  late MetricInfo metric;
  late List<double?> value;


  Map<String, dynamic> toMap() {
    return {
      'metricId': this.metric.metricId,
      'value': this.value,
    };
  }

  Measure({required this.metric,required this.value});
}