import 'package:flutter/material.dart';
import '../services/cnc_service.dart';
import '../services/cnc_provider.dart';

class DeviceConnectionModal extends StatefulWidget {
  const DeviceConnectionModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const DeviceConnectionModal(),
    );
  }

  @override
  State<DeviceConnectionModal> createState() => _DeviceConnectionModalState();
}

class _DeviceConnectionModalState extends State<DeviceConnectionModal> {
  bool _isScanning = false;

  // 模拟搜索到的硬件列表
  final List<Map<String, String>> _devices = [
    {'name': 'Smart CNC 3020 (BLE)', 'id': 'BT:88:21:AC:01'},
    {'name': 'USB Serial Port (CH340)', 'id': 'COM3'},
  ];

  void _toggleScan() {
    setState(() => _isScanning = !_isScanning);
    if (_isScanning) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isScanning = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cnc = CncProvider.of(context);
    final isConnected = cnc.state != CncMachineState.disconnected;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('设备连接管理', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 当前设备状态卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isConnected
                  ? Colors.green.withOpacity(0.15)
                  : Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isConnected ? Colors.green : Colors.redAccent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: isConnected ? Colors.green : Colors.redAccent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConnected ? 'Smart CNC 3020 Pro' : '设备未连接',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isConnected ? '波特率: 115200 | 信号强' : '请开启蓝牙或插入 USB 控制线',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (isConnected)
                  OutlinedButton(
                    onPressed: () {
                      cnc.disconnect();
                      setState(() {});
                    },
                    child: const Text('断开'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 扫描控制栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('附近可连接设备', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton.icon(
                icon: _isScanning
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(_isScanning ? '扫描中...' : '重新扫描'),
                onPressed: _isScanning ? null : _toggleScan,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 可用设备列表
          ..._devices.map(
            (dev) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF2A2A2A),
                child: Icon(Icons.memory, color: Colors.white70),
              ),
              title: Text(dev['name']!),
              subtitle: Text(dev['id']!, style: const TextStyle(fontSize: 12)),
              trailing: FilledButton.tonal(
                onPressed: isConnected
                    ? null
                    : () {
                        cnc.connect(dev['id']!);
                        Navigator.pop(context);
                      },
                child: const Text('连接'),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
