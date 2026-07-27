import 'package:flutter/material.dart';
import 'services/cnc_service.dart';
import 'services/cnc_provider.dart';
import 'theme/app_theme.dart';
import 'views/home_page.dart';

void main() {
  runApp(const SmartCncApp());
}

class SmartCncApp extends StatefulWidget {
  const SmartCncApp({super.key});

  @override
  State<SmartCncApp> createState() => _SmartCncAppState();
}

class _SmartCncAppState extends State<SmartCncApp> {
  final CncService _cncService = CncService();

  @override
  void initState() {
    super.initState();
    // 启动时自动建立模拟通信管道
    _cncService.connect('COM_VIRTUAL');
  }

  @override
  void dispose() {
    _cncService.disconnect();
    _cncService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CncProvider(
      cncService: _cncService,
      child: MaterialApp(
        title: 'Smart CNC Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomePage(),
      ),
    );
  }
}
