import 'package:flutter/material.dart';
import '../models/gcode_model.dart';

class GcodePreviewCanvas extends StatelessWidget {
  final GcodePath? pathData;

  const GcodePreviewCanvas({Super.key, this.pathData});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: pathData == null || pathData!.points.isEmpty
          ? const Center(
              child: Text(
                '暂未加载 G-code 文件',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: _PathPainter(pathData!),
              ),
            ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final GcodePath path;

  _PathPainter(this.path);

  @override
  void paint(Canvas canvas, Size size) {
    if (path.width <= 0 || path.height <= 0) return;

    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // 计算自动等比例缩放与居中偏移
    final padding = 20.0;
    final scaleX = (size.width - padding * 2) / path.width;
    final scaleY = (size.height - padding * 2) / path.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final pathObj = Path();
    for (int i = 0; i < path.points.length; i++) {
      final pt = path.points[i];
      // 翻转 Y 轴（Flutter 屏幕坐标系 Y 轴向下，而 CNC 笛卡尔坐标系 Y 轴向上）
      final dx = padding + (pt.dx - path.minX) * scale;
      final dy = size.height - (padding + (pt.dy - path.minY) * scale);

      if (i == 0) {
        pathObj.moveTo(dx, dy);
      } else {
        pathObj.lineTo(dx, dy);
      }
    }

    canvas.drawPath(pathObj, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
