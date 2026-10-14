import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';

/// InvestmentRoiCalculator provides commercial-grade financial analysis
/// including Gross Rental Yield, 5-Year Capital Appreciation projection,
/// and break-even amortization timelines.
class InvestmentRoiCalculator extends StatefulWidget {
  final double propertyPrice;

  const InvestmentRoiCalculator({
    super.key,
    required this.propertyPrice,
  });

  @override
  State<InvestmentRoiCalculator> createState() =>
      _InvestmentRoiCalculatorState();
}

class _InvestmentRoiCalculatorState extends State<InvestmentRoiCalculator> {
  bool _isExpanded = true;
  double _downPaymentPct = 0.25; // 25%
  double _monthlyRent = 0.0;
  double _occupancyRate = 0.95; // 95%
  final double _annualAppreciationRate = 0.068; // 6.8% historical prime CAGR

  @override
  void initState() {
    super.initState();
    // Default estimated rent: ~0.45% of property value per month
    _monthlyRent = (widget.propertyPrice * 0.0045).roundToDouble();
  }

  String _formatCurrency(double amount, [bool isArabic = false, bool isMonthly = false]) {
    return AppLocalizations.formatPrice(
      amount,
      isArabic: isArabic,
      isMonthly: isMonthly,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final annualGrossRent = _monthlyRent * 12 * _occupancyRate;
    final grossYieldPct = (widget.propertyPrice > 0 && annualGrossRent.isFinite)
        ? (annualGrossRent / widget.propertyPrice) * 100
        : 0.0;
    final downPaymentAmount = widget.propertyPrice * _downPaymentPct;

    // Projected 5-Year Capital Value: P * (1 + r)^5
    final projected5YearValue =
        widget.propertyPrice * pow(1 + _annualAppreciationRate, 5);
    final capitalGrowth5Yr = projected5YearValue - widget.propertyPrice;

    // Break-even years (Down payment / annual gross net)
    final breakEvenYears =
        annualGrossRent > 0 ? (downPaymentAmount / annualGrossRent) : 0.0;

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
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Expand Toggle
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.trending_up_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.translate('roi_title'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${grossYieldPct.toStringAsFixed(1)}% ${l10n.isArabic ? "عائد سنوي متوقع" : "Gross Yield Projected"}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),

          if (_isExpanded) ...[
            const SizedBox(height: 20),

            // 1. KPI Highlights Grid
            Row(
              children: [
                Expanded(
                  child: _buildKpiBox(
                    title: l10n.translate('gross_yield'),
                    value: '${grossYieldPct.toStringAsFixed(2)}%',
                    valueColor: theme.colorScheme.primary,
                    subtitle: 'Benchmark: > 4.5%',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildKpiBox(
                    title: l10n.translate('capital_appreciation'),
                    value: '+${_formatCurrency(capitalGrowth5Yr, l10n.isArabic)}',
                    valueColor: theme.colorScheme.secondary,
                    subtitle: '+${((pow(1 + _annualAppreciationRate, 5) - 1) * 100).toInt()}% Total Gain',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildKpiBox(
                    title: l10n.translate('breakeven'),
                    value: '${breakEvenYears.toStringAsFixed(1)} ${l10n.translate('years')}',
                    valueColor: theme.colorScheme.primary,
                    subtitle: 'Full Escrow Recoup',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Interactive Input Controls
            // Monthly Rent
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.translate('expected_rent'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _formatCurrency(_monthlyRent, l10n.isArabic, true),
                    style: AppTypography.priceTag.copyWith(
                      fontSize: 15,
                      color: theme.colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Slider(
              value: _monthlyRent,
              min: (widget.propertyPrice * 0.002).roundToDouble(),
              max: (widget.propertyPrice * 0.008).roundToDouble(),
              activeColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.outlineVariant.withValues(
                alpha: isDark ? 0.2 : 0.6,
              ),
              onChanged: (val) {
                setState(() {
                  _monthlyRent = val;
                });
              },
            ),

            // Occupancy Rate
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.translate('occupancy_rate'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(_occupancyRate * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            Slider(
              value: _occupancyRate,
              min: 0.70,
              max: 1.0,
              divisions: 6,
              activeColor: theme.colorScheme.secondary,
              inactiveColor: theme.colorScheme.outlineVariant.withValues(
                alpha: isDark ? 0.2 : 0.6,
              ),
              onChanged: (val) {
                setState(() {
                  _occupancyRate = val;
                });
              },
            ),

            // Down Payment Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.translate('down_payment_target'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${(_downPaymentPct * 100).toInt()}% (${_formatCurrency(downPaymentAmount, l10n.isArabic)})',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Slider(
              value: _downPaymentPct,
              min: 0.10,
              max: 0.50,
              divisions: 8,
              activeColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.outlineVariant.withValues(
                alpha: isDark ? 0.2 : 0.6,
              ),
              onChanged: (val) {
                setState(() {
                  _downPaymentPct = val;
                });
              },
            ),
            const SizedBox(height: 14),

            // 3. Projected 5-Year Capital Appreciation Visualizer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF141C2B)
                    : const Color(0xFFF7F5F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: isDark ? 0.2 : 0.6,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.translate('equity_growth_projected'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatCurrency(projected5YearValue, l10n.isArabic),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 5-Year Step Bars
                  Row(
                    children: List.generate(5, (index) {
                      final yearFactor =
                          pow(1 + _annualAppreciationRate, index + 1);
                      final fillPct =
                          ((yearFactor - 1.0) / (pow(1 + _annualAppreciationRate, 5) - 1.0))
                              .clamp(0.2, 1.0);

                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: Column(
                            children: [
                              Container(
                                height: 36 * fillPct,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary.withValues(
                                        alpha: 0.4 + (index * 0.15),
                                      ),
                                      theme.colorScheme.primary,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.isArabic ? 'س${index + 1}' : 'Y${index + 1}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKpiBox({
    required String title,
    required String value,
    required Color valueColor,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF141C2B)
            : const Color(0xFFF7F5F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: valueColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
