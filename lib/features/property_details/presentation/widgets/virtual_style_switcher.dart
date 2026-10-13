import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/localization/app_localizations.dart';

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

  String _getLocalizedStyleName(String styleName, AppLocalizations l10n) {
    if (!l10n.isArabic) return styleName;
    if (styleName.contains('Japandi')) return l10n.translate('style_japandi');
    if (styleName.contains('Cyberpunk')) return l10n.translate('style_cyberpunk');
    if (styleName.contains('Scandinavian')) return l10n.translate('style_scandinavian');
    if (styleName.contains('Art Deco')) return l10n.translate('style_art_deco');
    return styleName;
  }

  String _getLocalizedPalette(String styleName, bool isArabic) {
    if (!isArabic) return _styleMeta[styleName]?['palette'] ?? '';
    switch (styleName) {
      case 'Minimalist Japandi':
        return 'حجر الترافرتين • بلوط أبيض مدخن • ورق أرز ياباني';
      case 'Cyberpunk Loft':
        return 'ألياف الكربون • فولاذ صلب • إضاءة نيون هادئة';
      case 'Warm Scandinavian':
        return 'خشب البتولا النوردي • قماش بوكليه • أخضر ميرمية';
      case 'Modern Art Deco':
        return 'نحاس مصقول • مخمل زمردي فاخر • زجاج مضلع';
      default:
        return 'مواد معمارية مختارة بعناية';
    }
  }

  String _getLocalizedLighting(String styleName, bool isArabic) {
    if (!isArabic) return _styleMeta[styleName]?['lighting'] ?? '';
    switch (styleName) {
      case 'Minimalist Japandi':
        return 'إضاءة عضوية دافئة 2700 كلفن';
      case 'Cyberpunk Loft':
        return 'إضاءة خلفية محيطية RGB قابلة للتعديل';
      case 'Warm Scandinavian':
        return 'ضوء نهاري ناعم 3000 كلفن';
      case 'Modern Art Deco':
        return 'كرات إضاءة فتيلية دافئة قابلة للتعتيم';
      default:
        return 'إضاءة محيطية طبيعية';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeImageUrl = widget.styleVariants[_selectedStyle] ?? '';

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.translate('virtual_style_title'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.translate('ai_rendering'),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
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
                        Text(_getLocalizedStyleName(styleName, l10n)),
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
                    selectedColor:
                        theme.colorScheme.primary.withValues(alpha: 0.18),
                    backgroundColor: isDark
                        ? const Color(0xFF141C2B)
                        : const Color(0xFFEFECE6),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant.withValues(
                              alpha: isDark ? 0.2 : 0.6,
                            ),
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
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
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
                            _getLocalizedPalette(_selectedStyle, l10n.isArabic),
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
                                _getLocalizedLighting(_selectedStyle, l10n.isArabic),
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
