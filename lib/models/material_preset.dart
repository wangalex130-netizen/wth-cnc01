import 'package:flutter/material.dart';

class MaterialPreset {
  final String id;
  final String name;
  final IconData icon;
  final int defaultFeedRate;     // 进给速率 mm/min
  final int defaultSpindleSpeed; // 主轴转速 RPM
  final double maxStepDown;      // 单次切深 mm
  final String description;

  const MaterialPreset({
    required this.id,
    required this.name,
    required this.icon,
    required this.defaultFeedRate,
    required this.defaultSpindleSpeed,
    required this.maxStepDown,
    required this.description,
  });

  /// 内置常用材料参数库
  static const List<MaterialPreset> defaultPresets = [
    MaterialPreset(
      id: 'wood',
      name: '木材 / 椴木 / 榉木',
      icon: Icons.forest,
      defaultFeedRate: 1200,
      defaultSpindleSpeed: 10000,
      maxStepDown: 2.0,
      description: '适合绝大多数软木与硬木雕刻，切削顺畅',
    ),
    MaterialPreset(
      id: 'acrylic',
      name: '亚克力 / 有机玻璃',
      icon: Icons.layers,
      defaultFeedRate: 800,
      defaultSpindleSpeed: 8000,
      maxStepDown: 1.0,
      description: '低转速中进给，防止高温烫熔排屑口',
    ),
    MaterialPreset(
      id: 'aluminum',
      name: '铝合金 / 黄铜',
      icon: Icons.hardware,
      defaultFeedRate: 300,
      defaultSpindleSpeed: 12000,
      maxStepDown: 0.2,
      description: '轻切削微量进给，建议配合切削液使用',
    ),
    MaterialPreset(
      id: 'pcb',
      name: 'PCB 覆铜板',
      icon: Icons.developer_board,
      defaultFeedRate: 500,
      defaultSpindleSpeed: 12000,
      maxStepDown: 0.1,
      description: '高精极浅雕刻，适用于电路板快速打样',
    ),
  ];
}
