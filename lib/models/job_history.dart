import 'package:flutter/material.dart';

enum JobStatus { completed, canceled, error }

class JobHistoryItem {
  final String id;
  final String fileName;
  final String materialName;
  final DateTime timestamp;
  final int durationSeconds;
  final int totalLines;
  final JobStatus status;

  const JobHistoryItem({
    required this.id,
    required this.fileName,
    required this.materialName,
    required this.timestamp,
    required this.durationSeconds,
    required this.totalLines,
    required this.status,
  });

  /// 格式化加工时长 (MM:SS)
  String get formattedDuration {
    final minutes = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$minutes分$seconds秒';
  }

  /// 格式化日期 (YYYY-MM-DD HH:mm)
  String get formattedDate {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  /// 预置示范历史数据
  static List<JobHistoryItem> get sampleHistory => [
        JobHistoryItem(
          id: 'j1',
          fileName: 'Polygon_Cover.gcode',
          materialName: '木材 / 椴木板',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          durationSeconds: 195,
          totalLines: 120,
          status: JobStatus.completed,
        ),
        JobHistoryItem(
          id: 'j2',
          fileName: 'Relief_Imported.nc',
          materialName: '亚克力 / 有机玻璃',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          durationSeconds: 420,
          totalLines: 350,
          status: JobStatus.completed,
        ),
        JobHistoryItem(
          id: 'j3',
          fileName: 'Star_Cutout.gcode',
          materialName: '铝合金薄板',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          durationSeconds: 85,
          totalLines: 210,
          status: JobStatus.canceled,
        ),
      ];
}
