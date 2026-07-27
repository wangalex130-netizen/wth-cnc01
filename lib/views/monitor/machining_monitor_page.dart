import 'package:flutter/material.dart';
import '../../services/cnc_service.dart';
import '../../services/cnc_provider.dart';
import '../../models/gcode_model.dart';
import '../../widgets/gcode_preview_canvas.dart';

class MachiningMonitorPage extends StatefulWidget {
  const MachiningMonitorPage({Super.key});

  @override
  State<MachiningMonitorPage> createState() => _MachiningMonitorPageState();
}

class _MachiningMonitorPageState extends State<MachiningMonitorPage> {
  GcodePath? _loadedPath;

  // 模拟示范 G-code 数据 (圆形/正方形切削轨迹)
  final String _demoGcode = '''
G0 X0 Y0 Z5
G1 Z-1 F300
G1 X50 Y0 F800
G1 X50 Y50
G1 X0 Y50
G1 X0 Y0
G0 Z5
''';

  @override
  Widget build(BuildContext context) {
    final cnc = CncProvider.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 1. 2D 轨迹预览卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('刀具加工轨迹预览', style: Theme.of(context).textTheme.titleMedium),
                    TextButton.icon(
                      icon: const Icon(Icons.file_open, size: 18),
                      label: const Text('载入示例文件'),
                      onPressed: () {
                        setState(() {
                          _loadedPath = GcodePath.parse(_demoGcode);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GcodePreviewCanvas(pathData: _loadedPath),
                if (_loadedPath != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('尺寸 X: ${_loadedPath!.width.toStringAsFixed(1)} mm',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('尺寸 Y: ${_loadedPath!.height.toStringAsFixed(1)} mm',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('节点数: ${_loadedPath!.points.length}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 2. 状态与进度卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('当前任务: Demo_Square.gcode'),
                    _buildStatusBadge(cnc.state),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: cnc.state == CncMachineState.run ? 0.68 : 0.0,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('加工进度: 68%'),
                    Text('预计剩余: 08 分 15 秒'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 3. 实时倍率控制
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('实时倍率干预 (Overrides)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.speed),
                    const SizedBox(width: 8),
                    Text('进给: ${cnc.feedOverride}%'),
                    Expanded(
                      child: Slider(
                        value: cnc.feedOverride.toDouble(),
                        min: 50,
                        max: 150,
                        divisions: 10,
                        label: '${cnc.feedOverride}%',
                        onChanged: (val) => cnc.setFeedOverride(val.toInt()),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.rotate_right),
                    const SizedBox(width: 8),
                    Text('主轴: ${cnc.spindleOverride}%'),
                    Expanded(
                      child: Slider(
                        value: cnc.spindleOverride.toDouble(),
                        min: 50,
                        max: 120,
                        divisions: 7,
                        label: '${cnc.spindleOverride}%',
                        onChanged: (val) => cnc.setSpindleOverride(val.toInt()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // 4. 急停与控制按键
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: Icon(cnc.state == CncMachineState.hold ? Icons.play_arrow : Icons.pause),
                label: Text(cnc.state == CncMachineState.hold ? '继续加工' : '暂停加工'),
                onPressed: () {
                  if (cnc.state == CncMachineState.hold) {
                    cnc.resumeProcessing();
                  } else {
                    cnc.pauseProcessing();
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.stop),
                label: const Text('急停 (E-STOP)'),
                onPressed: () => cnc.emergencyStop(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(CncMachineState state) {
    Color color;
    String text;

    switch (state) {
      case CncMachineState.run:
        color = Colors.green[700]!;
        text = '加工中';
        break;
      case CncMachineState.hold:
        color = Colors.amber[800]!;
        text = '已暂停';
        break;
      case CncMachineState.alarm:
        color = Colors.red[800]!;
        text = 'ALARM 报警';
        break;
      case CncMachineState.idle:
        color = Colors.blue[700]!;
        text = '空闲就绪';
        break;
      case CncMachineState.disconnected:
        color = Colors.grey[700]!;
        text = '未连接';
        break;
    }

    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
    );
  }
}
