import 'dart:async';
import 'package:flutter/material.dart'; // 必须导入包以引入 Offset
import '../models/gcode_model.dart';
import 'cnc_service.dart';

class FramingService extends ChangeNotifier {
  final CncService cncService;

  FramingService({required this.cncService});

  bool _isFraming = false;
  double _progress = 0.0;

  bool get isFraming => _isFraming;
  double get progress => _progress;

  Future<void> startFraming({
    required GcodePath path,
    required double safeZHeight,
    required double framingSpeed,
    required bool enableLaser,
  }) async {
    if (_isFraming) return;

    _isFraming = true;
    _progress = 0.0;
    notifyListeners();

    cncService.jog(axis: 'Z', distance: safeZHeight, feedRate: 800);
    await Future.delayed(const Duration(milliseconds: 300));

    final points = [
      Offset(path.minX, path.minY),
      Offset(path.maxX, path.minY),
      Offset(path.maxX, path.maxY),
      Offset(path.minX, path.maxY),
      Offset(path.minX, path.minY),
    ];

    for (int i = 0; i < points.length; i++) {
      if (!_isFraming) break;

      final pt = points[i];
      final deltaX = pt.dx - cncService.x;
      final deltaY = pt.dy - cncService.y;

      if (deltaX != 0) cncService.jog(axis: 'X', distance: deltaX, feedRate: framingSpeed);
      if (deltaY != 0) cncService.jog(axis: 'Y', distance: deltaY, feedRate: framingSpeed);

      _progress = (i + 1) / points.length;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 600));
    }

    _isFraming = false;
    _progress = 1.0;
    notifyListeners();
  }

  void stopFraming() {
    _isFraming = false;
    cncService.pauseProcessing();
    notifyListeners();
  }
}
