import 'package:flutter/material.dart';

class GcodePath {
  final List<Offset> points;
  final double minX, maxX, minY, maxY;

  GcodePath({
    required this.points,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  /// 宽度 (mm)
  double get width => maxX - minX;

  /// 高度 (mm)
  double get height => maxY - minY;

  /// 从 G-code 字符串快速解析 X/Y 轨迹数据
  factory GcodePath.parse(String gcodeContent) {
    List<Offset> pts = [];
    double currX = 0.0;
    double currY = 0.0;
    double minX = 0.0, maxX = 0.0, minY = 0.0, maxY = 0.0;

    final lines = gcodeContent.split('\n');
    for (var line in lines) {
      final trimmed = line.trim().toUpperCase();
      // 匹配快速定位(G0)和直线切削(G1)
      if (trimmed.startsWith('G0') || trimmed.startsWith('G1')) {
        final xMatch = RegExp(r'X(-?\d+\.?\d*)').firstMatch(trimmed);
        final yMatch = RegExp(r'Y(-?\d+\.?\d*)').firstMatch(trimmed);

        if (xMatch != null) currX = double.parse(xMatch.group(1)!);
        if (yMatch != null) currY = double.parse(yMatch.group(1)!);

        pts.add(Offset(currX, currY));

        if (currX < minX) minX = currX;
        if (currX > maxX) maxX = currX;
        if (currY < minY) minY = currY;
        if (currY > maxY) maxY = currY;
      }
    }

    return GcodePath(
      points: pts,
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
    );
  }
}
