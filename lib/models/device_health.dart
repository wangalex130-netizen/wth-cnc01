import 'package:flutter/material.dart';

class ConsumableItem {
  final String id;
  final String name;
  final IconData icon;
  double currentHours; // 已运行小时数
  final double maxHours;    // 建议保养周期小时数
  final String advice;

  ConsumableItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.currentHours,
    required this.maxHours,
    required this.advice,
  });

  /// 剩余寿命百分比 (0.0 ~ 1.0)
  double get healthPercentage {
    final remain = (maxHours - currentHours) / maxHours;
    return remain.clamp(0.0, 1.0);
  }

  /// 是否需要立即保养
  bool get needsMaintenance => healthPercentage <= 0.15;
}

class DeviceStats {
  final double totalMachiningHours; // 累计加工时长
  final int totalJobsCount;         // 累计完成任务数
  final double successRate;         // 加工成功率

  const DeviceStats({
    required this.totalMachiningHours,
    required this.totalJobsCount,
    required this.successRate,
  });

  /// 预置初始运行统计
  static const DeviceStats defaultStats = DeviceStats(
    totalMachiningHours: 42.5,
    totalJobsCount: 28,
    successRate: 0.96,
  );

  /// 默认耗材监控列表
  static List<ConsumableItem> get defaultConsumables => [
        ConsumableItem(
          id: 'spindle_brush',
          name: '主轴电机碳刷/轴承',
          icon: Icons.rotate_right,
          currentHours: 180.0,
          maxHours: 200.0, // 剩 10%，触发保养提醒
          advice: '建议检查碳刷磨损程度，必要时更换新碳刷以免烧毁转子',
        ),
        ConsumableItem(
          id: 'rails_lubrication',
          name: 'XYZ 导轨与丝杆润滑',
          icon: Icons.water_drop_outlined,
          currentHours: 25.0,
          maxHours: 50.0, // 剩 50%
          advice: '请清除丝杆表面切削废屑，清理后均匀涂抹二硫化钼润滑脂',
        ),
        ConsumableItem(
          id: 'dust_filter',
          name: '防尘罩/吸尘滤芯',
          icon: Icons.air,
          currentHours: 12.0,
          maxHours: 30.0,
          advice: '请用压缩空气倒吹滤芯，防止切削粉尘堵塞散热通道',
        ),
        ConsumableItem(
          id: 'laser_diode',
          name: '定位红光/激光发光模组',
          icon: Icons.wb_sunny_outlined,
          currentHours: 120.0,
          maxHours: 1000.0,
          advice: '请使用无尘棉签微蘸无水乙醇轻轻擦拭透镜表面 Dust 聚焦镜',
        ),
      ];
}
