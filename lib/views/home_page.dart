import 'package:flutter/material.dart';
import '../services/cnc_service.dart';
import '../services/cnc_provider.dart';
import '../models/cnc_alarm.dart';
import '../widgets/device_connection_modal.dart';
import '../widgets/terminal_drawer.dart';
import 'control/jog_control_page.dart';
import 'wizard/setup_wizard_page.dart';
import 'monitor/machining_monitor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    JogControlPage(),
    SetupWizardPage(),
    MachiningMonitorPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final cnc = CncProvider.of(context);
    final isConnected = cnc.state != CncMachineState.disconnected;
    final isAlarm = cnc.state == CncMachineState.alarm;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart CNC Pro'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ActionChip(
              avatar: Icon(
                isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                size: 16,
                color: isConnected ? Colors.greenAccent : Colors.redAccent,
              ),
              label: Text(
                isConnected ? '已连接' : '未连接',
                style: TextStyle(
                  fontSize: 12,
                  color: isConnected ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
              onPressed: () => DeviceConnectionModal.show(context),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. 全局 ALARM 报警提示横幅
              if (isAlarm)
                Container(
                  color: Colors.red[900],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '警告：设备处于锁死状态 (ALARM)',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                        onPressed: () => _showAlarmDialog(context, 1), // 默认示范代码 1
                        child: const Text('排查与解锁'),
                      ),
                    ],
                  ),
                ),

              // 2. 主页面视图
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _pages,
                ),
              ),
            ],
          ),

          // 3. 底部悬浮收纳的终端日志控制台
          const Align(
            alignment: Alignment.bottomCenter,
            child: TerminalDrawer(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.tune_rounded),
            label: '手动控制',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_circle_outlined),
            selectedIcon: Icon(Icons.build_circle),
            label: '加工准备',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle_fill),
            label: '实时加工',
          ),
        ],
      ),
    );
  }

  void _showAlarmDialog(BuildContext context, int alarmCode) {
    final alarm = CncAlarm.alarmMap[alarmCode] ?? CncAlarm.getUnknown(alarmCode);
    final cnc = CncProvider.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.report_problem, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text(alarm.title, style: const TextStyle(fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('原因分析：', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Text(alarm.description, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 12),
              const Text('解决建议：', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Text(alarm.solution, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                cnc.resumeProcessing(); // 执行解锁 ($X) 并重置为 Idle
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已下发指令 [\$X]，设备成功解锁！')),
                );
              },
              child: const Text('一键解锁 ($X)'),
            ),
          ],
        );
      },
    );
  }
}
