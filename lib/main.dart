import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'views/home_page.dart';

void main() {
  runApp(const SmartCncApp());
}

class SmartCncApp extends StatelessWidget {
  const SmartCncApp({Super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart CNC Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
