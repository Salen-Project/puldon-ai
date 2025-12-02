import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    // Navigate to home after animation
    Future.delayed(const Duration(milliseconds: 3000), () {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            colors: [
              AppColors.accentCyan.withValues(alpha: 0.3),
              AppColors.primaryMid,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated particle logo
              SizedBox(
                width: 200,
                height: 200,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ParticleLogoPainter(
                        progress: _controller.value,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),

              // App Name
              Text(
                'Puldon',
                style: AppTextStyles.display1.copyWith(
                  shadows: [
                    Shadow(
                      color: AppColors.accentCyan.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                    Shadow(
                      color: AppColors.emerald.withValues(alpha: 0.3),
                      blurRadius: 40,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 12),

              // Tagline
              Text(
                'Your AI Financial Advisor',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 60),

              // Loading indicator
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.primaryLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.accentCyan,
                  ),
                  minHeight: 3,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1000.ms, color: AppColors.accentCyan.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParticleLogoPainter extends CustomPainter {
  final double progress;

  _ParticleLogoPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final particleCount = 60;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final distance = progress * (size.width / 2);
      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);

      final paint = Paint()
        ..color = i % 2 == 0
            ? AppColors.accentCyan.withValues(alpha: 1 - progress * 0.5)
            : AppColors.emerald.withValues(alpha: 1 - progress * 0.5)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        4 * (1 - progress) + 2,
        paint,
      );

      // Glow effect
      final glowPaint = Paint()
        ..color = paint.color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(
        Offset(x, y),
        8 * (1 - progress) + 4,
        glowPaint,
      );
    }

    // Central icon (dollar sign or graph)
    if (progress > 0.5) {
      final iconPaint = Paint()
        ..color = AppColors.accentCyan.withValues(alpha: (progress - 0.5) * 2)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;

      // Draw simple dollar sign
      final path = Path();
      path.moveTo(center.dx, center.dy - 30);
      path.lineTo(center.dx, center.dy + 30);

      path.moveTo(center.dx - 15, center.dy - 15);
      path.quadraticBezierTo(
        center.dx + 15,
        center.dy - 15,
        center.dx + 15,
        center.dy,
      );
      path.quadraticBezierTo(
        center.dx + 15,
        center.dy + 15,
        center.dx - 15,
        center.dy + 15,
      );

      canvas.drawPath(path, iconPaint);
    }
  }

  @override
  bool shouldRepaint(_ParticleLogoPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
