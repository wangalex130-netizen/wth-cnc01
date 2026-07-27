import 'package:flutter/material.dart';

class SetupWizardPage extends StatelessWidget {
  const SetupWizardPage({Super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          '加工准备向导',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '请按照步骤完成加工前的校准工作',
          style: TextStyle(color: Colors.grey[400]),
        ),
        const SizedBox(height: 16),

        // 步骤 1：自动对刀
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.vertical_align_bottom, color: Colors.white),
            ),
            title: const Text('Z 轴自动对刀 (Auto Probe)'),
            subtitle: const Text('连接对刀块，自动精准测定雕刻刀尖 Z 轴零点'),
            trailing: OutlinedButton(
              onPressed: () {
                // TODO: 启动对刀向导弹窗
              },
              child: const Text('开始'),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 步骤 2：激光循边/寻角
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.purpleAccent,
              child: Icon(Icons.center_focus_strong, color: Colors.white),
            ),
            title: const Text('激光循边定位 (Laser Boundary)'),
            subtitle: const Text('开启红光辅助，快速预览并确认板材雕刻边界'),
            trailing: OutlinedButton(
              onPressed: () {
                // TODO: 启动循边模式
              },
              child: const Text('预览'),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 步骤 3：设定 XY 工件原点
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orangeAccent,
              child: Icon(Icons.my_location, color: Colors.white),
            ),
            title: const Text('设为工作原点 (Set Zero)'),
            subtitle: const Text('将当前刀具 X/Y 轴位置标记为 G54 加工起始点'),
            trailing: ElevatedButton(
              onPressed: () {
                // TODO: 执行 G10 L20 P1 X0 Y0
              },
              child: const Text('确认原点'),
            ),
          ),
        ),
      ],
    );
  }
}
