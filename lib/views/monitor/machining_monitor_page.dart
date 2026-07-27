import 'package:flutter/material.dart';

class MachiningMonitorPage extends StatefulWidget {
  const MachiningMonitorPage({Super.key});

  @override
  State<MachiningMonitorPage> createState() => _MachiningMonitorPageState();
}

class _MachiningMonitorPageState extends State<MachiningMonitorPage> {
  double _feedRateOverride = 100.0; // 进给倍率 50% - 150%
  double _spindleSpeedOverride = 100.0; // 主轴倍率 50% - 120%
  final double _progress = 0.45; // 模拟当前加工进度 45%

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 进度与状态看板
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('当前任务: Phone_Case_v2.nc'),
                    Chip(
                      label: const Text('雕刻中', style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green[700],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _progress,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('进度: ${(_progress * 100).toInt()}%'),
                    const Text('预计剩余时间: 12 分 30 秒'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 倍率微调控制区域 (拓竹风格卡片)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('实时切削控制', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                
                // 进给倍率
                Row(
                  children: [
                    const Icon(Icons.speed),
                    const SizedBox(width: 8),
                    Text('进给速度: ${_feedRateOverride.toInt()}%'),
                    Expanded(
                      child: Slider(
                        value: _feedRateOverride,
                        min: 50,
                        max: 150,
                        divisions: 10,
                        label: '${_feedRateOverride.toInt()}%',
                        onChanged: (val) {
                          setState(() => _feedRateOverride = val);
                        },
                      ),
                    ),
                  ],
                ),

                // 主轴转速倍率
                Row(
                  children: [
                    const Icon(Icons.rotate_right),
                    const SizedBox(width: 8),
                    Text('主轴转速: ${_spindleSpeedOverride.toInt()}%'),
                    Expanded(
                      child: Slider(
                        value: _spindleSpeedOverride,
                        min: 50,
                        max: 120,
                        divisions: 7,
                        label: '${_spindleSpeedOverride.toInt()}%',
                        onChanged: (val) {
                          setState(() => _spindleSpeedOverride = val);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 底部安全控制按钮组
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.pause),
                label: const Text('暂停加工'),
                onPressed: () {},
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
                label: const Text('紧急停止 (E-Stop)'),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}
