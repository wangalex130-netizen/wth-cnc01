import 'package:flutter/material.dart';

class JogControlPage extends StatefulWidget {
  const JogControlPage({Super.key});

  @override
  State<JogControlPage> createState() => _JogControlPageState();
}

class _JogControlPageState extends State<JogControlPage> {
  double _stepDistance = 1.0; // 默认步长 1mm

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 实时坐标显示区域
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAxisDisplay('X 轴', '0.000', Colors.redAccent),
                _buildAxisDisplay('Y 轴', '0.000', Colors.greenAccent),
                _buildAxisDisplay('Z 轴', '0.000', Colors.blueAccent),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 步长选择卡片
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
                  onSelectionChanged: (Set<double> selection) {
                    setState(() {
                      _stepDistance = selection.first;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 三轴点动操作区
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
                      onPressed: () {}, // Y+
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      iconSize: 32,
                      icon: const Icon(Icons.keyboard_arrow_left),
                      onPressed: () {}, // X-
                    ),
                    const SizedBox(width: 32),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('工件原点归零'),
                    ),
                    const SizedBox(width: 32),
                    IconButton.filledTonal(
                      iconSize: 32,
                      icon: const Icon(Icons.keyboard_arrow_right),
                      onPressed: () {}, // X+
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      iconSize: 32,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onPressed: () {}, // Y-
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.arrow_upward),
                      label: const Text('Z 轴上升'),
                      onPressed: () {},
                    ),
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.arrow_downward),
                      label: const Text('Z 轴下降'),
                      onPressed: () {},
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
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        ),
      ],
    );
  }
}
