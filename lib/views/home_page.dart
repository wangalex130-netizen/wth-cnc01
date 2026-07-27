import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart CNC Pro'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ActionChip(
              avatar: const Icon(Icons.bluetooth_connected, size: 16, color: Colors.greenAccent),
              label: const Text('已连接 设备', style: TextStyle(fontSize: 12)),
              onPressed: () {
                // TODO: 触发设备连接切换弹窗
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
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
}
