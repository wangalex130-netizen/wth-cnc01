import 'package:flutter/material.dart';
import '../models/material_preset.dart';

class MaterialSelectorCard extends StatefulWidget {
  final ValueChanged<MaterialPreset>? onPresetSelected;

  const MaterialSelectorCard({Super.key, this.onPresetSelected});

  @override
  State<MaterialSelectorCard> createState() => _MaterialSelectorCardState();
}

class _MaterialSelectorCardState extends State<MaterialSelectorCard> {
  MaterialPreset _selectedPreset = MaterialPreset.defaultPresets.first;

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
                Text('雕刻材料预设', style: Theme.of(context).textTheme.titleMedium),
                Chip(
                  avatar: Icon(_selectedPreset.icon, size: 16),
                  label: Text(_selectedPreset.name, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 材料水平选择列表
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: MaterialPreset.defaultPresets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = MaterialPreset.defaultPresets[index];
                  final isSelected = item.id == _selectedPreset.id;

                  return ChoiceChip(
                    avatar: Icon(item.icon, size: 16),
                    label: Text(item.name.split(' / ').first),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedPreset = item);
                        widget.onPresetSelected?.call(item);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // 参数细节面板
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildParamItem('进给速率', '${_selectedPreset.defaultFeedRate} mm/min'),
                  _buildParamItem('主轴转速', '${_selectedPreset.defaultSpindleSpeed} RPM'),
                  _buildParamItem('最大切深', '${_selectedPreset.maxStepDown} mm'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParamItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
