import 'dart:async';
import 'package:flutter/foundation.dart';

class SerialPortAdapter {
  static const int maxBufferSize = 128; // GRBL 硬件串口 RX 缓冲区最大 128 字节
  int _currentBufferLength = 0;

  final List<String> _txQueue = [];
  final List<int> _sentLengthQueue = []; // 维护已下发但未收到 ok 的指令字节长度

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // 接收数据回调 (发送给 Parser)
  void Function(String response)? onDataReceived;

  Future<bool> openPort(String portName) async {
    // 模拟底层的 Native 串口打开逻辑 (如 flutter_libserialport)
    _isConnected = true;
    _currentBufferLength = 0;
    _txQueue.clear();
    _sentLengthQueue.clear();
    debugPrint('[SerialPort]: 成功打开串口 $portName, 波特率: 115200');
    return true;
  }

  void closePort() {
    _isConnected = false;
    _txQueue.clear();
    _sentLengthQueue.clear();
    _currentBufferLength = 0;
    debugPrint('[SerialPort]: 串口已关闭');
  }

  /// 入列一条 G-code 指令，并通过字符计数器逻辑尝试下发
  void sendCommand(String command) {
    if (!_isConnected) return;

    final formatted = command.endsWith('\n') ? command : '$command\n';
    _txQueue.add(formatted);
    _processTxQueue();
  }

  /// 处理待发送队列：只要未超过 128 字节限制，就立刻持续下发
  void _processTxQueue() {
    while (_txQueue.isNotEmpty) {
      final nextCmd = _txQueue.first;
      final cmdByteLength = nextCmd.length;

      // 如果加进去超过 128 字节，则暂停下发，等待下位机返回 'ok'
      if (_currentBufferLength + cmdByteLength > maxBufferSize) {
        break;
      }

      _txQueue.removeAt(0);
      _currentBufferLength += cmdByteLength;
      _sentLengthQueue.add(cmdByteLength);

      // 模拟底层实际向 TX 导线写入数据
      _rawWriteToHardware(nextCmd);
    }
  }

  /// 模拟接收下位机数据 (由硬件中断触发)
  void handleHardwareIncomingData(String rawResponse) {
    final trimmed = rawResponse.trim();

    // 当下位机返回 ok 或 error 时，释放对应指令占用的缓冲区空间
    if (trimmed == 'ok' || trimmed.startsWith('error:')) {
      if (_sentLengthQueue.isNotEmpty) {
        final releasedBytes = _sentLengthQueue.removeAt(0);
        _currentBufferLength -= releasedBytes;
        if (_currentBufferLength < 0) _currentBufferLength = 0;
      }
      _processTxQueue(); // 尝试下发后续积压指令
    }

    onDataReceived?.call(rawResponse);
  }

  void _rawWriteToHardware(String data) {
    debugPrint('[TX Raw -> Hardware]: ${data.trim()} (Buf: $_currentBufferLength/$maxBufferSize)');
    
    // 模拟下位机极快响应 ok
    Future.delayed(const Duration(milliseconds: 30), () {
      if (_isConnected) {
        handleHardwareIncomingData('ok');
      }
    });
  }
}
