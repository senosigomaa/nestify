import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';

/// PropertyComparisonSheet renders a commercial side-by-side spec comparison
/// between two units, matching Dubizzle & Property Finder standards.
class PropertyComparisonSheet extends StatelessWidget {
  final PropertyEntity propertyA;
  final PropertyEntity propertyB;

  const PropertyComparisonSheet({
    super.key,
    required this.propertyA,
    required this.propertyB,
  });

  static Future<void> show(
    BuildContext context, {
    required PropertyEntity propertyA,
    required PropertyEntity propertyB,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PropertyComparisonSheet(
        propertyA: propertyA,
        propertyB: propertyB,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: AppColors.borderLight, width: 1.5),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.compare_arrows_rounded,
                        color: AppColors.neonCyan,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.translate('comparing_units'),
                        style: AppTypography.headlineMedium,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Side-by-Side Unit Preview Headers
              Row(
                children: [
                  Expanded(child: _buildUnitThumbnail(propertyA)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildUnitThumbnail(propertyB)),
                ],
              ),
              const SizedBox(height: 18),

              // Scrollable Spec Comparison Matrix
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildComparisonRow(
                      label: l10n.translate('metric_price'),
                      valA: propertyA.localizedPrice(l10n.isArabic),
                      valB: propertyB.localizedPrice(l10n.isArabic),
                      highlightA: propertyA.price < propertyB.price,
                      highlightB: propertyB.price < propertyA.price,
                    ),
                    _buildComparisonRow(
                      label: l10n.translate('metric_price_sqm'),
                      valA: '${AppLocalizations.formatPrice(propertyA.pricePerSqm, isArabic: l10n.isArabic)} / ${l10n.translate('sqm')}',
                      valB: '${AppLocalizations.formatPrice(propertyB.pricePerSqm, isArabic: l10n.isArabic)} / ${l10n.translate('sqm')}',
                      highlightA: propertyA.pricePerSqm < propertyB.pricePerSqm,
                      highlightB: propertyB.pricePerSqm < propertyA.pricePerSqm,
                    ),
                    _buildComparisonRow(
                      label: l10n.translate('metric_down_payment'),
                      valA: propertyA.localizedDownPayment(l10n.isArabic),
                      valB: propertyB.localizedDownPayment(l10n.isArabic),
                    ),
                    _buildComparisonRow(
                      label: l10n.translate('metric_monthly'),
                      valA: propertyA.localizedMonthlyInstallment(l10n.isArabic),
                      valB: propertyB.localizedMonthlyInstallment(l10n.isArabic),
                    ),
                    _buildComparisonRow(
                      label: l10n.translate('metric_delivery'),
                      valA: '${propertyA.deliveryYear}',
                      valB: '${propertyB.deliveryYear}',
                    ),
                    _buildComparisonRow(
                      label: l10n.translate('metric_yield'),
                      valA: '${propertyA.rentalYieldPct}% ROI',
                      valB: '${propertyB.rentalYieldPct}% ROI',
                      highlightA: propertyA.rentalYieldPct > propertyB.rentalYieldPct,
                      highlightB: propertyB.rentalYieldPct > propertyA.rentalYieldPct,
                    ),
                    _buildComparisonRow(
                      label: l10n.translate('metric_acoustic'),
                      valA: '${propertyA.noiseLevelDb} dB',
                      valB: '${propertyB.noiseLevelDb} dB',
                      highlightA: propertyA.noiseLevelDb < propertyB.noiseLevelDb,
                      highlightB: propertyB.noiseLevelDb < propertyA.noiseLevelDb,
                    ),
                    _buildComparisonRow(
                      label: l10n.translate('virtual_tour_360'),
                      valA: propertyA.hasVirtualTour360 ? 'Available' : 'No',
                      valB: propertyB.hasVirtualTour360 ? 'Available' : 'No',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitThumbnail(PropertyEntity property) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: property.images.first,
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            property.title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            property.developerName,
            style: const TextStyle(fontSize: 10, color: AppColors.neonCyan),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow({
    required String label,
    required String valA,
    required String valB,
    bool highlightA = false,
    bool highlightB = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  valA,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: highlightA ? AppColors.neonCyan : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(width: 1, height: 16, color: Colors.white12),
              Expanded(
                child: Text(
                  valB,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: highlightB ? AppColors.neonCyan : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
