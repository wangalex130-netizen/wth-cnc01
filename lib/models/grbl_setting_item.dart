class GrblSettingItem {
  final String key; // 如 "$30"
  final String title;
  final String description;
  final String unit;
  String value;
  final String category; // "电机与方向", "行程与限制", "主轴与激光"

  GrblSettingItem({
    required this.key,
    required this.title,
    required this.description,
    this.unit = '',
    required this.value,
    required this.category,
  });

  /// GRBL 1.1 常用参数预设列表
  static List<GrblSettingItem> get defaultSettings => [
        GrblSettingItem(
          key: '\$3',
          title: '电机方向反转掩码',
          description: '用于修正某一轴运动方向相反的问题',
          value: '0',
          category: '电机与方向',
        ),
        GrblSettingItem(
          key: '\$30',
          title: '主轴最高转速 (Max RPM)',
          description: 'PWM 占空比 100% 时对应的最高转速',
          unit: 'RPM',
          value: '10000',
          category: '主轴与激光',
        ),
        GrblSettingItem(
          key: '\$31',
          title: '主轴最低转速 (Min RPM)',
          description: '主轴开启时的最低转速',
          unit: 'RPM',
          value: '0',
          category: '主轴与激光',
        ),
        GrblSettingItem(
          key: '\$100',
          title: 'X 轴脉冲定位 (Steps/mm)',
          description: 'X 轴电机移动 1 毫米所需的脉冲步数',
          unit: 'step/mm',
          value: '800.000',
          category: '电机与方向',
        ),
        GrblSettingItem(
          key: '\$101',
          title: 'Y 轴脉冲定位 (Steps/mm)',
          description: 'Y 轴电机移动 1 毫米所需的脉冲步数',
          unit: 'step/mm',
          value: '800.000',
          category: '电机与方向',
        ),
        GrblSettingItem(
          key: '\$102',
          title: 'Z 轴脉冲定位 (Steps/mm)',
          description: 'Z 轴电机移动 1 毫米所需的脉冲步数',
          unit: 'step/mm',
          value: '800.000',
          category: '电机与方向',
        ),
        GrblSettingItem(
          key: '\$130',
          title: 'X 轴最大行程 (Max Travel)',
          description: 'X 轴物理可移动的最大行程距离',
          unit: 'mm',
          value: '300.000',
          category: '行程与限制',
        ),
        GrblSettingItem(
          key: '\$131',
          title: 'Y 轴最大行程 (Max Travel)',
          description: 'Y 轴物理可移动的最大行程距离',
          unit: 'mm',
          value: '200.000',
          category: '行程与限制',
        ),
        GrblSettingItem(
          key: '\$132',
          title: 'Z 轴最大行程 (Max Travel)',
          description: 'Z 轴物理可移动的最大行程距离',
          unit: 'mm',
          value: '60.000',
          category: '行程与限制',
        ),
      ];
}
