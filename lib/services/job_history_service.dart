import 'package:flutter/foundation.dart';
import '../models/job_history.dart';

class JobHistoryService extends ChangeNotifier {
  final List<JobHistoryItem> _history = List.from(JobHistoryItem.sampleHistory);

  List<JobHistoryItem> get history => _history;

  /// 累计加工总时长 (小时)
  double get totalMachiningHours {
    final totalSec = _history.fold<int>(0, (sum, item) => sum + item.durationSeconds);
    return totalSec / 3600.0;
  }

  /// 任务成功率 (0.0 ~ 1.0)
  double get successRate {
    if (_history.isEmpty) return 1.0;
    final successCount = _history.where((e) => e.status == JobStatus.completed).length;
    return successCount / _history.length;
  }

  /// 追加一条新完成记录
  void recordJob({
    required String fileName,
    required String materialName,
    required int durationSeconds,
    required int totalLines,
    required JobStatus status,
  }) {
    _history.insert(
      0,
      JobHistoryItem(
        id: 'job_${DateTime.now().millisecondsSinceEpoch}',
        fileName: fileName,
        materialName: materialName,
        timestamp: DateTime.now(),
        durationSeconds: durationSeconds,
        totalLines: totalLines,
        status: status,
      ),
    );
    notifyListeners();
  }

  /// 导出为 CSV 文本数据
  String exportToCsv() {
    final buffer = StringBuffer();
    buffer.writeln('ID,文件名,切削材料,加工时间,时长(秒),总行数,状态');
    for (var item in _history) {
      buffer.writeln('${item.id},${item.fileName},${item.materialName},${item.formattedDate},${item.durationSeconds},${item.totalLines},${item.status.name}');
    }
    return buffer.toString();
  }
}
