import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_bloc.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_event.dart';
import 'package:nestify/features/explore_feed/presentation/widgets/match_score_badge.dart';
import 'package:nestify/features/co_living/presentation/widgets/smart_split_calculator.dart';
import 'package:nestify/features/vibe_radar/presentation/widgets/vibe_radar_sheet.dart';
import '../widgets/sun_path_simulator.dart';
import '../widgets/virtual_style_switcher.dart';

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
    DateTime selectedDate = DateTime.now().add(const Duration(days: 2));

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Book Private Architecture Tour',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Exclusive 1-on-1 walkthrough of ${widget.property.title} with licensed spatial advisor.',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDarkElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderCyan),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: AppColors.neonCyan,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 60)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: AppColors.neonCyan,
                                      surface: AppColors.surfaceDark,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: const Text(
                            'CHANGE',
                            style: TextStyle(
                              color: AppColors.neonCyan,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(modalContext).pop();
                        context.read<ExploreFeedBloc>().add(
                              BookTourRequestedEvent(
                                property: widget.property,
                                tourDate: selectedDate,
                              ),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.surfaceDarkElevated,
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.neonCyan,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Tour reserved for ${selectedDate.month}/${selectedDate.day}. VIP confirmation sent to your wallet.',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: const Text('Confirm VIP Tour Slot'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
                              color: AppColors.surfaceDark,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.neonCyan,
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
                                AppColors.backgroundDark,
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
                                  color: AppColors.neonCyan,
                                  onTap: () {
                                    context
                                        .read<ExploreFeedBloc>()
                                        .add(SwipeRightEvent(property));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor:
                                            AppColors.surfaceDarkElevated,
                                        content: Text(
                                          'Saved to your Nestify portfolio!',
                                          style: TextStyle(
                                            color: AppColors.neonCyan,
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
                                      ? AppColors.neonCyan
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
                            property.formattedPrice,
                            style: AppTypography.priceTag.copyWith(
                              fontSize: 34,
                            ),
                          ),
                          Text(
                            '\$${property.pricePerSqFt.toInt()} / sq ft',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
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
                              style: AppTypography.headlineLarge,
                            ),
                          ),
                          if (property.isVerified)
                            const Icon(
                              Icons.verified_rounded,
                              color: AppColors.neonCyan,
                              size: 22,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: AppColors.cyanVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property.neighborhood,
                              style: AppTypography.bodyMedium,
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
                              '${property.bedrooms} Bedrooms',
                            ),
                            const SizedBox(width: 8),
                            _buildSpecChip(
                              Icons.shower_outlined,
                              '${property.bathrooms} Bathrooms',
                            ),
                            const SizedBox(width: 8),
                            _buildSpecChip(
                              Icons.square_foot_rounded,
                              '${property.squareFeet} Sq Ft',
                            ),
                            const SizedBox(width: 8),
                            _buildSpecChip(
                              Icons.graphic_eq_rounded,
                              '${property.noiseLevelDb} dB Acoustic',
                              color: AppColors.neonCyan,
                            ),
                            const SizedBox(width: 8),
                            _buildSpecChip(
                              Icons.wb_sunny_outlined,
                              property.sunOrientation,
                              color: AppColors.amberGold,
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
                            gradient: const LinearGradient(
                              colors: [
                                Color(0x3300E5FF),
                                Color(0x1A141C2B),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.neonCyan.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.neonCyan
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.radar_rounded,
                                  color: AppColors.neonCyan,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Acoustic & Vibe Diagnostic',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${property.noiseLevelDb} dB noise • ${property.coffeeShopProximityMins}m coffee • ${property.commuteTechHubMins}m to tech hub',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: AppColors.neonCyan,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Description
                      const Text(
                        'Architectural Overview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        property.description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
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
                              color: AppColors.surfaceDarkElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 13,
                                  color: AppColors.neonCyan,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  amenity,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
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
                      const SizedBox(height: 110), // Padding for persistent bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Persistent Floating Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                MediaQuery.of(context).padding.bottom + 14,
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withValues(alpha: 0.95),
                border: const Border(
                  top: BorderSide(
                    color: AppColors.borderLight,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showBookingDialog(context),
                      child: const Text('Book VIP Tour'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.surfaceDarkElevated,
                            content: Text(
                              'Smart Co-Offer protocol initialized for ${property.title}!',
                              style: const TextStyle(
                                color: AppColors.neonCyan,
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text('Co-Invest / Offer'),
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

  Widget _buildFloatingIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.backgroundDark.withValues(alpha: 0.75),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: color ?? AppColors.textPrimary,
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
    final activeColor = color ?? AppColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (color ?? Colors.white).withValues(alpha: 0.12),
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
