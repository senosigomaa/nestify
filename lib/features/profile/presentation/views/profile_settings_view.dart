import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/core/localization/locale_bloc/locale_bloc.dart';
import 'package:nestify/core/localization/locale_bloc/locale_event.dart';
import 'package:nestify/core/localization/locale_bloc/locale_state.dart';

/// ProfileSettingsView handles user identity, bilingual language switching,
/// real-estate acoustic preferences, and VIP concierge hotline access.
class ProfileSettingsView extends StatefulWidget {
  const ProfileSettingsView({super.key});

  @override
  State<ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<ProfileSettingsView> {
  double _noiseTolerance = 38.0; // dB
  String _selectedStyle = 'Minimalist Japandi';

  final List<String> _architecturalStyles = [
    'Minimalist Japandi',
    'Cyberpunk Loft',
    'Warm Scandinavian',
    'Modern Art Deco',
    'Biophilic High-Rise',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                l10n.translate('profile_title'),
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: 18),

              // 1. VIP Investor Identity Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF16233B),
                      Color(0xFF0F1829),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.neonCyan,
                              width: 2,
                            ),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Sari Al-Mansoor',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 16,
                                    color: AppColors.neonCyan,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                l10n.translate('verified_investor'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neonCyan,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.translate('membership_tier'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.amberGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatMini(label: 'CO-BUY SHARES', value: '2 Properties'),
                        _StatMini(label: 'ESCROW STATUS', value: 'Verified \$1.2M'),
                        _StatMini(label: 'VIP TIER', value: 'Black Card'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Language Selection Card (RTL / LTR)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDarkCard,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.translate_rounded,
                          color: AppColors.neonCyan,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.translate('language_setting'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    BlocBuilder<LocaleBloc, LocaleState>(
                      builder: (context, state) {
                        final isArabic = state.isArabic;
                        return Row(
                          children: [
                            Expanded(
                              child: _buildLanguageOption(
                                label: 'English (US)',
                                isSelected: !isArabic,
                                onTap: () {
                                  context.read<LocaleBloc>().add(
                                        const SetLocaleEvent(Locale('en')),
                                      );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildLanguageOption(
                                label: 'العربية (RTL)',
                                isSelected: isArabic,
                                onTap: () {
                                  context.read<LocaleBloc>().add(
                                        const SetLocaleEvent(Locale('ar')),
                                      );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Acoustic & Architectural Preferences
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDarkCard,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.translate('noise_tolerance'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${_noiseTolerance.round()} dB',
                          style: AppTypography.priceTag.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    Slider(
                      value: _noiseTolerance,
                      min: 25.0,
                      max: 55.0,
                      divisions: 30,
                      activeColor: AppColors.neonCyan,
                      inactiveColor: AppColors.surfaceDarkElevated,
                      onChanged: (val) {
                        setState(() {
                          _noiseTolerance = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.translate('preferred_style'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _architecturalStyles.map((style) {
                        final isSelected = style == _selectedStyle;
                        return ChoiceChip(
                          label: Text(style),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedStyle = style);
                          },
                          selectedColor:
                              AppColors.neonCyan.withValues(alpha: 0.2),
                          backgroundColor: AppColors.surfaceDarkElevated,
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.neonCyan
                                : AppColors.textSecondary,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.neonCyan
                                : Colors.white.withValues(alpha: 0.08),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. Wealth Advisor Hotline Concierge
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x33FFB300),
                      Color(0x1A141C2B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.amberGold.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.amberGold.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.support_agent_rounded,
                            color: AppColors.amberGold,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.translate('contact_concierge'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '24/7 Dedicated Spatial & Escrow Support',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.amberGold,
                          foregroundColor: AppColors.backgroundDark,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.surfaceDarkElevated,
                              content: Text(
                                l10n.translate('hotline_call'),
                                style: const TextStyle(
                                  color: AppColors.amberGold,
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                        label: const Text('Call Dedicated Advisor'),
                      ),
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

  Widget _buildLanguageOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonCyan.withValues(alpha: 0.15)
              : AppColors.surfaceDarkElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.neonCyan
                : Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppColors.neonCyan : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;

  const _StatMini({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
