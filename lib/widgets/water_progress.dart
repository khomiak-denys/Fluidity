import 'dart:math';
import 'package:flutter/material.dart';

class WaterProgress extends StatelessWidget {
  final double current;
  final double goal;
  final String unit;

  const WaterProgress({
    super.key,
    required this.current,
    required this.goal,
    this.unit = 'ml',
  });

  @override
  Widget build(BuildContext context) {
  final double percentage = (current / goal).clamp(0.0, 1.0).toDouble();
  const radius = 75.0;

    return Center(
      child: SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- Background circle ---
            CustomPaint(
              size: const Size(200, 200),
              painter: _CirclePainter(
                percentage: percentage,
                radius: radius,
              ),
            ),
            // --- Center content ---
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                    Column(
                      children: [
                        Text(
                          '${current.toInt()} $unit',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.lightBlue[600],
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          'of ${goal.toInt()}$unit',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        Text(
                          '${(percentage * 100).round()}%',
                          style: TextStyle(
                            color: Colors.lightBlue[500],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 🌀 CustomPainter to draw background and progress ring
class _CirclePainter extends CustomPainter {
  final double percentage;
  final double radius;

  _CirclePainter({required this.percentage, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 12.0;
    final backgroundPaint = Paint()
      ..color = const Color(0xFFE0F7FF)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const gradient = SweepGradient(
      startAngle: -pi / 2,
      endAngle: 3 * pi / 2,
      colors: [
        Color(0xFF0EA5E9),
        Color(0xFF06B6D4),
        Color(0xFF10B981),
      ],
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw background circle
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc (animated)
    final sweepAngle = 2 * pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
