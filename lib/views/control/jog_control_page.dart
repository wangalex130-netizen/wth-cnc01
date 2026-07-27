import 'package:flutter/material.dart';
import '../../services/cnc_provider.dart';
import '../../widgets/macro_shortcuts_card.dart';

class JogControlPage extends StatefulWidget {
  const JogControlPage({Super.key});

  @override
  State<JogControlPage> createState() => _JogControlPageState();
}

class _JogControlPageState extends State<JogControlPage> {
  double _stepDistance = 1.0;

  @override
  Widget build(BuildContext context) {
    final cnc = CncProvider.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 1. 实时坐标卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAxisDisplay('X 轴', cnc.x.toStringAsFixed(3), Colors.redAccent),
                _buildAxisDisplay('Y 轴', cnc.y.toStringAsFixed(3), Colors.greenAccent),
                _buildAxisDisplay('Z 轴', cnc.z.toStringAsFixed(3), Colors.blueAccent),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 2. 快捷宏动作卡片 (NEW)
        const MacroShortcutsCard(),
        const SizedBox(height: 16),

        // 3. 步长选择器
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('移动步长 (mm)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment(value: 0.1, label: Text('0.1')),
                    ButtonSegment(value: 1.0, label: Text('1.0')),
                    ButtonSegment(value: 10.0, label: Text('10.0')),
                    ButtonSegment(value: 50.0, label: Text('50.0')),
                  ],
                  selected: {_stepDistance},
                  onSelectionChanged: (selection) {
                    setState(() => _stepDistance = selection.first);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 4. 三轴点动控制器
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      iconSize: 32,
                      icon: const Icon(Icons.keyboard_arrow_up),
                      onPressed: () => cnc.jog(axis: 'Y', distance: _stepDistance),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      iconSize: 32,
                      icon: const Icon(Icons.keyboard_arrow_left),
                      onPressed: () => cnc.jog(axis: 'X', distance: -_stepDistance),
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton(
                      onPressed: () => cnc.setZero(x: true, y: true, z: false),
                      child: const Text('XY 工件归零'),
                    ),
                    const SizedBox(width: 24),
                    IconButton.filledTonal(
                      iconSize: 32,
                      icon: const Icon(Icons.keyboard_arrow_right),
                      onPressed: () => cnc.jog(axis: 'X', distance: _stepDistance),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      iconSize: 32,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onPressed: () => cnc.jog(axis: 'Y', distance: -_stepDistance),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.arrow_upward),
                      label: const Text('Z 抬刀'),
                      onPressed: () => cnc.jog(axis: 'Z', distance: _stepDistance),
                    ),
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.arrow_downward),
                      label: const Text('Z 落刀'),
                      onPressed: () => cnc.jog(axis: 'Z', distance: -_stepDistance),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAxisDisplay(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }
}
