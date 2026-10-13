import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/features/co_living/presentation/bloc/co_living_bloc.dart';
import 'package:nestify/features/co_living/presentation/bloc/co_living_event.dart';
import 'package:nestify/features/co_living/presentation/bloc/co_living_state.dart';

/// SmartSplitCalculator provides a reactive co-buying and co-living calculator
/// featuring instant mathematical distribution of down payments, mortgage notes,
/// and utilities for Gen-Z co-purchasing groups.
class SmartSplitCalculator extends StatelessWidget {
  final double propertyPrice;
  final bool isRent;

  const SmartSplitCalculator({
    super.key,
    required this.propertyPrice,
    this.isRent = false,
  });

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

    return BlocProvider(
      create: (context) => CoLivingBloc()
        ..add(
          InitializeCalculatorEvent(
            propertyPrice: propertyPrice,
            mode: isRent ? SplitMode.coRent : SplitMode.coBuy,
          ),
        ),
      child: BlocBuilder<CoLivingBloc, CoLivingState>(
        builder: (context, state) {
          final isCoBuy = state.splitMode == SplitMode.coBuy;
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
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Mode Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.pie_chart_outline_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              l10n.translate('smart_split_title'),
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
                    // Buy vs Rent Mode Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF141C2B)
                            : const Color(0xFFEFECE6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Row(
                        children: [
                          _buildModeChip(
                            context: context,
                            title: l10n.translate('co_buy'),
                            isSelected: isCoBuy,
                            onTap: () => context.read<CoLivingBloc>().add(
                                  const ToggleSplitModeEvent(SplitMode.coBuy),
                                ),
                          ),
                          _buildModeChip(
                            context: context,
                            title: l10n.translate('co_rent'),
                            isSelected: !isCoBuy,
                            onTap: () => context.read<CoLivingBloc>().add(
                                  const ToggleSplitModeEvent(SplitMode.coRent),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Co-Buyers / Roommates Slider Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isCoBuy
                            ? l10n.translate('co_investors')
                            : l10n.translate('roommates_sharing'),
                        style: AppTypography.labelLarge.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '${state.coBuyersCount} ${l10n.translate('persons')} (${state.equitySharePercentage.toStringAsFixed(1)}% ${l10n.translate('each')})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Co-Buyers Count Slider (1 to 6)
                Slider(
                  value: state.coBuyersCount.toDouble(),
                  min: 1,
                  max: 6,
                  divisions: 5,
                  label: '${state.coBuyersCount} People',
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: theme.colorScheme.outlineVariant.withValues(
                    alpha: isDark ? 0.2 : 0.6,
                  ),
                  onChanged: (val) {
                    context
                        .read<CoLivingBloc>()
                        .add(UpdateCoBuyersCountEvent(val.round()));
                  },
                ),

                // Avatars Indicator Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(state.coBuyersCount, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? const Color(0xFF141C2B)
                            : const Color(0xFFF7F5F0),
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C...
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),

                // Down Payment percentage slider (Only for Co-Buy mode)
                if (isCoBuy) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.translate('down_payment_target'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        '${(state.downPaymentPercentage * 100).toInt()}% (${_formatCurrency(state.totalDownPayment, l10n.isArabic)})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: theme.colorScheme.secondary,
                      thumbColor: theme.colorScheme.secondary,
                      overlayColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: state.downPaymentPercentage,
                      min: 0.10,
                      max: 0.50,
                      divisions: 8,
                      onChanged: (val) {
                        context
                            .read<CoLivingBloc>()
                            .add(UpdateDownPaymentPercentageEvent(val));
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Instant Calculation Breakdown Cards
                Container(
                  padding: const EdgeInsets.all(16),
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
                    children: [
                      if (isCoBuy) ...[
                        _buildCalculationRow(
                          title: l10n.translate('down_payment_person'),
                          value: _formatCurrency(state.downPaymentPerPerson, l10n.isArabic),
                          valueColor: theme.colorScheme.secondary,
                          subtitle: l10n.isArabic
                              ? 'دفعة ضمان أولى (${(state.downPaymentPercentage * 100).toInt()}%)'
                              : 'One-time escrow wire (${(state.downPaymentPercentage * 100).toInt()}%)',
                        ),
                        const Divider(height: 20),
                        _buildCalculationRow(
                          title: l10n.translate('mortgage_share'),
                          value: _formatCurrency(state.monthlyInstallmentPerPerson, l10n.isArabic, true),
                          subtitle: l10n.isArabic
                              ? 'قسط 30 سنة بفائدة ثابتة ${(state.annualInterestRate * 100).toStringAsFixed(1)}%'
                              : '30yr fixed @ ${(state.annualInterestRate * 100).toStringAsFixed(1)}%',
                        ),
                      ] else ...[
                        _buildCalculationRow(
                          title: l10n.translate('base_rent_split'),
                          value: _formatCurrency(state.monthlyInstallmentPerPerson, l10n.isArabic, true),
                          subtitle: l10n.isArabic
                              ? 'تقسيم متساوي بين شركاء السكن'
                              : 'Divided equally across roommates',
                        ),
                      ],
                      const Divider(height: 20),
                      _buildCalculationRow(
                        title: l10n.translate('smart_utilities'),
                        value: _formatCurrency(state.utilitiesPerPerson, l10n.isArabic, true),
                        subtitle: l10n.isArabic
                            ? 'إنترنت 10 جيجابت، مياه، كهرباء، كونسيرج'
                            : '10Gbps Internet, Energy, Water, Concierge',
                      ),
                      const Divider(height: 20),
                      // Grand Total Monthly
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.translate('total_monthly_person'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onSurface,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  l10n.translate('all_inclusive_desc'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _formatCurrency(state.totalMonthlyOutflowPerPerson, l10n.isArabic, true),
                              style: AppTypography.priceTag.copyWith(
                                fontSize: 18,
                                color: theme.colorScheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Share / Invite Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: theme.cardColor,
                          content: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.translate('invite_copied'),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.share_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(
                      isCoBuy
                          ? l10n.translate('generate_term_sheet')
                          : l10n.translate('share_split'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeChip({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected
                ? (isDark ? const Color(0xFF0B0E14) : Colors.white)
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildCalculationRow({
    required String title,
    required String value,
    String? subtitle,
    Color? valueColor,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              value,
              style: AppTypography.metricValue.copyWith(
                fontSize: 16,
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ],
        );
      },
    );
  }
}
