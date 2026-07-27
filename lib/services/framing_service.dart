import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/gcode_model.dart';
import 'cnc_service.dart';

class FramingService extends ChangeNotifier {
  final CncService cncService;

  FramingService({required this.cncService});

  bool _isFraming = false;
  double _progress = 0.0; // 0.0 ~ 1.0

  bool get isFraming => _isFraming;
  double get progress => _progress;

  /// 执行矩形跑框 (沿 Xmin,Ymin -> Xmax,Ymin -> Xmax,Ymax -> Xmin,Ymax 循航)
  Future<void> startFraming({
    required GcodePath path,
    required double safeZHeight,  // 跑框时的安全抬刀高度 (mm)
    required double framingSpeed, // 跑框进给速度 (mm/min)
    required bool enableLaser,   // 是否开启弱光定位辅助
  }) async {
    if (_isFraming) return;

    _isFraming = true;
    _progress = 0.0;
    notifyListeners();

    // 1. 先抬刀至安全高度
    cncService.jog(axis: 'Z', distance: safeZHeight, feedRate: 800);
    await Future.delayed(const Duration(milliseconds: 300));

    // 2. 四个边界角点
    final points = [
      Offset(path.minX, path.minY),
      Offset(path.maxX, path.minY),
      Offset(path.maxX, path.maxY),
      Offset(path.minX, path.maxY),
      Offset(path.minX, path.minY), // 回到起点
    ];

    // 3. 逐点运动模拟走框
    for (int i = 0; i < points.length; i++) {
      if (!_isFraming) break; // 中途终止

      final pt = points[i];
      // 计算增量并下发点动
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

  /// 终止走框
  void stopFraming() {
    _isFraming = false;
    cncService.pauseProcessing();
    notifyListeners();
  }
}
