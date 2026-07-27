import 'package:flutter/material.dart';
import '../models/gcode_model.dart';

class GcodePreviewCanvas extends StatelessWidget {
  final GcodePath? pathData;
  final Offset? currentToolPosition; // 当前实时刀具坐标 (X, Y)

  const GcodePreviewCanvas({
    super.key,
    this.pathData,
    this.currentToolPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: pathData == null || pathData!.points.isEmpty
          ? const Center(
              child: Text(
                '暂未加载 G-code 路径',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: _PathPainter(
                  path: pathData!,
                  toolPos: currentToolPosition,
                ),
              ),
            ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final GcodePath path;
  final Offset? toolPos;

  _PathPainter({required this.path, this.toolPos});

  @override
  void paint(Canvas canvas, Size size) {
    if (path.width <= 0 || path.height <= 0) return;

    // 1. 绘制网格背景
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0;
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // 2. 计算缩放与居中参数
    const padding = 24.0;
    final scaleX = (size.width - padding * 2) / path.width;
    final scaleY = (size.height - padding * 2) / path.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // 3. 绘制 G-code 刀轨线
    final pathPaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.8)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final pathObj = Path();
    for (int i = 0; i < path.points.length; i++) {
      final pt = path.points[i];
      final dx = padding + (pt.dx - path.minX) * scale;
      final dy = size.height - (padding + (pt.dy - path.minY) * scale);

      if (i == 0) {
        pathObj.moveTo(dx, dy);
      } else {
        pathObj.lineTo(dx, dy);
      }
    }
    canvas.drawPath(pathObj, pathPaint);

    // 4. 实时绘制刀具位置 (红色动效高亮圈)
    if (toolPos != null) {
      final toolDx = padding + (toolPos!.dx - path.minX) * scale;
      final toolDy = size.height - (padding + (toolPos!.dy - path.minY) * scale);

      // 外扩散光圈
      final haloPaint = Paint()
        ..color = Colors.redAccent.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(toolDx, toolDy), 8.0, haloPaint);

      // 实体刀尖点
      final dotPaint = Paint()
        ..color = Colors.redAccent
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(toolDx, toolDy), 4.0, dotPaint);

      // 十字准星
      final crossPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(toolDx - 6, toolDy), Offset(toolDx + 6, toolDy), crossPaint);
      canvas.drawLine(Offset(toolDx, toolDy - 6), Offset(toolDx, toolDy + 6), crossPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return oldDelegate.toolPos != toolPos || oldDelegate.path != path;
  }
}
