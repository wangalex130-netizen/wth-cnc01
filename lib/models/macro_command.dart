import 'package:flutter/material.dart';

class MacroCommand {
  final String id;
  final String name;
  final IconData icon;
  final String gcodeScript;
  final String description;
  final Color themeColor;

  const MacroCommand({
    required this.id,
    required this.name,
    required this.icon,
    required this.gcodeScript,
    required this.description,
    this.themeColor = Colors.blueAccent,
  });

  /// 内置高频快捷动作库
  static List<MacroCommand> get defaultMacros => [
        const MacroCommand(
          id: 'm1',
          name: '安全换刀位置',
          icon: Icons.unarchive_outlined,
          gcodeScript: 'G90 G0 Z50\nG0 X0 Y0',
          description: 'Z 轴抬高至 50mm 并移动到前端，方便螺丝刀拆装刀具',
          themeColor: Colors.blueAccent,
        ),
        const MacroCommand(
          id: 'm2',
          name: '退料/移开主轴',
          icon: Icons.open_in_browser,
          gcodeScript: 'G90 G0 Z30\nG0 Y200',
          description: 'Z 轴抬高并将 Y 轴推至最外侧，方便取下成品板材',
          themeColor: Colors.purpleAccent,
        ),
        const MacroCommand(
          id: 'm3',
          name: '主轴分段预热',
          icon: Icons.local_fire_department_outlined,
          gcodeScript: 'M3 S3000\nG4 P5\nM3 S6000\nG4 P5\nM5',
          description: '低速转动 5 秒后提升至中速，保护高速轴承油脂均匀',
          themeColor: Colors.orangeAccent,
        ),
        const MacroCommand(
          id: 'm4',
          name: '回机械原点 ($H)',
          icon: Icons.home_outlined,
          gcodeScript: '\$H',
          description: '触发 X/Y/Z 轴碰撞限位开关，寻得机器绝对机械原点',
          themeColor: Colors.tealAccent,
        ),
      ];
}
