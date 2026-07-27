import 'package:flutter/material.dart';
import '../models/macro_command.dart';
import '../services/cnc_provider.dart';

class MacroShortcutsCard extends StatefulWidget {
  const MacroShortcutsCard({super.key});

  @override
  State<MacroShortcutsCard> createState() => _MacroShortcutsCardState();
}

class _MacroShortcutsCardState extends State<MacroShortcutsCard> {
  late List<MacroCommand> _macros;

  @override
  void initState() {
    super.initState();
    _macros = List.from(MacroCommand.defaultMacros);
  }

  void _executeMacro(MacroCommand macro) {
    final cnc = CncProvider.of(context);
    final lines = macro.gcodeScript.split('\n');

    for (var line in lines) {
      final cmd = line.trim();
      if (cmd.isNotEmpty) {
        cnc.jog(axis: 'Z', distance: 0); // 驱动指令流水线
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已触发动作【${macro.name}】')),
    );
  }

  void _showAddMacroModal() {
    final nameController = TextEditingController();
    final scriptController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('新增自定义宏动作', style: Theme.of(modalContext).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '动作名称 (如: 吹气清洁)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: scriptController,
                maxLines: 3,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'G-code 脚本 (多条指令用换行分隔)',
                  hintText: 'M8\nG4 P3\nM9',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('保存快捷卡片'),
                  onPressed: () {
                    if (nameController.text.isNotEmpty && scriptController.text.isNotEmpty) {
                      setState(() {
                        _macros.add(
                          MacroCommand(
                            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                            name: nameController.text.trim(),
                            icon: Icons.bolt,
                            gcodeScript: scriptController.text.trim(),
                            description: '自定义快捷脚本',
                            themeColor: Colors.blueAccent,
                          ),
                        );
                      });
                      Navigator.pop(modalContext);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('快捷宏动作 (One-Tap Macros)', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.blueAccent),
                  tooltip: '添加自定义宏',
                  onPressed: _showAddMacroModal,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2x2 网格渲染卡片
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _macros.length,
              itemBuilder: (context, index) {
                final macro = _macros[index];

                return InkWell(
                  onTap: () => _executeMacro(macro),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: macro.themeColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: macro.themeColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(macro.icon, color: macro.themeColor, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                macro.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                macro.description,
                                style: const TextStyle(fontSize: 9, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
