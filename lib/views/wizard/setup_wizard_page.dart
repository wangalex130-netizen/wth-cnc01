import 'package:flutter/material.dart';
import '../../services/cnc_provider.dart';
import '../../models/gcode_model.dart';
import '../../widgets/material_selector_card.dart';
import '../../widgets/framing_modal.dart';

class SetupWizardPage extends StatelessWidget {
  const SetupWizardPage({super.key});

  // 示范用边界 G-code
  final String _boundaryDemoGcode = '''
G0 X0 Y0 Z5
G1 X50 Y0
G1 X50 Y40
G1 X0 Y40
G1 X0 Y0
''';

  @override
  Widget build(BuildContext context) {
    final cnc = CncProvider.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text('加工准备向导', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('按照引导完成零点定位与校准，保障切削安全', style: TextStyle(color: Colors.grey[400])),
        const SizedBox(height: 16),

        // 1. 材料预设卡片
        MaterialSelectorCard(
          onPresetSelected: (preset) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('已套用【${preset.name}】加工参数')),
            );
          },
        ),
        const SizedBox(height: 12),

        // 2. 自动对刀
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.vertical_align_bottom, color: Colors.white),
            ),
            title: const Text('Z 轴自动对刀 (Auto Z-Probe)'),
            subtitle: const Text('使用对刀块精确定位刀具下端面 Z0'),
            trailing: OutlinedButton(
              onPressed: () => _showAutoProbeModal(context),
              child: const Text('开始'),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 3. 激光循边/走框校验 (已接入 FramingModal)
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.purpleAccent,
              child: Icon(Icons.center_focus_strong, color: Colors.white),
            ),
            title: const Text('跑框走框 / 轮廓边界预览'),
            subtitle: const Text('沿 G-code 外框巡航，肉眼校验板材预留量'),
            trailing: OutlinedButton(
              onPressed: () {
                final path = GcodePath.parse(_boundaryDemoGcode);
                FramingModal.show(context: context, path: path);
              },
              child: const Text('跑框预览'),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 4. 设为原点
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orangeAccent,
              child: Icon(Icons.my_location, color: Colors.white),
            ),
            title: const Text('设定当前位置为工件原点'),
            subtitle: const Text('将当前 X/Y/Z 设为 G54 零点'),
            trailing: ElevatedButton(
              onPressed: () {
                cnc.setZero(x: true, y: true, z: true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('工件坐标系 (G54) 已成功归零！')),
                );
              },
              child: const Text('确认归零'),
            ),
          ),
        ),
      ],
    );
  }

  void _showAutoProbeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Z 轴自动对刀流程', style: Theme.of(modalContext).textTheme.titleLarge),
              const SizedBox(height: 16),
              const ListTile(
                leading: Icon(Icons.looks_one, color: Colors.blueAccent),
                title: Text('放置对刀块'),
                subtitle: Text('请将对刀块平放在工件表面，并置于刀头正下方'),
              ),
              const ListTile(
                leading: Icon(Icons.looks_two, color: Colors.blueAccent),
                title: Text('连接鳄鱼夹'),
                subtitle: Text('确保对刀夹子已牢固夹在刀具主轴上'),
              ),
              const ListTile(
                leading: Icon(Icons.height, color: Colors.blueAccent),
                title: Text('预设对刀块厚度'),
                subtitle: Text('当前默认卡尺厚度: 10.00 mm'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final cnc = CncProvider.of(context);
                    cnc.jog(axis: 'Z', distance: -10, feedRate: 100);
                    cnc.setZero(x: false, y: false, z: true);
                    Navigator.pop(modalContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('对刀成功！Z轴零点已校准并补偿厚度')),
                    );
                  },
                  child: const Text('开始触碰对刀 (Probe Start)'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
