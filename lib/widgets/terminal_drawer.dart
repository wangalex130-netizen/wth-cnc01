import 'package:flutter/material.dart';
import '../services/cnc_service.dart';
import '../services/cnc_provider.dart';

class TerminalDrawer extends StatefulWidget {
  const TerminalDrawer({super.key});

  @override
  State<TerminalDrawer> createState() => _TerminalDrawerState();
}

class _TerminalDrawerState extends State<TerminalDrawer> {
  bool _isExpanded = false;
  final TextEditingController _cmdController = TextEditingController();
  final List<String> _logs = [
    '[系统] Smart CNC Pro 串口初始化成功...',
    '[RX] Grbl 1.1h [\'\$\' for help]',
    '[TX] \$X (解锁成功)',
  ];

  void _sendCommand(CncService cnc) {
    final text = _cmdController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _logs.add('[TX] $text');
      _cmdController.clear();
    });

    // 简单模拟回应
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _logs.add('[RX] ok');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cnc = CncProvider.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: _isExpanded ? 280 : 42,
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: Colors.white12, width: 1)),
      ),
      child: Column(
        children: [
          // 顶部收起/展开控制条
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.terminal, size: 18, color: Colors.greenAccent),
                      const SizedBox(width: 8),
                      const Text(
                        '串口实时日志与控制台',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_logs.length} 行',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // 展开后的终端视图
          if (_isExpanded) ...[
            const Divider(height: 1, color: Colors.white12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black,
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    final isTx = log.startsWith('[TX]');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        log,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: isTx ? Colors.cyanAccent : Colors.greenAccent,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 命令行输入框
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: const Color(0xFF1E1E1E),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cmdController,
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      decoration: const InputDecoration(
                        hintText: '输入 G-code 指令 (如 \$G, \$#, G0 X0)...',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                        isDense: true,
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendCommand(cnc),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, size: 18, color: Colors.blueAccent),
                    onPressed: () => _sendCommand(cnc),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
