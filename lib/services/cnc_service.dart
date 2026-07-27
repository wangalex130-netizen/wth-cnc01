import 'dart:async';
import 'package:flutter/foundation.dart';
import 'grbl_status_parser.dart';
import 'serial_port_adapter.dart';

enum CncMachineState { disconnected, idle, run, hold, alarm }

class CncService extends ChangeNotifier {
  final SerialPortAdapter _adapter = SerialPortAdapter();
  Timer? _statusPollTimer;

  CncMachineState _state = CncMachineState.disconnected;
  CncMachineState get state => _state;

  double _x = 0.0;
  double _y = 0.0;
  double _z = 0.0;

  double get x => _x;
  double get y => _y;
  double get z => _z;

  int _feedOverride = 100;
  int _spindleOverride = 100;

  int get feedOverride => _feedOverride;
  int get spindleOverride => _spindleOverride;

  CncService() {
    // 绑定下位机数据接收通道
    _adapter.onDataReceived = _onHardwareResponse;
  }

  /// 连接设备并开启 200ms 实时状态轮询定时器
  Future<bool> connect(String portOrAddress) async {
    final success = await _adapter.openPort(portOrAddress);
    if (success) {
      _state = CncMachineState.idle;

      // 启动 200ms GRBL 状态查询循环 (?)
      _statusPollTimer?.cancel();
      _statusPollTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (_adapter.isConnected) {
          _adapter.sendCommand('?');
        }
      });

      notifyListeners();
    }
    return success;
  }

  void disconnect() {
    _statusPollTimer?.cancel();
    _adapter.closePort();
    _state = CncMachineState.disconnected;
    notifyListeners();
  }

  /// 1. 三轴点动控制
  void jog({required String axis, required double distance, double feedRate = 1000}) {
    if (_state == CncMachineState.disconnected) return;

    final String cmd = '\$J=G91 G21 $axis${distance.toStringAsFixed(3)} F${feedRate.toInt()}';
    _adapter.sendCommand(cmd);

    // 本地快速推算更新，消除网络延迟卡顿感
    if (axis == 'X') _x += distance;
    if (axis == 'Y') _y += distance;
    if (axis == 'Z') _z += distance;
    notifyListeners();
  }

  /// 2. 原点设定 (G54)
  void setZero({bool x = true, bool y = true, bool z = true}) {
    String axes = '';
    if (x) axes += 'X0 ';
    if (y) axes += 'Y0 ';
    if (z) axes += 'Z0 ';
    _adapter.sendCommand('G10 L20 P1 $axes');

    if (x) _x = 0.0;
    if (y) _y = 0.0;
    if (z) _z = 0.0;
    notifyListeners();
  }

  /// 3. 实时倍率微调
  void setFeedOverride(int percent) {
    _feedOverride = percent.clamp(50, 150);
    _adapter.sendCommand('\x90'); // GRBL 实时 100% 进给重置字节
    notifyListeners();
  }

  void setSpindleOverride(int percent) {
    _spindleOverride = percent.clamp(50, 120);
    _adapter.sendCommand('\x99'); // GRBL 实时 100% 主轴转速重置字节
    notifyListeners();
  }

  /// 4. 实时安全控制
  void pauseProcessing() {
    _adapter.sendCommand('!'); // Feed Hold 实时字节
    _state = CncMachineState.hold;
    notifyListeners();
  }

  void resumeProcessing() {
    _adapter.sendCommand('~'); // Cycle Start 实时字节
    _state = CncMachineState.run;
    notifyListeners();
  }

  void emergencyStop() {
    _adapter.sendCommand('\x18'); // Ctrl+X 软复位
    _state = CncMachineState.alarm;
    notifyListeners();
  }

  /// 处理从物理下位机返回的串口行
  void _onHardwareResponse(String response) {
    // 尝试用 GRBL Status Parser 解析问号报文
    final statusData = GrblStatusParser.parse(response);
    if (statusData != null) {
      _x = statusData.x;
      _y = statusData.y;
      _z = statusData.z;
      if (_state != CncMachineState.alarm) {
        _state = statusData.state;
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _statusPollTimer?.cancel();
    _adapter.closePort();
    super.dispose();
  }
}
