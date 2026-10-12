import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nestify/core/constants/app_colors.dart';
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

  String _formatCurrency(double amount) {
    final int rounded = amount.round();
    final str = rounded.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write(',');
      }
    }
    return '\$${buffer.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final annualGrossRent = _monthlyRent * 12 * _occupancyRate;
    final grossYieldPct = (annualGrossRent / widget.propertyPrice) * 100;
    final downPaymentAmount = widget.propertyPrice * _downPaymentPct;

    // Projected 5-Year Capital Value: P * (1 + r)^5
    final projected5YearValue =
        widget.propertyPrice * pow(1 + _annualAppreciationRate, 5);
    final capitalGrowth5Yr = projected5YearValue - widget.propertyPrice;

    // Break-even years (Down payment / annual gross net)
    final breakEvenYears =
        annualGrossRent > 0 ? (downPaymentAmount / annualGrossRent) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.25),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.trending_up_rounded,
                        color: AppColors.neonCyan,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.translate('roi_title'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${grossYieldPct.toStringAsFixed(1)}% Gross Yield Projected',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neonCyan,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.neonCyan,
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
                    valueColor: AppColors.neonCyan,
                    subtitle: 'Benchmark: > 4.5%',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildKpiBox(
                    title: l10n.translate('capital_appreciation'),
                    value: '+${_formatCurrency(capitalGrowth5Yr)}',
                    valueColor: AppColors.amberGold,
                    subtitle: '+${((pow(1 + _annualAppreciationRate, 5) - 1) * 100).toInt()}% Total Gain',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildKpiBox(
                    title: l10n.translate('breakeven'),
                    value: '${breakEvenYears.toStringAsFixed(1)} ${l10n.translate('years')}',
                    valueColor: const Color(0xFF69F0AE),
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
                Text(
                  l10n.translate('expected_rent'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${_formatCurrency(_monthlyRent)} / mo',
                  style: AppTypography.priceTag.copyWith(fontSize: 16),
                ),
              ],
            ),
            Slider(
              value: _monthlyRent,
              min: (widget.propertyPrice * 0.002).roundToDouble(),
              max: (widget.propertyPrice * 0.008).roundToDouble(),
              activeColor: AppColors.neonCyan,
              inactiveColor: AppColors.surfaceDarkElevated,
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
                Text(
                  l10n.translate('occupancy_rate'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${(_occupancyRate * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.amberGold,
                  ),
                ),
              ],
            ),
            Slider(
              value: _occupancyRate,
              min: 0.70,
              max: 1.0,
              divisions: 6,
              activeColor: AppColors.amberGold,
              inactiveColor: AppColors.surfaceDarkElevated,
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
                Text(
                  l10n.translate('down_payment_target'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${(_downPaymentPct * 100).toInt()}% (${_formatCurrency(downPaymentAmount)})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Slider(
              value: _downPaymentPct,
              min: 0.10,
              max: 0.50,
              divisions: 8,
              activeColor: AppColors.cyanVariant,
              inactiveColor: AppColors.surfaceDarkElevated,
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
                color: AppColors.backgroundDark.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.translate('equity_growth_projected'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _formatCurrency(projected5YearValue),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neonCyan,
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
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            children: [
                              Container(
                                height: 36 * fillPct,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.neonCyan
                                          .withValues(alpha: 0.4 + (index * 0.15)),
                                      AppColors.cyanVariant,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Y${index + 1}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
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
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkElevated,
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
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
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
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
