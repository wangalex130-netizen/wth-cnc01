import 'dart:async';
import 'package:flutter/foundation.dart';
import 'cnc_service.dart';

class GcodeSenderService extends ChangeNotifier {
  final CncService cncService;

  GcodeSenderService({required this.cncService});

  List<String> _gcodeLines = [];
  int _currentLineIndex = 0;
  bool _isProcessing = false;
  bool _isPaused = false;

  Timer? _processingTimer;
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;

  List<String> get gcodeLines => _gcodeLines;
  int get currentLineIndex => _currentLineIndex;
  int get totalLines => _gcodeLines.length;
  bool get isProcessing => _isProcessing;
  bool get isPaused => _isPaused;
  int get elapsedSeconds => _elapsedSeconds;

  /// 进度百分比 (0.0 ~ 1.0)
  double get progress {
    if (_gcodeLines.isEmpty) return 0.0;
    return (_currentLineIndex / _gcodeLines.length).clamp(0.0, 1.0);
  }

  /// 格式化已用时间 (MM:SS)
  String get formattedElapsedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// 估算剩余时间 (MM:SS)
  String get formattedRemainingTime {
    if (progress <= 0 || _elapsedSeconds == 0) return '--:--';
    final totalEstimated = _elapsedSeconds / progress;
    final remaining = (totalEstimated - _elapsedSeconds).toInt();
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// 加载 G-code 文本
  void loadGcode(String content) {
    _gcodeLines = content
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith(';'))
        .toList();
    _currentLineIndex = 0;
    _elapsedSeconds = 0;
    notifyListeners();
  }

  /// 开始/恢复加工
  void startProcessing() {
    if (_gcodeLines.isEmpty) return;

    _isProcessing = true;
    _isPaused = false;
    notifyListeners();

    // 启动秒表定时器
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      notifyListeners();
    });

    // 启动 G-code 逐行下发调度器（模拟 100ms 下发一行）
    _processingTimer?.cancel();
    _processingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_currentLineIndex < _gcodeLines.length) {
        final line = _gcodeLines[_currentLineIndex];
        _executeLine(line);
        _currentLineIndex++;
        notifyListeners();
      } else {
        stopProcessing(); // 加工完成
      }
    });
  }

  /// 暂停加工
  void pauseProcessing() {
    _isPaused = true;
    _processingTimer?.cancel();
    _elapsedTimer?.cancel();
    cncService.pauseProcessing();
    notifyListeners();
  }

  /// 继续加工
  void resumeProcessing() {
    cncService.resumeProcessing();
    startProcessing();
  }

  /// 停止/复位
  void stopProcessing() {
    _isProcessing = false;
    _isPaused = false;
    _processingTimer?.cancel();
    _elapsedTimer?.cancel();
    cncService.setZero(x: false, y: false, z: false); // 保持坐标，回归空闲
    notifyListeners();
  }

  /// 解析 G-code 指令并驱动 CncService 更新实时坐标
  void _executeLine(String line) {
    final trimmed = line.toUpperCase();
    if (trimmed.startsWith('G0') || trimmed.startsWith('G1')) {
      final xMatch = RegExp(r'X(-?\d+\.?\d*)').firstMatch(trimmed);
      final yMatch = RegExp(r'Y(-?\d+\.?\d*)').firstMatch(trimmed);
      final zMatch = RegExp(r'Z(-?\d+\.?\d*)').firstMatch(trimmed);

      if (xMatch != null) {
        final targetX = double.parse(xMatch.group(1)!);
        cncService.jog(axis: 'X', distance: targetX - cncService.x);
      }
      if (yMatch != null) {
        final targetY = double.parse(yMatch.group(1)!);
        cncService.jog(axis: 'Y', distance: targetY - cncService.y);
      }
      if (zMatch != null) {
        final targetZ = double.parse(zMatch.group(1)!);
        cncService.jog(axis: 'Z', distance: targetZ - cncService.z);
      }
    }
  }

  @override
  void dispose() {
    _processingTimer?.cancel();
    _elapsedTimer?.cancel();
    super.dispose();
  }
}
