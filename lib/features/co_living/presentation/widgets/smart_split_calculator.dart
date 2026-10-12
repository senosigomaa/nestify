import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
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

          return Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDarkCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.borderLight,
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
                    const Row(
                      children: [
                        Icon(
                          Icons.pie_chart_outline_rounded,
                          color: AppColors.neonCyan,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Smart Split Calculator',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    // Buy vs Rent Mode Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDarkElevated,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Row(
                        children: [
                          _buildModeChip(
                            context: context,
                            title: 'CO-BUY',
                            isSelected: isCoBuy,
                            onTap: () => context.read<CoLivingBloc>().add(
                                  const ToggleSplitModeEvent(SplitMode.coBuy),
                                ),
                          ),
                          _buildModeChip(
                            context: context,
                            title: 'CO-RENT',
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
                    Text(
                      isCoBuy ? 'Co-Investors / Buyers' : 'Roommates Sharing',
                      style: AppTypography.labelLarge,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.neonCyan.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '${state.coBuyersCount} PERSONS (${state.equitySharePercentage.toStringAsFixed(1)}% EACH)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neonCyan,
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
                  activeColor: AppColors.neonCyan,
                  inactiveColor: AppColors.surfaceDarkElevated,
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
                        color: AppColors.surfaceDarkElevated,
                        border: Border.all(
                          color: AppColors.neonCyan,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C...
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neonCyan,
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
                      const Text(
                        'Down Payment Target',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${(state.downPaymentPercentage * 100).toInt()}% (${_formatCurrency(state.totalDownPayment)} Total)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.amberGold,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.amberGold,
                      thumbColor: AppColors.amberGold,
                      overlayColor: AppColors.amberGlow,
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
                    color: AppColors.backgroundDark.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (isCoBuy) ...[
                        _buildCalculationRow(
                          title: 'Down Payment Per Person',
                          value: _formatCurrency(state.downPaymentPerPerson),
                          valueColor: AppColors.amberGold,
                          subtitle:
                              'One-time escrow wire (${(state.downPaymentPercentage * 100).toInt()}%)',
                        ),
                        const Divider(height: 20),
                        _buildCalculationRow(
                          title: 'Mortgage Note Share',
                          value:
                              '${_formatCurrency(state.monthlyInstallmentPerPerson)}/mo',
                          subtitle:
                              '30yr fixed @ ${(state.annualInterestRate * 100).toStringAsFixed(1)}%',
                        ),
                      ] else ...[
                        _buildCalculationRow(
                          title: 'Base Rent Split',
                          value:
                              '${_formatCurrency(state.monthlyInstallmentPerPerson)}/mo',
                          subtitle: 'Divided equally across roommates',
                        ),
                      ],
                      const Divider(height: 20),
                      _buildCalculationRow(
                        title: 'Smart Utilities & Fiber',
                        value:
                            '${_formatCurrency(state.utilitiesPerPerson)}/mo',
                        subtitle: '10Gbps Internet, Energy, Water, Concierge',
                      ),
                      const Divider(height: 20),
                      // Grand Total Monthly
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL MONTHLY / PERSON',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'All-inclusive housing commitment',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${_formatCurrency(state.totalMonthlyOutflowPerPerson)}/mo',
                            style: AppTypography.priceTag.copyWith(
                              fontSize: 22,
                              color: AppColors.neonCyan,
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
                                  'Co-Investment invite link copied! Ready to share with your group.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.share_rounded,
                      size: 16,
                      color: AppColors.neonCyan,
                    ),
                    label: Text(
                      isCoBuy
                          ? 'Generate Co-Ownership Term Sheet'
                          : 'Share Co-Living Split with Friends',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neonCyan,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonCyan : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? AppColors.backgroundDark : AppColors.textMuted,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
        Text(
          value,
          style: AppTypography.metricValue.copyWith(
            fontSize: 16,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
