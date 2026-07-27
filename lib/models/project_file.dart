import 'package:flutter/material.dart';

class ProjectFile {
  final String id;
  final String title;
  final String fileName;
  final String gcodeContent;
  final String estimatedTime;
  final String recommendedMaterial;
  final IconData icon;

  const ProjectFile({
    required this.id,
    required this.title,
    required this.fileName,
    required this.gcodeContent,
    required this.estimatedTime,
    required this.recommendedMaterial,
    required this.icon,
  });

  /// 官方内置示例工程库
  static const List<ProjectFile> sampleProjects = [
    ProjectFile(
      id: 'p1',
      title: '多边形防护盖板',
      fileName: 'Polygon_Cover.gcode',
      gcodeContent: '''
G0 X0 Y0 Z5
G1 Z-1 F300
G1 X60 Y0 F800
G1 X60 Y40
G1 X30 Y60
G1 X0 Y40
G1 X0 Y0
G0 Z5
''',
      estimatedTime: '03分15秒',
      recommendedMaterial: '木材 / 椴木板',
      icon: Icons.hexagon_outlined,
    ),
    ProjectFile(
      id: 'p2',
      title: '50mm 校准测试方块',
      fileName: 'Calibration_Square.gcode',
      gcodeContent: '''
G0 X0 Y0 Z5
G1 Z-0.5 F300
G1 X50 Y0 F1000
G1 X50 Y50
G1 X0 Y50
G1 X0 Y0
G0 Z5
''',
      estimatedTime: '01分20秒',
      recommendedMaterial: '亚克力 / 有机玻璃',
      icon: Icons.crop_square_rounded,
    ),
    ProjectFile(
      id: 'p3',
      title: '星形装饰镂空件',
      fileName: 'Star_Cutout.gcode',
      gcodeContent: '''
G0 X30 Y0 Z5
G1 Z-1 F250
G1 X38 Y20 F600
G1 X60 Y20
G1 X42 Y32
G1 X48 Y54
G1 X30 Y40
G1 X12 Y54
G1 X18 Y32
G1 X0 Y20
G1 X22 Y20
G1 X30 Y0
G0 Z5
''',
      estimatedTime: '05分10秒',
      recommendedMaterial: '铝合金薄板',
      icon: Icons.star_border_rounded,
    ),
  ];
}
