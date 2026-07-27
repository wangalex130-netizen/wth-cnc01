import 'package:flutter/material.dart';
import '../../services/cnc_service.dart';
import '../../services/cnc_provider.dart';

class MachiningMonitorPage extends StatelessWidget {
  const MachiningMonitorPage({Super.key});

  @override
  Widget build(BuildContext context) {
    final cnc = CncProvider.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 状态与任务卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('任务: Aluminium_Cover.gcode'),
                    _buildStatusBadge(cnc.state),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: cnc.state == CncMachineState.run ? 0.68 : 0.0,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
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

        // 倍率微调控制器
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('实时倍率干预 (Overrides)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
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
        const SizedBox(height: 24),

        // 安全急停控制按键
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
