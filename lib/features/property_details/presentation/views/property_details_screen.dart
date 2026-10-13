import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_bloc.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_event.dart';
import 'package:nestify/features/explore_feed/presentation/widgets/match_score_badge.dart';
import 'package:nestify/features/co_living/presentation/widgets/smart_split_calculator.dart';
import 'package:nestify/features/vibe_radar/presentation/widgets/vibe_radar_sheet.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/features/marketplace/presentation/widgets/direct_connect_buttons.dart';
import '../widgets/sun_path_simulator.dart';
import '../widgets/virtual_style_switcher.dart';
import '../widgets/investment_roi_calculator.dart';
import '../widgets/interactive_booking_sheet.dart';

/// PropertyDetailsScreen provides the full interactive luxury experience
/// including the Sun-Path Simulator, Virtual Style Switcher, and Smart Split Calculator.
class PropertyDetailsScreen extends StatefulWidget {
  final PropertyEntity property;

  const PropertyDetailsScreen({
    super.key,
    required this.property,
  });

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  int _heroPhotoIndex = 0;
  final PageController _pageController = PageController();

  void _showBookingDialog(BuildContext context) {
    InteractiveBookingSheet.show(context, widget.property);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final property = widget.property;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main Scrollable Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Image Gallery App Bar
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 380,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Photo PageView
                      PageView.builder(
                        controller: _pageController,
                        itemCount: property.images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _heroPhotoIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: property.images[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: theme.cardColor,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Gradient Overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.6),
                                Colors.transparent,
                                theme.scaffoldBackgroundColor,
                              ],
                              stops: const [0.0, 0.45, 1.0],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),

                      // Floating Navigation Icons (Back + Bookmark)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFloatingIconButton(
                              icon: Icons.arrow_back_ios_new_rounded,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            Row(
                              children: [
                                MatchScoreBadge(
                                  score: property.vibeMatchPercentage,
                                  isLarge: true,
                                ),
                                const SizedBox(width: 8),
                                _buildFloatingIconButton(
                                  icon: Icons.favorite_rounded,
                                  color: theme.colorScheme.primary,
                                  onTap: () {
                                    context
                                        .read<ExploreFeedBloc>()
                                        .add(SwipeRightEvent(property));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: theme.cardColor,
                                        content: Text(
                                          'Saved to your Nestify portfolio!',
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Gallery Dots Indicator
                      if (property.images.length > 1)
                        Positioned(
                          bottom: 24,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              property.images.length,
                              (i) => Container(
                                width: i == _heroPhotoIndex ? 20 : 6,
                                height: 6,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  color: i == _heroPhotoIndex
                                      ? theme.colorScheme.primary
                                      : Colors.white.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Property Header & Info Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price & Per Sq Ft
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            l10n.isArabic
                                ? property.localizedPrice(true)
                                : property.formattedPrice,
                            style: AppTypography.priceTag.copyWith(
                              fontSize: 34,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            l10n.isArabic
                                ? '${AppLocalizations.formatPrice(property.pricePerSqm, isArabic: true)} / م²'
                                : '${AppLocalizations.formatPrice(property.pricePerSqFt, isArabic: false)} / sq ft',
                            style: AppTypography.bodyMedium.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Title & Verified
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              property.title,
                              style: AppTypography.headlineLarge.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (property.isVerified)
                            Icon(
                              Icons.verified_rounded,
                              color: theme.colorScheme.primary,
                              size: 22,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property.neighborhood,
                              style: AppTypography.bodyMedium.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Specification Cards Carousel
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildSpecChip(
                              Icons.king_bed_outlined,
                              '${property.bedrooms} ${l10n.translate('beds')}',
                            ),
                            const SizedBox(width: 8),
                            _buildSpecChip(
                              Icons.shower_outlined,
                              '${property.bathrooms} ${l10n.translate('baths')}',
                            ),
                            const SizedBox(width: 8),
                            _buildSpecChip(
                              Icons.square_foot_rounded,
                              l10n.isArabic
                                  ? '${property.areaSqm} ${l10n.translate('sqm')}'
                                  : '${property.squareFeet} ${l10n.translate('sqft')}',
                            ),
                            const SizedBox(width: 8),
                            _buildSpecChip(
                              Icons.graphic_eq_rounded,
                              '${property.noiseLevelDb} ${l10n.translate('noise')}',
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            _buildSpecChip(
                              Icons.wb_sunny_outlined,
                              property.sunOrientation,
                              color: theme.colorScheme.secondary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Vibe Radar Teaser Card
                      GestureDetector(
                        onTap: () => VibeRadarSheet.show(context, property),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0x3300E5FF),
                                      const Color(0x1A141C2B),
                                    ]
                                  : [
                                      const Color(0xFFF7F5F0),
                                      Colors.white,
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.radar_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.translate('acoustic_diagnostic'),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${property.noiseLevelDb} dB • ${property.coffeeShopProximityMins} ${l10n.translate('mins_walk')} • ${property.commuteTechHubMins} ${l10n.isArabic ? "د لمراكز الأعمال" : "m to tech hub"}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Description
                      Text(
                        l10n.translate('acoustic_overview'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        property.description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Amenities Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: property.amenities.map((amenity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant.withValues(
                                  alpha: isDark ? 0.2 : 0.6,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 13,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  amenity,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),

                      // 1. Interactive Sun-Path Simulator
                      SunPathSimulator(
                        propertyImageUrl: property.images.first,
                        orientation: property.sunOrientation,
                      ),
                      const SizedBox(height: 28),

                      // 2. Generative Virtual Style Switcher
                      VirtualStyleSwitcher(
                        styleVariants: property.styleVariants,
                      ),
                      const SizedBox(height: 28),

                      // 3. Smart Split Calculator
                      SmartSplitCalculator(
                        propertyPrice: property.price,
                        isRent: property.priceType == 'rent',
                      ),
                      const SizedBox(height: 28),

                      // 4. Investment & Yield Analysis (ROI)
                      InvestmentRoiCalculator(
                        propertyPrice: property.price,
                      ),
                      const SizedBox(height: 140), // 140.h safe padding ensuring scrollable content clears floating bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Persistent Floating Action Bar with Quick Connect Actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                10,
                16,
                MediaQuery.of(context).padding.bottom + 10,
              ),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.96),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: isDark ? 0.2 : 0.6,
                    ),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(
                      alpha: isDark ? 0.4 : 0.08,
                    ),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Direct Lead Connect: WhatsApp Chat & Instant Call
                  DirectConnectButtons(property: property),
                  const SizedBox(height: 8),
                  // Primary Tour & Offer Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showBookingDialog(context),
                          child: Text(
                            context.tr('book_vip_tour'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: theme.cardColor,
                                content: Text(
                                  context.tr('offer_initialized'),
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            context.tr('coinvest_offer'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
    );
  }

  Widget _buildFloatingIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0B0E14).withValues(alpha: 0.75)
              : Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(
              alpha: isDark ? 0.2 : 0.6,
            ),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecChip(
    IconData icon,
    String label, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = color ?? theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (color ?? theme.colorScheme.outlineVariant).withValues(
            alpha: isDark ? 0.2 : 0.6,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: activeColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: activeColor,
            ),
          ),
        ],
      ),
    );
  }
}
