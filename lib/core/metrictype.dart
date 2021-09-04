
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
   'v': MetricInfo(name: language!.STRING_VALENCE,
       metricCode: 'v', color: Colors.brown,binf: language!.STRING_INF_VALENCE ,bsup: language!.STRING_SUP_VALENCE),

   'a': MetricInfo(name: language!.STRING_AROUSAL,
       metricCode: 'a', color: Colors.blue,binf: language!.STRING_INF_AROUSAL,bsup: language!.STRING_SUP_AROUSAL),

   'bpm':MetricInfo(name: language!.STRING_BPM,
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