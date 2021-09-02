
import 'package:flutter/material.dart';
import 'package:moodplaner/constants/language.dart';
class MetricInfo {
   late final String name;
   late final String metricCode;
   late final MaterialColor color;
   late final String binf;
   late final String bsup;
  MetricInfo({required this.name,required this.metricCode,required this.color,required this.binf,required this.bsup});
}

 Map<String,MetricInfo> METRICS = {
   'v': MetricInfo(name: "Valence",
       metricCode: 'v', color: Colors.brown,binf: "Low",bsup: "High"),

   'a': MetricInfo(name: "Arousal",
       metricCode: 'a', color: Colors.blue,binf: "Negative",bsup: "Positive"),

   'bpm':MetricInfo(name: "BPM",
       metricCode: 'bpm', color: Colors.yellow,binf: "<50",bsup: ">180"),

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