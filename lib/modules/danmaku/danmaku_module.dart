import 'package:flutter/material.dart';
import 'package:kazumi/utils/utils.dart';

class Danmaku {
  // Danmaku content
  String message;
  // Danmaku time
  double time;
  // Danmaku type (1-normal, 4-bottom, 5-top)
  int type;
  // Danmaku color
  Color color;
  // Danmaku source ([BiliBili], [Gamer])
  String source;

  Danmaku({required this.message, required this.time, required this.type, required this.color, required this.source});

  factory Danmaku.fromJson(Map<String, dynamic> json) {
    String messageValue = json['m'];
    List<String> parts = json['p'].split(',');
    double timeValue = double.parse(parts[0]);
    int typeValue = int.parse(parts[1]);
    Color color = Utils.generateDanmakuColor(int.parse(parts[2]));
    String sourceValue = parts[3];
    return Danmaku(time: timeValue, message: messageValue, type: typeValue, color: color, source: sourceValue);
  }
}