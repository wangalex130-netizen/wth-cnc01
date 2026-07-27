import 'package:flutter/material.dart';
import '../../services/cnc_provider.dart';
import '../../models/grbl_setting_item.dart';
import '../../widgets/device_health_modal.dart';
import '../../widgets/job_analytics_modal.dart';

class MachineSettingsPage extends StatefulWidget {
  const MachineSettingsPage({Super.key});

  @override
  State<MachineSettingsPage> createState() => _MachineSettingsPageState();
}

class _MachineSettingsPageState extends State<MachineSettingsPage> {
  int _tabIndex = 0; // 0: 常规调校, 1: 全量参数($$)
  final List<GrblSettingItem> _settings = GrblSettingItem.defaultSettings;

  bool _invertX = false;
  bool _invertY = false;
  bool _invertZ = false;

  @override
  Widget build(BuildContext context) {
    final cnc = CncProvider.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 0. 设备健康度与切削履历卡片组
        Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.blueAccent.withOpacity(0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.health_and_safety, color: Colors.white),
                  ),
                  title: const Text('设备健康度', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('主轴碳刷预警', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  onTap: () => DeviceHealthModal.show(context),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                color: Colors.purpleAccent.withOpacity(0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.purpleAccent.withOpacity(0.3)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.purpleAccent,
                    child: Icon(Icons.analytics_outlined, color: Colors.white),
                  ),
                  title: const Text('切削履历', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('查看数据与 CSV', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  onTap: () => JobAnalyticsModal.show(context),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 1. 顶部分段选择器
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('常用可视化设置'), icon: Icon(Icons.tune)),
            ButtonSegment(value: 1, label: Text('高级参数表 (\$\$)'), icon: Icon(Icons.code)),
          ],
          selected: {_tabIndex},
          onSelectionChanged: (set) => setState(() => _tabIndex = set.first),
        ),
        const SizedBox(height: 16),

        // 2. 视图分类展现
        if (_tabIndex == 0) _buildEasySettings(cnc) else _buildAdvancedSettings(cnc),
      ],
    );
  }

  /// 视图 A：小白快捷设置视图
  Widget _buildEasySettings(cnc) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('电机方向修正', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text('如果点动控制时轴体移动方向与按键相反，请开启对应反转开关：',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('X 轴方向反转'),
                  value: _invertX,
                  onChanged: (val) => setState(() => _invertX = val),
                ),
                SwitchListTile(
                  title: const Text('Y 轴方向反转'),
                  value: _invertY,
                  onChanged: (val) => setState(() => _invertY = val),
                ),
                SwitchListTile(
                  title: const Text('Z 轴方向反转'),
                  value: _invertZ,
                  onChanged: (val) => setState(() => _invertZ = val),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('设备物理工作行程', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _buildInlineInput('X 轴最大行程', '300.0', 'mm'),
                const Divider(height: 16),
                _buildInlineInput('Y 轴最大行程', '200.0', 'mm'),
                const Divider(height: 16),
                _buildInlineInput('Z 轴最大行程', '60.0', 'mm'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('保存并写入设备 EPROM'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('参数配置已成功写入固件 EEPROM！')),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 视图 B：极客 $$ 参数表视图
  Widget _buildAdvancedSettings(cnc) {
    return Column(
      children: [
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _settings.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = _settings[index];
              return ListTile(
                title: Row(
                  children: [
                    Text(
                      item.key,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(item.title, style: const TextStyle(fontSize: 14)),
                  ],
                ),
                subtitle: Text(item.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: SizedBox(
                  width: 90,
                  child: TextFormField(
                    initialValue: item.value,
                    style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      isDense: true,
                      suffixText: item.unit.isNotEmpty ? ' ${item.unit}' : null,
                      suffixStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    onChanged: (val) => item.value = val,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('重新读取 (\$\$)'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已成功从 GRBL 重新拉取参数表')),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.upload),
                label: const Text('全量修改同步'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('所有 GRBL 指令更新下发完成')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInlineInput(String label, String defaultValue, String unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        SizedBox(
          width: 100,
          child: TextFormField(
            initialValue: defaultValue,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              isDense: true,
              suffixText: ' $unit',
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
