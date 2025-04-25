import 'package:flutter/material.dart';

class QiblaArrow extends StatelessWidget {
  final Color color;

  const QiblaArrow({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(150, 150),
      painter: QiblaArrowPainter(color: color),
    );
  }
}

class QiblaArrowPainter extends CustomPainter {
  final Color color;

  QiblaArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Create a simple arrow path
    final path = Path();

    // Arrow head - simple triangle
    path.moveTo(center.dx, center.dy - radius + 10);
    path.lineTo(center.dx - 15, center.dy - radius + 40);
    path.lineTo(center.dx + 15, center.dy - radius + 40);
    path.close();

    // Arrow body - simple line
    final bodyPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx, center.dy - radius + 40),
      Offset(center.dx, center.dy + radius - 30),
      bodyPaint,
    );

    // Fill the arrow head
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Draw a circle in the center
    final circlePaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 12, circlePaint);

    // Draw outer circle
    final outerCirclePaint =
        Paint()
          ..color = color.withAlpha(100)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawCircle(center, 20, outerCirclePaint);

    // Add "Qibla" text below the arrow
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'القبلة',
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + radius - 20),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
