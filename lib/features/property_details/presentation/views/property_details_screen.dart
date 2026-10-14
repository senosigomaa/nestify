import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_bloc.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_event.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_state.dart';
import 'package:nestify/features/explore_feed/presentation/widgets/match_score_badge.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/features/marketplace/presentation/widgets/direct_connect_buttons.dart';
import '../widgets/egyptian_payment_plan_slider.dart';
import '../widgets/investment_roi_calculator.dart';
import '../widgets/interactive_booking_sheet.dart';

/// PropertyDetailsScreen enforces strict Egyptian real estate business logic:
/// segregates Rent vs. Cash Sale vs. Installment, removes gimmicks, and presents
/// room spaces in high-resolution photography.
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
  int _mediaTab = 0; // 0: Floor Plan (المخطط المعماري), 1: Photos (صور الوحدة)
  final PageController _pageController = PageController();

  void _showBookingDialog(BuildContext context) {
    InteractiveBookingSheet.show(context, widget.property);
  }

  void _showImageZoomDialog(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: InteractiveViewer(
                  clipBehavior: Clip.none,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
                                BlocBuilder<ExploreFeedBloc, ExploreFeedState>(
                                  builder: (context, feedState) {
                                    final isSaved = feedState.savedProperties
                                        .any((p) => p.id == property.id);
                                    return _buildFloatingIconButton(
                                      icon: isSaved
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: isSaved
                                          ? const Color(0xFFE11D48)
                                          : (isDark
                                              ? Colors.white
                                              : const Color(0xFF64748B)),
                                      onTap: () {
                                        context.read<ExploreFeedBloc>().add(
                                              ToggleSavePropertyEvent(property),
                                            );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: theme.cardColor,
                                            duration:
                                                const Duration(milliseconds: 900),
                                            content: Text(
                                              isSaved
                                                  ? (l10n.isArabic
                                                      ? 'تمت الإزالة من المفضلة'
                                                      : 'Removed from saved properties')
                                                  : (l10n.isArabic
                                                      ? 'تم الحفظ في عقاراتي المفضلة'
                                                      : 'Saved to favorites!'),
                                              style: TextStyle(
                                                color: theme.colorScheme.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
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
                      // Price & Per Sq Ft / Rent Note (Zero overflow on all screen sizes)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 6,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: l10n.isArabic
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Text(
                                property.localizedPrice(l10n.isArabic),
                                style: AppTypography.priceTag.copyWith(
                                  fontSize: 30,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 5,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: l10n.isArabic
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: !property.forRent
                                  ? Text(
                                      l10n.isArabic
                                          ? '${AppLocalizations.formatPrice(property.pricePerSqm, isArabic: true)} / م²'
                                          : '${AppLocalizations.formatPrice(property.pricePerSqFt, isArabic: false)} / sq ft',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    )
                                  : Text(
                                      l10n.isArabic
                                          ? 'إيجار شهري تعاقدي'
                                          : 'Contractual Monthly Rent',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
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
                            if (property.forRent) ...[
                              _buildSpecChip(
                                Icons.chair_outlined,
                                property.isFurnished
                                    ? (l10n.isArabic ? 'مفروش بالكامل' : 'Furnished')
                                    : (l10n.isArabic ? 'غير مفروش' : 'Unfurnished'),
                                color: const Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 8),
                              _buildSpecChip(
                                Icons.calendar_today_rounded,
                                '${l10n.isArabic ? "الحد الأدنى" : "Min"}: ${property.minLeaseYears} ${l10n.isArabic ? "سنة" : "Yr"}',
                              ),
                              const SizedBox(width: 8),
                              _buildSpecChip(
                                Icons.lock_outline_rounded,
                                '${l10n.isArabic ? "تأمين" : "Deposit"}: ${property.securityDepositMonths} ${l10n.isArabic ? "أشهر" : "mos"}',
                              ),
                            ] else if (property.isCashOnly) ...[
                              _buildSpecChip(
                                Icons.payments_outlined,
                                l10n.isArabic ? 'بيع كاش فقط' : 'Cash Only',
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
                            ] else ...[
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
                                Icons.calendar_month_outlined,
                                '${property.installmentYears} ${l10n.isArabic ? "سنوات تقسيط" : "Yrs Installment"}',
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              _buildSpecChip(
                                Icons.shield_outlined,
                                '${l10n.translate('maintenance_fee')}: ${(property.maintenanceRatio * 100).toInt()}%',
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // STRICT CONDITIONAL RENDERING: Transaction Specific Pricing Overview
                      if (property.forRent)
                        _buildRentalPricingCard(context, property, l10n, isDark)
                      else if (property.isCashOnly)
                        _buildCashSaleCard(context, property, l10n, isDark)
                      else
                        _buildInstallmentPricingCard(context, property, l10n, isDark),

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

                      // High-Resolution Floor Plan & Photos Gallery (Replacing Sun-Path Simulator)
                      _buildFloorPlanAndPhotosSection(context, property, l10n, isDark),
                      const SizedBox(height: 28),

                      // 3. Payment Plan Engine & Slider Simulator (SHOWN ONLY IF hasInstallments == true)
                      if (property.hasInstallments) ...[
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
                      ],

                      // 4. Investment & Yield Analysis (SHOWN ONLY IF isInvestmentOpportunity == true)
                      if (property.isInvestmentOpportunity) ...[
                        InvestmentRoiCalculator(
                          propertyPrice: property.price,
                        ),
                        const SizedBox(height: 28),
                      ],

                      const SizedBox(height: 140), // Safe padding ensuring scrollable content clears floating bar
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
                            final msg = property.forRent
                                ? (l10n.isArabic
                                    ? 'تم إرسال طلب معاينة الإيجار للمالك'
                                    : 'Rental viewing request sent to owner')
                                : (property.isCashOnly
                                    ? (l10n.isArabic
                                        ? 'تم تقديم عرض الشراء الكاش للوكيل'
                                        : 'Cash purchase offer submitted to agent')
                                    : (l10n.isArabic
                                        ? 'تم طلب خطة السداد المخصصة من المطور'
                                        : 'Custom payment plan requested from developer'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: theme.cardColor,
                                content: Text(
                                  msg,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            property.forRent
                                ? (l10n.isArabic
                                    ? "طلب موعد معاينة للإيجار"
                                    : "Request Rental Viewing")
                                : (property.isCashOnly
                                    ? (l10n.isArabic
                                        ? "تقديم عرض شراء كاش"
                                        : "Submit Cash Offer")
                                    : (l10n.isArabic
                                        ? "طلب خطة سداد مخصصة"
                                        : "Request Custom Plan")),
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

  // --- STRICT CONDITIONAL PRICING CARDS ---

  Widget _buildRentalPricingCard(
    BuildContext context,
    PropertyEntity property,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141C2B) : const Color(0xFFF7F5EE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: primary.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.key_rounded, size: 14, color: primary),
                    const SizedBox(width: 4),
                    Text(
                      l10n.isArabic ? 'وحدة سكنية للإيجار' : 'Residential Rental',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  property.isFurnished
                      ? (l10n.isArabic ? 'مفروشة بالكامل' : 'Fully Furnished')
                      : (l10n.isArabic ? 'غير مفروشة' : 'Unfurnished'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.isArabic ? 'الإيجار الشهري الصافي' : 'Net Monthly Rent',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              property.localizedPrice(l10n.isArabic),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: primary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Rental Specs Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.isArabic ? 'مبلغ التأمين التعاقدي' : 'Security Deposit',
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
                        property.localizedSecurityDeposit(l10n.isArabic),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      l10n.isArabic
                          ? '(${property.securityDepositMonths} أشهر مستردة)'
                          : '(${property.securityDepositMonths} mos refundable)',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 34, color: theme.dividerColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.isArabic ? 'الحد الأدنى للعقد' : 'Min. Lease',
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
                        l10n.isArabic
                            ? (property.minLeaseYears == 1 ? 'سنة واحدة' : '${property.minLeaseYears} سنوات')
                            : '${property.minLeaseYears} Year',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    Text(
                      l10n.isArabic ? 'قابل للتجديد' : 'Renewable',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 34, color: theme.dividerColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.isArabic ? 'مصاريف الصيانة' : 'Maintenance',
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
                        l10n.isArabic ? 'شاملة بالكامل' : 'Included',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    Text(
                      l10n.isArabic ? 'على المالك' : 'Covered by Owner',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Rental Terms Checklist
          if (property.rentalTerms.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: isDark ? 0.2 : 0.4,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel_rounded, size: 14, color: primary),
                      const SizedBox(width: 6),
                      Text(
                        l10n.isArabic ? 'شروط وقواعد الإيجار التعاقدية:' : 'Lease Terms & Rules:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...property.rentalTerms.map(
                    (term) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 14,
                            color: Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              term,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCashSaleCard(
    BuildContext context,
    PropertyEntity property,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141C2B) : const Color(0xFFF7F5EE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: primary.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.payments_rounded, size: 14, color: primary),
                    const SizedBox(width: 4),
                    Text(
                      l10n.isArabic ? 'بيع كاش فقط (بدون تقسيط)' : 'Cash Only Sale',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (property.cashDiscountPercent > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.isArabic
                        ? 'خصم فوري ${property.cashDiscountPercent}% للكاش'
                        : '${property.cashDiscountPercent}% Instant Cash Off',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.isArabic ? 'السعر الإجمالي المطلوب كاش' : 'Total Cash Asking Price',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              property.localizedPrice(l10n.isArabic),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: primary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Cash Specific Breakdown
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.isArabic ? 'وديعة الصيانة' : 'Maintenance Deposit',
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
                        '${(property.maintenanceRatio * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      AppLocalizations.formatPrice(
                        property.price * property.maintenanceRatio,
                        isArabic: l10n.isArabic,
                        currencySymbol: 'ج.م',
                      ),
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 34, color: theme.dividerColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.isArabic ? 'رسوم التنازل والتسجيل' : 'Transfer & Reg.',
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
                        property.localizedTransferFee(l10n.isArabic),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    Text(
                      l10n.isArabic ? 'نسبة ٢.٥٪ قانونية' : '2.5% Statutory Fee',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 34, color: theme.dividerColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.isArabic ? 'موعد الاستلام' : 'Delivery',
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
                        property.localizedDelivery(l10n.isArabic),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    Text(
                      l10n.isArabic ? 'معاينة فورية متاحة' : 'Viewing Available',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentPricingCard(
    BuildContext context,
    PropertyEntity property,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141C2B) : const Color(0xFFF7F5EE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: primary.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 14, color: primary),
                    const SizedBox(width: 4),
                    Text(
                      l10n.isArabic
                          ? 'تقسيط مباشر حتى ${property.installmentYears} سنوات'
                          : 'Installments up to ${property.installmentYears} Yrs',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (property.cashDiscountPercent > 0)
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
          const SizedBox(height: 12),
          Text(
            l10n.translate('total_price'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              property.localizedPrice(l10n.isArabic),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: primary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
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
    );
  }

  // --- ARCHITECTURAL FLOOR PLAN & PHOTO GALLERY SECTION ---

  Widget _buildFloorPlanAndPhotosSection(
    BuildContext context,
    PropertyEntity property,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final roomLabels = l10n.isArabic
        ? [
            'الريسبشن الرئيسي البانورامي',
            'غرفة النوم الماستر والأجنحة',
            'المطبخ المودرن ومنطقة المعيشة',
            'التراس الخارجي واللاندسكيب',
          ]
        : [
            'Grand Reception',
            'Master Suite & Bedrooms',
            'Modern Kitchen & Living',
            'Terrace & Landscape',
          ];

    final displayImages = property.images;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(
            alpha: isDark ? 0.2 : 0.6,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.architecture_rounded,
                      color: primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.isArabic
                            ? 'مخطط الوحدة والمعرض الهندسي'
                            : 'Floor Plan & Photo Gallery',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${property.areaSqm} م² • صافي',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tab Switcher: Floor Plan vs Photo Gallery
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _mediaTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _mediaTab == 0
                            ? (isDark ? const Color(0xFF2B384E) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _mediaTab == 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.3 : 0.05,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_rounded,
                            size: 16,
                            color: _mediaTab == 0
                                ? primary
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : const Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.isArabic
                                ? 'المخطط المعماري (2D)'
                                : 'Floor Plan (2D)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _mediaTab == 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _mediaTab == 0
                                  ? (isDark ? Colors.white : const Color(0xFF0F1B2B))
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.6)
                                      : const Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _mediaTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _mediaTab == 1
                            ? (isDark ? const Color(0xFF2B384E) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _mediaTab == 1
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.3 : 0.05,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_rounded,
                            size: 16,
                            color: _mediaTab == 1
                                ? primary
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : const Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.isArabic
                                ? 'صور الغرف (${displayImages.length})'
                                : 'Room Photos (${displayImages.length})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _mediaTab == 1
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _mediaTab == 1
                                  ? (isDark ? Colors.white : const Color(0xFF0F1B2B))
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.6)
                                      : const Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content based on selected tab
          if (_mediaTab == 0) ...[
            // 1. ARCHITECTURAL FLOOR PLAN VIEW
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141C2B) : const Color(0xFFF7F5F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primary.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Stack(
                children: [
                  // Architectural grid background
                  Positioned.fill(
                    child: Opacity(
                      opacity: isDark ? 0.15 : 0.25,
                      child: CustomPaint(
                        painter: _ArchitecturalGridPainter(
                          color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                        ),
                      ),
                    ),
                  ),

                  // Floor plan graphic illustration & Room layout tags
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.apartment_rounded,
                          size: 48,
                          color: primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.isArabic
                              ? 'المخطط الهندسي التوزيعي للوحدة'
                              : 'Architectural Layout Blueprint',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.isArabic
                              ? '${property.bedrooms} غرف نوم • ${property.bathrooms} حمامات • ريسبشن ٣ قطع'
                              : '${property.bedrooms} Beds • ${property.bathrooms} Baths • 3-Piece Reception',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.7)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Quick Room Specs Badges
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildRoomSpecPill('الريسبشن: 8.5 × 5.2 م', isDark, primary),
                            _buildRoomSpecPill('الماستر: 5.8 × 4.4 م', isDark, primary),
                            _buildRoomSpecPill('المطبخ: 4.0 × 3.2 م', isDark, primary),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Download / Fullscreen CTA
                  Positioned(
                    bottom: 10,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: theme.cardColor,
                            content: Text(
                              l10n.isArabic
                                  ? 'جاري فتح المخطط الهندسي بدقة ألترا HD...'
                                  : 'Opening Ultra-HD Blueprint...',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: primary.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in_rounded, size: 14, color: primary),
                            const SizedBox(width: 4),
                            Text(
                              l10n.isArabic ? 'تكبير المخطط' : 'Zoom Plan',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // 2. HIGH RESOLUTION ROOM PHOTOS CAROUSEL
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: displayImages.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final imgUrl = displayImages[index];
                  final label = index < roomLabels.length
                      ? roomLabels[index]
                      : (l10n.isArabic ? 'مساحة داخلية للوحدة' : 'Interior Space');

                  return GestureDetector(
                    onTap: () {
                      _showImageZoomDialog(context, imgUrl, label);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: imgUrl,
                            width: 250,
                            height: 190,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 250,
                              height: 190,
                              color: isDark ? const Color(0xFF141C2B) : const Color(0xFFE8E5DD),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primary,
                                ),
                              ),
                            ),
                          ),
                          // Gradient Overlay
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.75),
                                  ],
                                  stops: const [0.45, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // Zoom Icon
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.fullscreen_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          // Room Tag Label
                          Positioned(
                            bottom: 10,
                            left: 12,
                            right: 12,
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoomSpecPill(String text, bool isDark, Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2838) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF0F1B2B),
        ),
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

class _ArchitecturalGridPainter extends CustomPainter {
  final Color color;

  _ArchitecturalGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    const double step = 20.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArchitecturalGridPainter oldDelegate) =>
      oldDelegate.color != color;
}
