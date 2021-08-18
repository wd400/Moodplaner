
import 'package:flutter/material.dart';
import 'package:moodplaner/constants/language.dart';
class MetricInfo {
   late final String name;
   late final String metricCode;
   late final MaterialColor color;
  MetricInfo({required this.name,required this.metricCode,required this.color});
}

 Map<String,MetricInfo> METRICS = {
   'm1': MetricInfo(name: language!.STRING_METRIC_ROCK,
       metricCode: 'm1', color: Colors.brown),

   'm2': MetricInfo(name: language!.STRING_METRIC_BLUES,
       metricCode: 'm2', color: Colors.blue),

   'm3':MetricInfo(name: language!.STRING_METRIC_HAPPY,
       metricCode: 'm3', color: Colors.yellow),

 };

class Measure {
  late MetricInfo metric;
  late List<double?> value;


  Map<String, dynamic> toMap() {
    return {
      'metricId': this.metric.metricCode,
      'value': this.value,
    };
  }

  Measure({required this.metric,required this.value});
}