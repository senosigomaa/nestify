import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';
import 'package:nestify/features/explore_feed/presentation/widgets/match_score_badge.dart';

/// VibeRadarSheet presents an acoustic and lifestyle neighborhood diagnostic
/// in a sleek glassmorphic bottom sheet.
class VibeRadarSheet extends StatelessWidget {
  final PropertyEntity property;

  const VibeRadarSheet({
    super.key,
    required this.property,
  });

  static Future<void> show(BuildContext context, PropertyEntity property) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VibeRadarSheet(property: property),
    );
  }

  String _getNoiseClassification(int db) {
    if (db <= 35) return 'Whispering Library Quiet (Acoustic Glass)';
    if (db <= 42) return 'Serene Residential Ambience';
    if (db <= 50) return 'Moderate Urban Activity';
    return 'Dynamic Vibrant City Pulse';
  }

  @override
  Widget build(BuildContext context) {
    final noiseLabel = _getNoiseClassification(property.noiseLevelDb);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom Sheet Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title & Match Badge Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.radar_rounded,
                              size: 18,
                              color: AppColors.neonCyan,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'NEIGHBORHOOD VIBE RADAR',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: AppColors.neonCyan,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          property.neighborhood,
                          style: AppTypography.headlineMedium.copyWith(
                            fontSize: 20,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  MatchScoreBadge(
                    score: property.vibeMatchPercentage,
                    isLarge: true,
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // 1. Ambient Acoustic Noise Meter
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDarkElevated,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.graphic_eq_rounded,
                              color: AppColors.neonCyan,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Ambient Acoustic Profiling',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${property.noiseLevelDb} dB',
                          style: AppTypography.priceTag.copyWith(
                            fontSize: 18,
                            color: AppColors.neonCyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Visual Decibel Equalizer Bars
                    Row(
                      children: List.generate(24, (i) {
                        final threshold = (property.noiseLevelDb / 60.0) * 24;
                        final isActive = i < threshold;
                        final barHeight = 6.0 + (i % 5) * 4.0;

                        return Expanded(
                          child: Container(
                            height: barHeight,
                            margin: const EdgeInsets.symmetric(horizontal: 1.2),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? (i > 18
                                      ? AppColors.passRed
                                      : AppColors.neonCyan)
                                  : Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      noiseLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Specialty Coffee & Commute Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.coffee_rounded,
                      iconColor: AppColors.amberGold,
                      title: 'Specialty Coffee',
                      value: '${property.coffeeShopProximityMins}m walk',
                      subtitle: 'Third-wave roasters on block',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.directions_subway_rounded,
                      iconColor: AppColors.neonCyan,
                      title: 'Tech Hub Commute',
                      value: '${property.commuteTechHubMins} mins',
                      subtitle: 'Express metro & bike route',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3. Pet Friendliness & Fiber Internet
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.pets_rounded,
                      iconColor: const Color(0xFF69F0AE),
                      title: 'Pet Friendliness',
                      value: property.petFriendly ? '96% Index' : 'Restricted',
                      subtitle: property.petFriendly
                          ? 'Dog park within 250m'
                          : 'Quiet zone regulations',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.wifi_tethering_rounded,
                      iconColor: AppColors.cyanVariant,
                      title: 'Digital Pipeline',
                      value: '10 Gbps',
                      subtitle: 'Ultra-low latency fiber',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 4. Urban Lifestyle Radar Bars
              _buildProgressBar(
                label: 'Walkability & Transit Score',
                value: property.walkScore,
                color: AppColors.neonCyan,
              ),
              const SizedBox(height: 10),
              _buildProgressBar(
                label: 'Green Canopy & Parks',
                value: property.greenScore,
                color: const Color(0xFF00E676),
              ),
              const SizedBox(height: 10),
              _buildProgressBar(
                label: 'Boutique Dining & Nightlife',
                value: property.nightlifeScore,
                color: AppColors.amberGold,
              ),
              const SizedBox(height: 24),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.surfaceDarkElevated,
                        content: Text(
                          'Neighborhood Vibe Tour guide downloaded to your calendar!',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.explore_rounded, size: 18),
                  label: const Text('Schedule Neighborhood Vibe Walk'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$value / 100',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (value / 100.0).clamp(0.0, 1.0),
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}
