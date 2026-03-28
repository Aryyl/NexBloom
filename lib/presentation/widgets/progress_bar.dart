import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularProgressBar extends StatelessWidget {
  final double percentage;
  final double size;
  final double strokeWidth;
  final bool showPercentage;

  const CircularProgressBar({
    super.key,
    required this.percentage,
    this.size = 80,
    this.strokeWidth = 8,
    this.showPercentage = true,
  });

  Color _getColor() {
    if (percentage >= 75) return const Color(0xFF10B981); // Green
    if (percentage >= 50) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background circle
          CustomPaint(
            size: Size(size, size),
            painter: _CirclePainter(
              progress: 1.0,
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: strokeWidth,
            ),
          ),
          // Progress circle
          CustomPaint(
            size: Size(size, size),
            painter: _CirclePainter(
              progress: percentage / 100,
              color: _getColor(),
              strokeWidth: strokeWidth,
            ),
          ),
          // Percentage text
          if (showPercentage)
            Center(
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.bold,
                  color: _getColor(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class LinearProgressBar extends StatelessWidget {
  final double percentage;
  final double height;
  final bool showPercentage;

  const LinearProgressBar({
    super.key,
    required this.percentage,
    this.height = 8,
    this.showPercentage = false,
  });

  Color _getColor() {
    if (percentage >= 75) return const Color(0xFF10B981);
    if (percentage >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
                FractionallySizedBox(
                  widthFactor: percentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getColor(),
                          _getColor().withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getColor(),
            ),
          ),
        ],
      ],
    );
  }
}
