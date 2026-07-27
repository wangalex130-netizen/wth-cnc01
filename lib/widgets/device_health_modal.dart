import 'package:flutter/material.dart';
import '../models/device_health.dart';

class DeviceHealthModal extends StatefulWidget {
  const DeviceHealthModal({Super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const DeviceHealthModal(),
    );
  }

  @override
  State<DeviceHealthModal> createState() => _DeviceHealthModalState();
}

class _DeviceHealthModalState extends State<DeviceHealthModal> {
  final List<ConsumableItem> _items = DeviceStats.defaultConsumables;
  final DeviceStats _stats = DeviceStats.defaultStats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('设备健康度与保养诊断', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. 累计统计看板
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('累计加工时长', '${_stats.totalMachiningHours.toStringAsFixed(1)} 小时'),
                _buildStatItem('完成工程数', '${_stats.totalJobsCount} 个'),
                _buildStatItem('加工成功率', '${(_stats.successRate * 100).toInt()}%'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('耗材与零组件状态', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),

          // 2. 耗材列表
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final percent = item.healthPercentage;
                final isWarning = item.needsMaintenance;

                final Color healthColor = isWarning
                    ? Colors.redAccent
                    : (percent < 0.4 ? Colors.amber : Colors.greenAccent);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(item.icon, color: healthColor, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              '剩余 ${(percent * 100).toInt()}%',
                              style: TextStyle(
                                color: healthColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: percent,
                          color: healthColor,
                          backgroundColor: Colors.white10,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.advice,
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () {
                                setState(() {
                                  item.currentHours = 0.0; // 重置已用时间
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('已成功复位【${item.name}】保养计时！')),
                                );
                              },
                              child: const Text('标记已保养', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
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
