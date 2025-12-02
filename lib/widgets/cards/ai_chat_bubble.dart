import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'glass_container.dart';

/// AI Chat bubble with glowing effect
class AIChatBubble extends StatelessWidget {
  final String message;
  final bool isAI;
  final DateTime timestamp;

  const AIChatBubble({
    super.key,
    required this.message,
    required this.isAI,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment:
              isAI ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              color: isAI
                  ? AppColors.accentCyan.withValues(alpha: 0.1)
                  : AppColors.primaryLight,
              border: isAI
                  ? Border.all(
                      color: AppColors.accentCyan.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
              boxShadow: isAI
                  ? AppColors.glowingShadow(
                      color: AppColors.accentCyan,
                      blur: 15,
                    )
                  : null,
              child: Text(
                message,
                style: AppTextStyles.bodyMedium,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _formatTime(timestamp),
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
