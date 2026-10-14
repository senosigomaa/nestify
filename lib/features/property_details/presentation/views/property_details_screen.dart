import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_bloc.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_event.dart';
import 'package:nestify/features/explore_feed/presentation/widgets/match_score_badge.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/features/marketplace/presentation/widgets/direct_connect_buttons.dart';
import '../widgets/egyptian_payment_plan_slider.dart';
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
                              '${property.areaSqm} ${l10n.translate('sqm')}',
                            ),
                            const SizedBox(width: 8),
                            _buildSpecChip(
                              Icons.architecture_rounded,
                              property.localizedFinishing(l10n.isArabic),
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            _buildSpecChip(
                              Icons.event_available_rounded,
                              property.localizedDelivery(l10n.isArabic),
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            _buildSpecChip(
                              Icons.verified_user_outlined,
                              property.localizedOfferingType(l10n.isArabic),
                            ),
                            const SizedBox(width: 8),
                            _buildSpecChip(
                              Icons.shield_outlined,
                              '${l10n.translate('maintenance_fee')}: ${(property.maintenanceRatio * 100).toInt()}%',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Authentic Egyptian Payment & Pricing Overview Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF141C2B) : const Color(0xFFF7F5EE),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.translate('total_price'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    l10n.isArabic
                                        ? 'خصم ${property.cashDiscountPercent}% للكاش'
                                        : '${property.cashDiscountPercent}% Cash Off',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                property.localizedPrice(l10n.isArabic),
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.translate('down_payment'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          property.localizedDownPayment(l10n.isArabic),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(width: 1, height: 28, color: theme.dividerColor),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.translate('monthly_installment'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          property.localizedMonthlyInstallment(l10n.isArabic),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: theme.colorScheme.secondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(width: 1, height: 28, color: theme.dividerColor),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.translate('quarterly_installment'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          property.localizedQuarterlyInstallment(l10n.isArabic),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Description
                      Text(
                        l10n.isArabic ? 'تفاصيل الوحدة والمشروع' : 'Property & Project Details',
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

                      // 3. Realistic Egyptian Payment Plan Engine & Slider Simulator
                      EgyptianPaymentPlanSlider(
                        propertyPrice: property.price,
                        initialDownPaymentPct: (property.downPaymentPrice > 0
                            ? (property.downPaymentPrice / property.price * 100)
                            : 10.0),
                        initialYears: property.installmentYears,
                        maintenancePct: property.maintenanceRatio,
                        cashDiscountPct: property.cashDiscountPercent,
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
                            l10n.isArabic ? "طلب خطة سداد مخصصة" : "Request Custom Plan",
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
