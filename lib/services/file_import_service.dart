import 'package:flutter/material.dart';
import '../models/project_file.dart';
import '../models/gcode_model.dart';

class FileImportService {
  /// 将读取到的本地 G-code 字符串解析为 ProjectFile
  static ProjectFile? parseRawGcode({
    required String fileName,
    required String content,
  }) {
    if (content.trim().isEmpty) return null;

    // 提取有效行数
    final lines = content
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && !e.startsWith(';'))
        .toList();

    if (lines.isEmpty) return null;

    // 粗略预估时间 (按平均 150 行/分钟估算)
    final totalMinutes = (lines.length / 150).ceil();
    final timeStr = totalMinutes < 1 ? '< 01分00秒' : '$totalMinutes分00秒';

    // 解析尺寸
    final path = GcodePath.parse(content);
    final dimensionStr = '尺寸: ${path.width.toStringAsFixed(1)}x${path.height.toStringAsFixed(1)}mm';

    return ProjectFile(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: fileName.contains('.') ? fileName.split('.').first : fileName,
      fileName: fileName,
      gcodeContent: content,
      estimatedTime: timeStr,
      recommendedMaterial: dimensionStr,
      icon: Icons.description_outlined,
    );
  }

  /// 预置示范：模拟导入自定义浮雕 G-code
  static ProjectFile getMockImportedFile() {
    const mockContent = '''
G0 X0 Y0 Z5
G1 Z-0.5 F400
G1 X20 Y0 F1000
G1 X40 Y20
G1 X20 Y40
G1 X0 Y20
G1 X0 Y0
G0 Z5
''';

    return parseRawGcode(
      fileName: 'Relief_Imported.nc',
      content: mockContent,
    )!;
  }
}
