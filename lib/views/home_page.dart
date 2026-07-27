import 'package:flutter/material.dart';
import '../services/cnc_service.dart';
import '../services/cnc_provider.dart';
import '../widgets/device_connection_modal.dart';
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
