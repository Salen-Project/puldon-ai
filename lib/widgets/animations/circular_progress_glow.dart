import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';

/// Circular progress indicator with glowing rings and confidence visualization
class CircularProgressGlow extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final Widget? center;

  const CircularProgressGlow({
    super.key,
    required this.progress,
    this.size = 200,
    this.strokeWidth = 12,
    this.color,
    this.backgroundColor,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? AppColors.accentCyan;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: AppColors.glowingShadow(
                color: progressColor,
                blur: 30,
                spread: 5,
              ),
            ),
          ),

          // Background circle
          CustomPaint(
            size: Size(size, size),
            painter: _CircleProgressPainter(
              progress: 1.0,
              strokeWidth: strokeWidth,
              color: backgroundColor ?? AppColors.primaryLight,
            ),
          ),

          // Progress arc
          CustomPaint(
            size: Size(size, size),
            painter: _CircleProgressPainter(
              progress: progress,
              strokeWidth: strokeWidth,
              color: progressColor,
            ),
          ),

          // Inner glow
          Container(
            width: size * 0.7,
            height: size * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: progressColor.withValues(alpha: 0.05),
            ),
          ),

          // Center content
          if (center != null) center!,
        ],
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _CircleProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
