import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/core/localization/locale_bloc/locale_bloc.dart';
import 'package:nestify/core/localization/locale_bloc/locale_event.dart';
import 'package:nestify/core/localization/locale_bloc/locale_state.dart';
import 'package:nestify/core/theme/theme_bloc/theme_bloc.dart';
import 'package:nestify/core/theme/theme_bloc/theme_event.dart';
import 'package:nestify/core/theme/theme_bloc/theme_state.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                style: AppTypography.headlineLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 18),

              // 1. VIP Investor Identity Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF16233B),
                            const Color(0xFF0F1829),
                          ]
                        : [
                            Colors.white,
                            const Color(0xFFF7F5F0),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
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
                              color: theme.colorScheme.primary,
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
                                  Text(
                                    'Sari Al-Mansoor',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                l10n.translate('verified_investor'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.translate('membership_tier'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 24,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: isDark ? 0.2 : 0.6,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatMini(
                          label: l10n.isArabic ? 'الحصص المملوكة' : 'CO-BUY SHARES',
                          value: l10n.isArabic ? 'عقاران' : '2 Properties',
                        ),
                        _StatMini(
                          label: l10n.isArabic ? 'رصيد الضمان' : 'ESCROW STATUS',
                          value: l10n.isArabic ? '١.٢ مليون ج.م' : '1.2M EGP',
                        ),
                        _StatMini(
                          label: l10n.isArabic ? 'فئة العضوية' : 'VIP TIER',
                          value: l10n.isArabic ? 'البلاك كارد' : 'Black Card',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Dual-Theme Selection Card (Nordic Minimalist Light vs Obsidian Dark)
              Container(
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
                    Row(
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.translate('theme_setting'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, themeState) {
                        final isThemeDark = themeState.isDark;
                        return Row(
                          children: [
                            Expanded(
                              child: _buildThemeOption(
                                label: l10n.translate('theme_nordic_light'),
                                subtitle: l10n.isArabic ? 'عاجي وذهبي' : 'Ivory & Gold',
                                icon: Icons.light_mode_rounded,
                                isSelected: !isThemeDark,
                                activeColor: const Color(0xFFC5A880),
                                onTap: () {
                                  context.read<ThemeBloc>().add(
                                        const SetThemeEvent(ThemeMode.light),
                                      );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildThemeOption(
                                label: l10n.translate('theme_obsidian_dark'),
                                subtitle: l10n.isArabic ? 'حجر أوبسيديان' : 'Luxury Slate',
                                icon: Icons.dark_mode_rounded,
                                isSelected: isThemeDark,
                                activeColor: const Color(0xFF00F5D4),
                                onTap: () {
                                  context.read<ThemeBloc>().add(
                                        const SetThemeEvent(ThemeMode.dark),
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

              // 2. Language Selection Card (RTL / LTR)
              Container(
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
                    Row(
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.translate('language_setting'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.translate('noise_tolerance'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${_noiseTolerance.round()} dB',
                          style: AppTypography.priceTag.copyWith(
                            fontSize: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _noiseTolerance,
                      min: 25.0,
                      max: 55.0,
                      divisions: 30,
                      activeColor: theme.colorScheme.primary,
                      inactiveColor: theme.colorScheme.outlineVariant.withValues(
                        alpha: isDark ? 0.2 : 0.6,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _noiseTolerance = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.translate('preferred_style'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
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
                              theme.colorScheme.primary.withValues(alpha: 0.2),
                          backgroundColor: isDark
                              ? const Color(0xFF141C2B)
                              : const Color(0xFFEFECE6),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant.withValues(
                                    alpha: isDark ? 0.2 : 0.6,
                                  ),
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
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0x33FFB300),
                            const Color(0x1A141C2B),
                          ]
                        : [
                            const Color(0xFFFFF9EE),
                            Colors.white,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
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
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.support_agent_rounded,
                            color: theme.colorScheme.primary,
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
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '24/7 Dedicated Spatial & Escrow Support',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: isDark ? const Color(0xFF0B0E14) : Colors.white,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: theme.cardColor,
                              content: Text(
                                l10n.translate('hotline_call'),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF141C2B) : const Color(0xFFEFECE6)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(
                    alpha: isDark ? 0.2 : 0.6,
                  ),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF141C2B) : const Color(0xFFEFECE6)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? activeColor
                : theme.colorScheme.outlineVariant.withValues(
                    alpha: isDark ? 0.2 : 0.6,
                  ),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? activeColor : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
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
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
