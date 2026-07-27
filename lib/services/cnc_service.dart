import 'dart:async';
import 'package:flutter/foundation.dart';

/// 设备状态枚举
enum CncMachineState { disconnected, idle, run, hold, alarm }

class CncService extends ChangeNotifier {
  // 基础连接与机器状态
  CncMachineState _state = CncMachineState.disconnected;
  CncMachineState get state => _state;

  // 三轴实时工件坐标 (WCO)
  double _x = 0.0;
  double _y = 0.0;
  double _z = 0.0;

  double get x => _x;
  double get y => _y;
  double get z => _z;

  // 当前倍率设置
  int _feedOverride = 100;
  int _spindleOverride = 100;

  int get feedOverride => _feedOverride;
  int get spindleOverride => _spindleOverride;

  // 模拟蓝牙/串口连接
  Future<bool> connect(String portOrAddress) async {
    // TODO: 后续在此处接入 flutter_libserialport 或 flutter_blue_plus
    _state = CncMachineState.idle;
    notifyListeners();
    return true;
  }

  void disconnect() {
    _state = CncMachineState.disconnected;
    notifyListeners();
  }

  // --- 1. 三轴点动控制 (Jogging) ---
  /// 下发点动指令，例如: $J=G91 G21 X10 F1000
  void jog({required String axis, required double distance, double feedRate = 1000}) {
    if (_state == CncMachineState.disconnected) return;

    final String command = '\$J=G91 G21 $axis$distance F${feedRate.toInt()}\n';
    _sendRawCommand(command);

    // 模拟更新本地坐标（硬件接入后由实时状态回报更新）
    if (axis == 'X') _x += distance;
    if (axis == 'Y') _y += distance;
    if (axis == 'Z') _z += distance;
    notifyListeners();
  }

  // --- 2. 原点设定 (Zero WCS) ---
  /// 设当前位置为 G54 工件零点
  void setZero({bool x = true, bool y = true, bool z = true}) {
    String axes = '';
    if (x) axes += 'X0 ';
    if (y) axes += 'Y0 ';
    if (z) axes += 'Z0 ';
    _sendRawCommand('G10 L20 P1 $axes\n');

    if (x) _x = 0.0;
    if (y) _y = 0.0;
    if (z) _z = 0.0;
    notifyListeners();
  }

  // --- 3. 实时倍率微调 (Overrides) ---
  /// 调节进给倍率 (GRBL realtime commands: 0x90=100%, 0x91=+10%, 0x92=-10%)
  void setFeedOverride(int percent) {
    _feedOverride = percent.clamp(50, 150);
    // TODO: 发送对应的 GRBL 实时字节码
    notifyListeners();
  }

  /// 调节主轴转速倍率 (0x99=100%, 0x9A=+10%, 0x9B=-10%)
  void setSpindleOverride(int percent) {
    _spindleOverride = percent.clamp(50, 120);
    // TODO: 发送对应的 GRBL 实时字节码
    notifyListeners();
  }

  // --- 4. 安全控制 (Realtime Safety) ---
  /// 暂停加工 (Feed Hold: '!')
  void pauseProcessing() {
    _sendRawCommand('!');
    _state = CncMachineState.hold;
    notifyListeners();
  }

  /// 恢复加工 (Cycle Start: '~')
  void resumeProcessing() {
    _sendRawCommand('~');
    _state = CncMachineState.run;
    notifyListeners();
  }

  /// 紧急停止 / 软复位 (Reset: 0x18 / Ctrl+X)
  void emergencyStop() {
    _sendRawCommand('\x18');
    _state = CncMachineState.alarm;
    notifyListeners();
  }

  /// 发送原始 G-code 命令的内部入口
  void _sendRawCommand(String cmd) {
    // 在此处打印下发日志，方便调试
    debugPrint('[CNC Out]: $cmd');
  }
}
