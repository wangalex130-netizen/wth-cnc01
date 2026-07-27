import 'package:flutter/material.dart';
import '../models/job_history.dart';
import '../services/job_history_service.dart';

class JobAnalyticsModal extends StatefulWidget {
  const JobAnalyticsModal({Super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const JobAnalyticsModal(),
    );
  }

  @override
  State<JobAnalyticsModal> createState() => _JobAnalyticsModalState();
}

class _JobAnalyticsModalState extends State<JobAnalyticsModal> {
  final JobHistoryService _historyService = JobHistoryService();

  @override
  Widget build(BuildContext context) {
    final history = _historyService.history;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('切削履历与数据看板', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. 核心数据统计看板
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('累计切削', '${_historyService.totalMachiningHours.toStringAsFixed(2)} 小时'),
                _buildStatItem('完成任务', '${history.length} 次'),
                _buildStatItem('切削成功率', '${(_historyService.successRate * 100).toInt()}%'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. CSV 导出导出控制栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('历史加工明细', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                icon: const Icon(Icons.download, size: 18),
                label: const Text('导出 CSV 报表'),
                onPressed: () {
                  final csvData = _historyService.exportToCsv();
                  debugPrint(csvData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已成功导出切削履历 CSV 报表！')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 3. 历史记录列表
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final isSuccess = item.status == JobStatus.completed;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isSuccess ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                      child: Icon(
                        isSuccess ? Icons.check : Icons.close,
                        color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                    title: Text(item.fileName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${item.materialName} | ${item.formattedDate}\n用时: ${item.formattedDuration} (${item.totalLines}行)',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: Chip(
                      label: Text(
                        isSuccess ? '完成' : '已取消',
                        style: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                      backgroundColor: isSuccess ? Colors.green[800] : Colors.red[800],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
      ],
    );
  }
}
