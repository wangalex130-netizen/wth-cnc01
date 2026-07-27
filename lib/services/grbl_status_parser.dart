import 'cnc_service.dart';

class GrblStatusData {
  final CncMachineState state;
  final double x;
  final double y;
  final double z;
  final int realFeedRate;
  final int realSpindleSpeed;

  GrblStatusData({
    required this.state,
    required this.x,
    required this.y,
    required this.z,
    required this.realFeedRate,
    required this.realSpindleSpeed,
  });
}

class GrblStatusParser {
  /// 解析 GRBL 实时返回的状态文本行
  static GrblStatusData? parse(String response) {
    final trimmed = response.trim();
    if (!trimmed.startsWith('<') || !trimmed.endsWith('>')) return null;

    final content = trimmed.substring(1, trimmed.length - 1);
    final parts = content.split('|');
    if (parts.isEmpty) return null;

    // 1. 解析主状态
    final stateStr = parts[0].toUpperCase();
    CncMachineState state = CncMachineState.idle;
    if (stateStr.startsWith('RUN')) {
      state = CncMachineState.run;
    } else if (stateStr.startsWith('HOLD')) {
      state = CncMachineState.hold;
    } else if (stateStr.startsWith('ALARM')) {
      state = CncMachineState.alarm;
    } else if (stateStr.startsWith('IDLE')) {
      state = CncMachineState.idle;
    }

    double x = 0.0, y = 0.0, z = 0.0;
    int feed = 0, spindle = 0;

    // 2. 解析坐标与速度段
    for (var i = 1; i < parts.length; i++) {
      final part = parts[i];

      // MPos:10.000,20.000,0.000 或 WPos:10.000,20.000,0.000
      if (part.startsWith('MPos:') || part.startsWith('WPos:')) {
        final coords = part.substring(5).split(',');
        if (coords.length >= 3) {
          x = double.tryParse(coords[0]) ?? 0.0;
          y = double.tryParse(coords[1]) ?? 0.0;
          z = double.tryParse(coords[2]) ?? 0.0;
        }
      }
      // FS:500,8000 (当前实时进给速率与主轴转速)
      else if (part.startsWith('FS:')) {
        final speeds = part.substring(3).split(',');
        if (speeds.length >= 2) {
          feed = int.tryParse(speeds[0]) ?? 0;
          spindle = int.tryParse(speeds[1]) ?? 0;
        }
      }
    }

    return GrblStatusData(
      state: state,
      x: x,
      y: y,
      z: z,
      realFeedRate: feed,
      realSpindleSpeed: spindle,
    );
  }
}
