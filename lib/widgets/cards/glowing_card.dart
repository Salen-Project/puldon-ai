import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

/// Card with animated glowing border effect
class GlowingCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool animate;

  const GlowingCard({
    super.key,
    required this.child,
    this.glowColor = AppColors.accentCyan,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.onTap,
    this.width,
    this.height,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: glowColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: AppColors.glowingShadow(color: glowColor),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primaryMid,
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );

    if (animate) {
      return card
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 2000.ms,
            color: glowColor.withValues(alpha: 0.1),
          );
    }

    return card;
  }
}
