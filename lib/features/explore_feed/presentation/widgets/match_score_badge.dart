import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';

/// MatchScoreBadge displays the Gen-Z AI Vibe Match score with a glowing
/// neon cyan glassmorphic container and subtle pulse animation.
class MatchScoreBadge extends StatelessWidget {
  final int score;
  final bool isLarge;
  final bool animate;

  const MatchScoreBadge({
    super.key,
    required this.score,
    this.isLarge = false,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon = Icon(
      Icons.auto_awesome,
      size: isLarge ? 16 : 13,
      color: AppColors.neonCyan,
    );

    if (animate) {
      icon = icon
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            duration: 1200.ms,
            begin: const Offset(0.85, 0.85),
            end: const Offset(1.15, 1.15),
          );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 14 : 10,
        vertical: isLarge ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.25),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            '$score% VIBE',
            style: isLarge
                ? AppTypography.badgeScore.copyWith(fontSize: 14)
                : AppTypography.badgeScore,
          ),
        ],
      ),
    );
  }
}
