import 'package:flutter/material.dart';
import '../models/gcode_model.dart';
import '../services/cnc_provider.dart';
import '../services/framing_service.dart';

class FramingModal extends StatefulWidget {
  final GcodePath gcodePath;

  const FramingModal({super.key, required this.gcodePath}); // 修正为小写 super.key

  static void show({
    required BuildContext context,
    required GcodePath path,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FramingModal(gcodePath: path),
    );
  }

  @override
  State<FramingModal> createState() => _FramingModalState();
}

class _FramingModalState extends State<FramingModal> {
  double _safeZ = 5.0;
  double _speed = 1200.0;
  bool _useLaser = true;
  FramingService? _framingService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_framingService == null) {
      final cnc = CncProvider.of(context);
      _framingService = FramingService(cncService: cnc);
      _framingService!.addListener(_onServiceUpdate);
    }
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _framingService?.removeListener(_onServiceUpdate);
    _framingService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final framing = _framingService!;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('加工边界跑框校验', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '刀头将沿 G-code 外框运行一周，请观察板材边缘是否留有足够余量：',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem('X 轴跨度', '${widget.gcodePath.width.toStringAsFixed(1)} mm'),
                _buildInfoItem('Y 轴跨度', '${widget.gcodePath.height.toStringAsFixed(1)} mm'),
                _buildInfoItem('覆盖面积', '${(widget.gcodePath.width * widget.gcodePath.height / 100).toStringAsFixed(1)} cm²'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('开启弱光/红光定位辅助'),
            subtitle: const Text('光斑可清晰指示板材实际切削边界', style: TextStyle(fontSize: 11)),
            value: _useLaser,
            onChanged: framing.isFraming ? null : (val) => setState(() => _useLaser = val),
          ),
          Row(
            children: [
              const SizedBox(width: 16),
              Text('安全抬刀高度: ${_safeZ.toInt()} mm'),
              Expanded(
                child: Slider(
                  value: _safeZ,
                  min: 2,
                  max: 20,
                  divisions: 18,
                  onChanged: framing.isFraming ? null : (val) => setState(() => _safeZ = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (framing.isFraming) ...[
            LinearProgressIndicator(value: framing.progress, minHeight: 8),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.stop, color: Colors.redAccent),
                label: const Text('停止走框', style: TextStyle(color: Colors.redAccent)),
                onPressed: () => framing.stopFraming(),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.center_focus_strong),
                label: const Text('开始沿板材边缘走框 (Start Framing)'),
                onPressed: () {
                  framing.startFraming(
                    path: widget.gcodePath,
                    safeZHeight: _safeZ,
                    framingSpeed: _speed,
                    enableLaser: _useLaser,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
      ],
    );
  }
}
