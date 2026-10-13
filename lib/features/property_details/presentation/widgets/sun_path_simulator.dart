import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';

/// SunPathSimulator simulates real-time solar illumination, shadow angles,
/// and golden hour tints from 06:00 to 18:00 with dynamic lighting overlays.
class SunPathSimulator extends StatefulWidget {
  final String propertyImageUrl;
  final String orientation;

  const SunPathSimulator({
    super.key,
    required this.propertyImageUrl,
    this.orientation = 'South-West Facing',
  });

  @override
  State<SunPathSimulator> createState() => _SunPathSimulatorState();
}

class _SunPathSimulatorState extends State<SunPathSimulator> {
  // Time in 24-hour decimal format (e.g. 16.5 = 16:30 / 4:30 PM)
  double _timeHour = 16.5;

  String _formatTime(double hour, bool isArabic) {
    final int h = hour.floor();
    final int m = ((hour - h) * 60).round();
    final period = isArabic
        ? (h >= 12 ? 'م' : 'ص')
        : (h >= 12 ? 'PM' : 'AM');
    final displayHour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    final displayMin = m < 10 ? '0$m' : '$m';
    return isArabic
        ? '$displayHour:$displayMin $period'
        : '$displayHour:$displayMin $period';
  }

  String _getTimePhase(double hour, AppLocalizations l10n) {
    if (hour < 8.0) return l10n.translate('early_dawn');
    if (hour < 11.0) return l10n.translate('morning_ambient');
    if (hour < 14.0) return l10n.translate('midday_zenith');
    if (hour < 16.5) return l10n.translate('afternoon_light');
    if (hour < 17.5) return l10n.translate('golden_hour');
    return l10n.translate('sunset_twilight');
  }

  Color _getSunOverlayColor(double hour) {
    if (hour <= 8.5) {
      // Warm amber / peach tint (#FFA726)
      final t = ((hour - 6.0) / 2.5).clamp(0.0, 1.0);
      return Color.lerp(
        const Color(0x66FFA726),
        const Color(0x33FFB74D),
        t,
      )!;
    } else if (hour <= 14.5) {
      // Crisp bright daylight (#FFFFFF)
      final t = ((hour - 8.5) / 6.0).clamp(0.0, 1.0);
      return Color.lerp(
        const Color(0x22FFE082),
        const Color(0x18FFFFFF),
        t,
      )!;
    } else if (hour <= 17.0) {
      // Warm golden glow
      final t = ((hour - 14.5) / 2.5).clamp(0.0, 1.0);
      return Color.lerp(
        const Color(0x28FFB300),
        const Color(0x55FF7043),
        t,
      )!;
    } else {
      // Deep orange / sunset hue (#FF5722)
      final t = ((hour - 17.0) / 1.0).clamp(0.0, 1.0);
      return Color.lerp(
        const Color(0x55FF7043),
        const Color(0x77FF5722),
        t,
      )!;
    }
  }

  double _getShadowFactor(double hour) {
    // Zenith at 12:00 has smallest shadows (0.3x), early/late has elongated shadows (2.5x)
    final diffFromNoon = (hour - 12.0).abs();
    return (0.3 + (diffFromNoon / 6.0) * 1.8).clamp(0.3, 2.5);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final overlayColor = _getSunOverlayColor(_timeHour);
    final timeStr = _formatTime(_timeHour, l10n.isArabic);
    final phaseStr = _getTimePhase(_timeHour, l10n);
    final shadowMult = _getShadowFactor(_timeHour);
    final progress = ((_timeHour - 6.0) / 12.0).clamp(0.0, 1.0);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(
            alpha: isDark ? 0.2 : 0.6,
          ),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Wrap to eliminate the 7.6 PIXELS overflow error
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wb_sunny_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.translate('sun_path_title'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.amberGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.amberGold.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  widget.orientation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.amberGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Celestial Trajectory Arc Preview & Simulation Container
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Underlying Architectural Photo
                  CachedNetworkImage(
                    imageUrl: widget.propertyImageUrl,
                    fit: BoxFit.cover,
                  ),

                  // Dynamic Lighting Filter Overlay
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      color: overlayColor,
                      backgroundBlendMode: BlendMode.hardLight,
                    ),
                  ),

                  // Contrast Vignette
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Custom Painter: Sun Trajectory Arc & Position Indicator
                  CustomPaint(
                    painter: _SunArcPainter(progress: progress),
                  ),

                  // Time & Lighting Badge
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timeStr,
                              style: AppTypography.priceTag.copyWith(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              phaseStr,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.amberGold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            '${l10n.translate('shadow_factor')} ${shadowMult.toStringAsFixed(1)}x',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Interactive Time Scrub Slider
          Row(
            children: [
              const Text(
                '06:00',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: theme.colorScheme.primary,
                    thumbColor: theme.colorScheme.primary,
                    overlayColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                    inactiveTrackColor: isDark
                        ? const Color(0xFF141C2B)
                        : const Color(0xFFEFECE6),
                    trackHeight: 5,
                  ),
                  child: Slider(
                    value: _timeHour,
                    min: 6.0,
                    max: 18.0,
                    divisions: 48, // 15-minute intervals
                    onChanged: (val) {
                      setState(() {
                        _timeHour = val;
                      });
                    },
                  ),
                ),
              ),
              Text(
                '18:00',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),

          // Quick Presets
          Row(
            children: [
              Expanded(
                child: _buildPresetButton(
                  label: l10n.translate('morning_preset'),
                  targetHour: 8.0,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildPresetButton(
                  label: l10n.translate('noon_preset'),
                  targetHour: 12.0,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildPresetButton(
                  label: l10n.translate('sunset_preset'),
                  targetHour: 17.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton({
    required String label,
    required double targetHour,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = (_timeHour - targetHour).abs() < 0.3;

    return GestureDetector(
      onTap: () {
        setState(() {
          _timeHour = targetHour;
        });
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : (isDark ? const Color(0xFF141C2B) : const Color(0xFFEFECE6)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(
                    alpha: isDark ? 0.2 : 0.6,
                  ),
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter rendering celestial sun path trajectory arc and glowing sun icon
class _SunArcPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  _SunArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final start = Offset(size.width * 0.1, size.height * 0.7);
    final control = Offset(size.width * 0.5, size.height * 0.1);
    final end = Offset(size.width * 0.9, size.height * 0.7);

    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    canvas.drawPath(path, arcPaint);

    // Calculate current sun position on quadratic Bezier curve:
    // B(t) = (1-t)^2 * P0 + 2(1-t)t * P1 + t^2 * P2
    final t = progress;
    final sunX = pow(1 - t, 2) * start.dx +
        2 * (1 - t) * t * control.dx +
        pow(t, 2) * end.dx;
    final sunY = pow(1 - t, 2) * start.dy +
        2 * (1 - t) * t * control.dy +
        pow(t, 2) * end.dy;

    // Draw glowing sun halo
    final haloPaint = Paint()
      ..color = AppColors.amberGold.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(sunX.toDouble(), sunY.toDouble()), 12, haloPaint);

    // Draw sun core
    final corePaint = Paint()
      ..color = const Color(0xFFFFE082)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sunX.toDouble(), sunY.toDouble()), 6, corePaint);
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
