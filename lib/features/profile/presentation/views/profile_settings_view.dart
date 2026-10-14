import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/core/localization/locale_bloc/locale_bloc.dart';
import 'package:nestify/core/localization/locale_bloc/locale_event.dart';
import 'package:nestify/core/localization/locale_bloc/locale_state.dart';
import 'package:nestify/core/theme/theme_bloc/theme_bloc.dart';
import 'package:nestify/core/theme/theme_bloc/theme_event.dart';
import 'package:nestify/core/theme/theme_bloc/theme_state.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_bloc.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_state.dart';
import 'package:nestify/features/marketplace/presentation/views/add_property_listing_screen.dart';
import 'package:nestify/features/portfolio/presentation/views/portfolio_view.dart';

/// ProfileSettingsView delivers an executive, investor-grade profile hub tailored
/// for the Egyptian real estate market. Free of theoretical clutter, featuring:
/// 1. Verified investor & broker profile credentials (+201206667376).
/// 2. Prominent reactive Saved Properties card navigating to Favorites/Portfolio.
/// 3. My Published Listings manager with view statistics & quick listing CTA.
/// 4. Nordic Light / Obsidian Dark theme switch & Arabic / English language toggle.
/// 5. Direct Phone Hotline & WhatsApp technical customer support.
/// 6. Official Terms of Service & Privacy Policy dialogues.
class ProfileSettingsView extends StatelessWidget {
  const ProfileSettingsView({super.key});

  static const String supportPhone = '+201206667376';

  Future<void> _launchCall(BuildContext context) async {
    final uri = Uri.parse('tel:$supportPhone');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showToast(context, 'رقم الدعم الفني: $supportPhone');
      }
    } catch (_) {
      if (context.mounted) {
        _showToast(context, 'رقم الدعم الفني: $supportPhone');
      }
    }
  }

  Future<void> _launchWhatsApp(BuildContext context, bool isArabic) async {
    final text = isArabic
        ? 'مرحباً، أحتاج للمساعدة والدعم الفني في تطبيق Nestify العقاري.'
        : 'Hello, I need customer support regarding Nestify Real Estate app.';
    final cleanPhone = supportPhone.replaceAll('+', '').replaceAll(' ', '');
    final uri = Uri.parse(
        'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(text)}');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showToast(context, 'واتساب الدعم الفني: $supportPhone');
      }
    } catch (_) {
      if (context.mounted) {
        _showToast(context, 'واتساب الدعم الفني: $supportPhone');
      }
    }
  }

  void _showToast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F1B2B),
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'حسناً / إغلاق',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.translate('profile_title'),
                    style: AppTypography.headlineLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_rounded, color: primaryColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          l10n.isArabic ? 'حساب موثق' : 'Verified',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. VIP Broker / Investor Identity Card
              _buildIdentityCard(context, l10n, theme, isDark, primaryColor),
              const SizedBox(height: 18),

              // 3. PROMINENT "عقاراتي المفضلة" (SAVED PROPERTIES) LUXURY CARD
              _buildSavedPropertiesCard(context, l10n, theme, isDark, primaryColor),
              const SizedBox(height: 18),

              // 4. "إعلاناتي المنشورة" (MY PUBLISHED LISTINGS) CARD
              _buildMyListingsCard(context, l10n, theme, isDark, primaryColor),
              const SizedBox(height: 18),

              // 5. Dual-Theme Toggle Card (Nordic Light / Obsidian Dark)
              _buildThemeCard(context, l10n, theme, isDark, primaryColor),
              const SizedBox(height: 18),

              // 6. Language Selection Card (Arabic / English)
              _buildLanguageCard(context, l10n, theme, isDark, primaryColor),
              const SizedBox(height: 18),

              // 7. Customer Support & Hotline Actions (Call & WhatsApp)
              _buildSupportSection(context, l10n, theme, isDark, primaryColor),
              const SizedBox(height: 18),

              // 8. Terms & Privacy Policy Links
              _buildLegalSection(context, l10n, theme, isDark, primaryColor),
              const SizedBox(height: 24),

              // App Version Footer
              Center(
                child: Text(
                  'Nestify Egypt Real Estate Super-App • v2.4.0 (Cairo Edition)',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildIdentityCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0x120F1B2B),
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const Icon(
                      Icons.person_rounded,
                      size: 32,
                    ),
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
                          l10n.isArabic ? 'ساري المنصور' : 'Sari Al-Mansoor',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.verified_rounded,
                          size: 17,
                          color: primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      supportPhone,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.8)
                            : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.isArabic
                                ? 'وسيط معتمد • القاهرة والجيزة'
                                : 'Certified Broker • Cairo/Giza',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(
            height: 26,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE5E0D8),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat(
                label: l10n.isArabic ? 'إعلاناتي النشطة' : 'Active Listings',
                value: l10n.isArabic ? '٣ عقارات' : '3 Units',
                isDark: isDark,
              ),
              _buildMiniStat(
                label: l10n.isArabic ? 'إجمالي المشاهدات' : 'Total Views',
                value: l10n.isArabic ? '٢,٨٤٠' : '2,840',
                isDark: isDark,
              ),
              _buildMiniStat(
                label: l10n.isArabic ? 'فئة العضوية' : 'VIP Tier',
                value: l10n.isArabic ? 'مستثمر بريميوم' : 'VIP Investor',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // --- 3. PROMINENT SAVED PROPERTIES LUXURY CARD ---

  Widget _buildSavedPropertiesCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
    Color primaryColor,
  ) {
    return BlocBuilder<ExploreFeedBloc, ExploreFeedState>(
      builder: (context, feedState) {
        final savedCount = feedState.savedProperties.length;
        final countText = l10n.isArabic
            ? '$savedCount عقارات محفوظة ومتابعة للأسعار'
            : '$savedCount Properties Saved in Vault';

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PortfolioView(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF2C1523),
                        const Color(0xFF1E1724),
                      ]
                    : [
                        const Color(0xFFFFF1F2),
                        Colors.white,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE11D48).withValues(alpha: isDark ? 0.45 : 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE11D48).withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                    border: Border.all(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFE11D48),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('my_saved_properties'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        countText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFFDA4AF)
                              : const Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 4. MY PUBLISHED LISTINGS CARD ---

  Widget _buildMyListingsCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFE5E0D8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.domain_add_rounded,
                    color: primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.translate('my_published_listings'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddPropertyListingScreen(),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded,
                          size: 14,
                          color: isDark
                              ? const Color(0xFF0B0E14)
                              : Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        l10n.isArabic ? 'إعلان جديد' : 'New Ad',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? const Color(0xFF0B0E14)
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.isArabic
                ? 'إدارة إعلاناتك المعروضة في التجمع والشيخ زايد والعاصمة، ومتابعة رسائل المشترين.'
                : 'Manage your active properties in New Cairo, Zayed, and New Capital.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),

          // Sample Published Listing Tile
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2838) : const Color(0xFFFBF9F5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE2DDD5),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=300&q=80',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.isArabic
                            ? 'شقة فاخرة بماونتن فيو إي سيتي'
                            : 'Luxury Apartment in Mountain View iCity',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '٨,٥٠٠,٠٠٠ ج.م • نشط ومميز',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '١,٤٢٠ مشاهدة',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. THEME SELECTION CARD ---

  Widget _buildThemeCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFE5E0D8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.translate('theme_setting'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
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
                    child: _buildSelectableOption(
                      title: l10n.translate('theme_nordic_light'),
                      subtitle: l10n.isArabic ? 'عاجي ناعم وأبيض' : 'Ivory & Crisp White',
                      icon: Icons.light_mode_rounded,
                      isSelected: !isThemeDark,
                      activeColor: const Color(0xFFC5A880),
                      onTap: () {
                        context
                            .read<ThemeBloc>()
                            .add(const SetThemeEvent(ThemeMode.light));
                      },
                      isDark: isDark,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSelectableOption(
                      title: l10n.translate('theme_obsidian_dark'),
                      subtitle: l10n.isArabic ? 'أوبسيديان فاخر' : 'Obsidian Luxury',
                      icon: Icons.dark_mode_rounded,
                      isSelected: isThemeDark,
                      activeColor: const Color(0xFF00F5D4),
                      onTap: () {
                        context
                            .read<ThemeBloc>()
                            .add(const SetThemeEvent(ThemeMode.dark));
                      },
                      isDark: isDark,
                      theme: theme,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 6. LANGUAGE SELECTION CARD ---

  Widget _buildLanguageCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFE5E0D8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.translate_rounded,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.translate('language_setting'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
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
                    child: _buildSelectableOption(
                      title: 'العربية',
                      subtitle: 'اللغة الافتراضية (RTL)',
                      icon: Icons.language_rounded,
                      isSelected: isArabic,
                      activeColor: primaryColor,
                      onTap: () {
                        context
                            .read<LocaleBloc>()
                            .add(const SetLocaleEvent(Locale('ar')));
                      },
                      isDark: isDark,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSelectableOption(
                      title: 'English',
                      subtitle: 'English (US - LTR)',
                      icon: Icons.language_rounded,
                      isSelected: !isArabic,
                      activeColor: primaryColor,
                      onTap: () {
                        context
                            .read<LocaleBloc>()
                            .add(const SetLocaleEvent(Locale('en')));
                      },
                      isDark: isDark,
                      theme: theme,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 7. CUSTOMER SUPPORT & HOTLINE ---

  Widget _buildSupportSection(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFE5E0D8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.support_agent_rounded,
                color: primaryColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.translate('contact_support'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.isArabic
                ? 'فريق خدمة عملاء ومستشاري Nestify متاحون على مدار الساعة للمعاينة والاستشارات.'
                : 'Dedicated customer advisors available 24/7 for tours and inquiries.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor:
                        isDark ? const Color(0xFF0B0E14) : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _launchCall(context),
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                  label: Text(
                    l10n.isArabic ? 'اتصال مباشر' : 'Call Support',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _launchWhatsApp(context, l10n.isArabic),
                  icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                  label: Text(
                    l10n.isArabic ? 'محادثة واتساب' : 'WhatsApp',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 8. LEGAL & PRIVACY SECTION ---

  Widget _buildLegalSection(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE5E0D8),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.description_outlined,
                color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                size: 20),
            title: Text(
              l10n.isArabic
                  ? 'الشروط والأحكام العامة للوساطة العقارية'
                  : 'Terms & Conditions',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            trailing: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: 13,
              color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
            ),
            onTap: () {
              _showLegalDialog(
                context,
                l10n.isArabic
                    ? 'الشروط والأحكام العامة للوساطة العقارية'
                    : 'Terms of Service',
                l10n.isArabic
                    ? 'جميع العقارات والأسعار المعروضة على منصة Nestify تخضع للمعاينة والتأكد من سندات الملكية والموافقات التنظيمية في جمهورية مصر العربية. الرسوم والعمولات تحكمها القوانين المنظمة للهيئة العامة للرقابة المالية.'
                    : 'All properties listed on Nestify are subject to official verification, title deeds, and regulatory approvals in the Arab Republic of Egypt.',
              );
            },
          ),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE5E0D8),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined,
                color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                size: 20),
            title: Text(
              l10n.translate('privacy_policy'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            trailing: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: 13,
              color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
            ),
            onTap: () {
              _showLegalDialog(
                context,
                l10n.translate('privacy_policy'),
                l10n.isArabic
                    ? 'تلتزم Nestify بحماية سرية وخصوصية بيانات المستثمرين وأرقام هواتفهم. لا يتم مشاركة بيانات الاتصال إلا مع المطورين العقاريين المعتمدين عند طلب المعاينة المباشرة.'
                    : 'Nestify is committed to investor data privacy. Contact information is securely transmitted only to verified developers upon tour booking.',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
    required bool isDark,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isDark ? const Color(0xFF1E2838) : const Color(0xFFFBF9F5)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE5E0D8)),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? activeColor
                      : (isDark
                          ? AppColors.textSecondary
                          : const Color(0xFF64748B)),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: activeColor,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFF0F1B2B))
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
