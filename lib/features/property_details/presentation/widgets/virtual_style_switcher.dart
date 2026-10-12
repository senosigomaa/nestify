import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nestify/core/constants/app_colors.dart';

/// VirtualStyleSwitcher enables interactive generative previewing of
/// different architectural interior aesthetics (Japandi, Cyberpunk, Scandinavian, Art Deco).
class VirtualStyleSwitcher extends StatefulWidget {
  final Map<String, String> styleVariants;

  const VirtualStyleSwitcher({
    super.key,
    required this.styleVariants,
  });

  @override
  State<VirtualStyleSwitcher> createState() => _VirtualStyleSwitcherState();
}

class _VirtualStyleSwitcherState extends State<VirtualStyleSwitcher> {
  late String _selectedStyle;

  final Map<String, Map<String, String>> _styleMeta = {
    'Minimalist Japandi': {
      'icon': '🌿',
      'palette': 'Travertine Stone • Smoked White Oak • Rice Paper',
      'lighting': '2700K Warm Organic Glow',
      'accent': '#E0D6C3',
    },
    'Cyberpunk Loft': {
      'icon': '⚡',
      'palette': 'Carbon Fiber • Gunmetal Steel • Diffused Neon',
      'lighting': 'Adjustable RGB Ambient Backlight',
      'accent': '#00E5FF',
    },
    'Warm Scandinavian': {
      'icon': '🪵',
      'palette': 'Nordic Birch • Chunky Bouclé • Muted Sage',
      'lighting': '3000K Soft Diffused Daylight',
      'accent': '#E2E8F0',
    },
    'Modern Art Deco': {
      'icon': '✨',
      'palette': 'Brushed Brass • Emerald Velvet • Fluted Glass',
      'lighting': 'Dimmable Warm Filament Spheres',
      'accent': '#FFB300',
    },
  };

  @override
  void initState() {
    super.initState();
    _selectedStyle = widget.styleVariants.keys.firstWhere(
      (k) => true,
      orElse: () => 'Minimalist Japandi',
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeImageUrl = widget.styleVariants[_selectedStyle] ?? '';
    final meta = _styleMeta[_selectedStyle] ??
        {
          'icon': '🎨',
          'palette': 'Curated Architectural Materials',
          'lighting': 'Natural Ambient Illuminance',
          'accent': '#00E5FF',
        };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.neonCyan,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Virtual Style Switcher',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                'AI RENDERING',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neonCyan,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Style Selection Chips Carousel
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: widget.styleVariants.keys.map((styleName) {
                final isSelected = styleName == _selectedStyle;
                final icon = _styleMeta[styleName]?['icon'] ?? '✨';

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(icon),
                        const SizedBox(width: 6),
                        Text(styleName),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedStyle = styleName;
                        });
                      }
                    },
                    selectedColor: AppColors.neonCyan.withValues(alpha: 0.18),
                    backgroundColor: AppColors.surfaceDarkElevated,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.neonCyan
                          : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.neonCyan
                          : Colors.white.withValues(alpha: 0.08),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Animated Cross-fade Preview Screen
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.backgroundDark,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: CachedNetworkImage(
                      key: ValueKey<String>(_selectedStyle),
                      imageUrl: activeImageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),

                  // Bottom Gradient Scrim
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            meta['palette'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.light_mode_outlined,
                                size: 12,
                                color: AppColors.amberGold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                meta['lighting'] ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
