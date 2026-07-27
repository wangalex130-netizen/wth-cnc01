class CncAlarm {
  final int code;
  final String title;
  final String description;
  final String solution;

  const CncAlarm({
    required this.code,
    required this.title,
    required this.description,
    required this.solution,
  });

  /// GRBL 1.1 官方标准报警映射字典
  static const Map<int, CncAlarm> alarmMap = {
    1: CncAlarm(
      code: 1,
      title: '硬限位被触发 (Hard Limit)',
      description: '雕刻机某一轴移动到了物理极限，触碰了限位开关。',
      solution: '请手动推开轴体离开开关，或点击【一键解锁 ($X)】后使用点动按钮反向退回安全区域。',
    ),
    2: CncAlarm(
      code: 2,
      title: '软限位超出范围 (Soft Limit)',
      description: '下发的 G-code 目标坐标超过了机器设定的最大行程行程。',
      solution: '请检查工件零点 (G54) 设定是否偏离了有效雕刻台面，或重新对刀。',
    ),
    3: CncAlarm(
      code: 3,
      title: '复位中断 (Reset While Motion)',
      description: '运动过程中接收到了复位指令，步骤可能存在丢步风险。',
      solution: '请重新进行“归零”校准后再继续加工。',
    ),
    4: CncAlarm(
      code: 4,
      title: '对刀/探测失败 (Probe Fail)',
      description: 'Z 轴自动对刀时，在最大行程内未能触碰到对刀块。',
      solution: '请检查对刀鳄鱼夹是否夹紧、电路是否断线，并将刀头离对刀块放近一些后再试。',
    ),
  };

  /// 默认未知报错回退
  static CncAlarm getUnknown(int code) {
    return CncAlarm(
      code: code,
      title: '系统未知报警 (ALARM:$code)',
      description: '设备返回了未定义的异常状态代码。',
      solution: '请点击【软复位】恢复设备并查看终端日志。',
    );
  }
}
