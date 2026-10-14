import 'package:flutter/material.dart';
import 'package:nestify/core/localization/app_localizations.dart';

/// EgyptianPaymentPlanSlider provides an authentic real-estate payment plan simulator
/// tailored for Egyptian buyers (New Cairo, Sheikh Zayed, New Capital compounds).
/// It enables dynamic recalculation of Down Payment, Monthly & Quarterly Installments,
/// Delivery Maintenance Deposit (8-10%), and Upfront Cash Discount comparisons.
class EgyptianPaymentPlanSlider extends StatefulWidget {
  final double propertyPrice;
  final double initialDownPaymentPct;
  final int initialYears;
  final double maintenancePct;
  final int cashDiscountPct;

  const EgyptianPaymentPlanSlider({
    super.key,
    required this.propertyPrice,
    this.initialDownPaymentPct = 10.0,
    this.initialYears = 8,
    this.maintenancePct = 0.08,
    this.cashDiscountPct = 25,
  });

  @override
  State<EgyptianPaymentPlanSlider> createState() => _EgyptianPaymentPlanSliderState();
}

class _EgyptianPaymentPlanSliderState extends State<EgyptianPaymentPlanSlider> {
  late double _downPaymentPct;
  late int _years;
  bool _showQuarterly = false;

  @override
  void initState() {
    super.initState();
    _downPaymentPct = widget.initialDownPaymentPct.clamp(5.0, 30.0);
    _years = widget.initialYears.clamp(3, 10);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isArabic = l10n.isArabic;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    // Mathematical calculations
    final downPaymentAmount = widget.propertyPrice * (_downPaymentPct / 100.0);
    final remainingAmount = widget.propertyPrice - downPaymentAmount;
    final totalMonths = _years * 12;
    final monthlyInstallment = (totalMonths > 0 && remainingAmount.isFinite && !remainingAmount.isNaN)
        ? remainingAmount / totalMonths
        : 0.0;
    final quarterlyInstallment = monthlyInstallment * 3;
    final maintenanceDeposit = widget.propertyPrice * widget.maintenancePct;
    final cashSavings = widget.propertyPrice * (widget.cashDiscountPct / 100.0);
    final cashPrice = widget.propertyPrice - cashSavings;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.3 : 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : const Color(0x0F0F1B2B),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calculate_rounded,
                  color: primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('payment_plan_simulator'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.translate('payment_plan_desc'),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 1. Down Payment Slider Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.translate('down_payment_slider'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${_downPaymentPct.toInt()}% = ${AppLocalizations.formatPrice(downPaymentAmount, currencySymbol: "ج.م", isArabic: isArabic)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: primaryColor,
              inactiveTrackColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
              thumbColor: primaryColor,
              overlayColor: primaryColor.withValues(alpha: 0.15),
              trackHeight: 6,
            ),
            child: Slider(
              value: _downPaymentPct,
              min: 5.0,
              max: 30.0,
              divisions: 5,
              onChanged: (val) {
                setState(() {
                  _downPaymentPct = val;
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          // 2. Installment Duration Slider Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.translate('years_slider'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: secondaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: secondaryColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  isArabic ? '$_years سنوات ($totalMonths شهر)' : '$_years Years ($totalMonths Mos)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: secondaryColor,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: secondaryColor,
              inactiveTrackColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
              thumbColor: secondaryColor,
              overlayColor: secondaryColor.withValues(alpha: 0.15),
              trackHeight: 6,
            ),
            child: Slider(
              value: _years.toDouble(),
              min: 3.0,
              max: 10.0,
              divisions: 7,
              onChanged: (val) {
                setState(() {
                  _years = val.round();
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Cadence Toggle (Monthly vs Quarterly)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCadencePill(
                title: l10n.translate('monthly_installment'),
                isActive: !_showQuarterly,
                onTap: () => setState(() => _showQuarterly = false),
              ),
              const SizedBox(width: 8),
              _buildCadencePill(
                title: l10n.translate('quarterly_installment'),
                isActive: _showQuarterly,
                onTap: () => setState(() => _showQuarterly = true),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Key Installment Metrics Cards
          Row(
            children: [
              // Installment Value Card (Primary CTA)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF141C2B)
                        : const Color(0xFFF6F3EC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _showQuarterly
                            ? l10n.translate('quarterly_installment')
                            : l10n.translate('monthly_installment'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          AppLocalizations.formatPrice(
                            _showQuarterly ? quarterlyInstallment : monthlyInstallment,
                            currencySymbol: 'ج.م',
                            isArabic: isArabic,
                            isMonthly: !_showQuarterly,
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Remaining Amount
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF141C2B)
                        : const Color(0xFFF6F3EC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('remaining_amount'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          AppLocalizations.formatPrice(
                            remainingAmount,
                            currencySymbol: 'ج.م',
                            isArabic: isArabic,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Maintenance Fee Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161F2E) : const Color(0xFFF8FAF7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF2D5A46).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: Color(0xFF2D5A46),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${l10n.translate('maintenance_fee')}: ${(widget.maintenancePct * 100).toInt()}% = ${AppLocalizations.formatPrice(maintenanceDeposit, currencySymbol: "ج.م", isArabic: isArabic)} (${isArabic ? "عند الاستلام" : "at delivery"})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D5A46),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Upfront Cash Discount Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF1E3A2B),
                        const Color(0xFF14241C),
                      ]
                    : [
                        const Color(0xFFE8F5E9),
                        const Color(0xFFF1F8E9),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.45),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_offer_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isArabic ? 'وفر كاش ${widget.cashDiscountPct}%!' : 'Cash Discount ${widget.cashDiscountPct}%!',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isArabic
                                  ? '(وفر ${AppLocalizations.formatPrice(cashSavings, currencySymbol: "ج.م", isArabic: isArabic)})'
                                  : '(Save ${AppLocalizations.formatPrice(cashSavings, currencySymbol: "EGP")})',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : const Color(0xFF33691E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.translate('cash_price')}: ${AppLocalizations.formatPrice(cashPrice, currencySymbol: "ج.م", isArabic: isArabic)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCadencePill({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? primaryColor : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.black : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
