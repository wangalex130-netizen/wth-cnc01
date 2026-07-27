import 'package:flutter/material.dart';
import 'cnc_service.dart';

class CncProvider extends InheritedNotifier<CncService> {
  const CncProvider({
    super.key, // 修正为小写 super.key
    required CncService cncService,
    required super.child,
  }) : super(notifier: cncService);

  static CncService of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<CncProvider>();
    assert(provider != null, 'No CncProvider found in context');
    return provider!.notifier!;
  }
}
