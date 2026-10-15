import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import '../../data/mock_compounds_data.dart';
import '../../domain/entities/compound_entity.dart';
import 'compound_details_screen.dart';

/// AllCompoundsScreen displays the complete portfolio of off-plan and new compound
/// projects in Egypt with city filtering and full Nordic light theme support.
class AllCompoundsScreen extends StatefulWidget {
  const AllCompoundsScreen({super.key});

  @override
  State<AllCompoundsScreen> createState() => _AllCompoundsScreenState();
}

class _AllCompoundsScreenState extends State<AllCompoundsScreen> {
  String _selectedCity = 'all';

  List<CompoundEntity> get _filteredCompounds {
    if (_selectedCity == 'all') return MockCompoundsData.compounds;
    if (_selectedCity == 'zayed') {
      return MockCompoundsData.compounds
          .where((c) => c.locationAr.contains('زايد'))
          .toList();
    }
    if (_selectedCity == 'new_cairo') {
      return MockCompoundsData.compounds
          .where((c) => c.locationAr.contains('القاهرة الجديدة') || c.locationAr.contains('التجمع'))
          .toList();
    }
    if (_selectedCity == 'october') {
      return MockCompoundsData.compounds
          .where((c) => c.locationAr.contains('أكتوبر'))
          .toList();
    }
    if (_selectedCity == 'capital') {
      return MockCompoundsData.compounds
          .where((c) => c.locationAr.contains('العاصمة الإدارية'))
          .toList();
    }
    return MockCompoundsData.compounds;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isArabic = l10n.isArabic;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios_rounded
                : Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isArabic ? 'كمبوندات جديدة ومشروعات تحت الإنشاء' : 'Off-Plan & New Compounds',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // City Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _buildCityChip('all', isArabic ? 'جميع المناطق' : 'All Areas', primaryColor, isDark),
                const SizedBox(width: 8),
                _buildCityChip('new_cairo', isArabic ? 'التجمع الخامس' : 'New Cairo', primaryColor, isDark),
                const SizedBox(width: 8),
                _buildCityChip('zayed', isArabic ? 'الشيخ زايد' : 'Sheikh Zayed', primaryColor, isDark),
                const SizedBox(width: 8),
                _buildCityChip('october', isArabic ? 'مدينة 6 أكتوبر' : '6th of October', primaryColor, isDark),
                const SizedBox(width: 8),
                _buildCityChip('capital', isArabic ? 'العاصمة الإدارية' : 'New Capital', primaryColor, isDark),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Compounds List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              physics: const BouncingScrollPhysics(),
              itemCount: _filteredCompounds.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (ctx, idx) {
                final compound = _filteredCompounds[idx];
                return _buildCompoundListCard(compound, isArabic, theme, isDark, primaryColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityChip(String cityKey, String label, Color primaryColor, bool isDark) {
    final isSelected = _selectedCity == cityKey;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF0F1B2B)),
        ),
      ),
      selected: isSelected,
      selectedColor: primaryColor,
      backgroundColor: isDark ? const Color(0xFF1E2838) : const Color(0xFFF1F5F9),
      onSelected: (_) => setState(() => _selectedCity = cityKey),
    );
  }

  Widget _buildCompoundListCard(
    CompoundEntity compound,
    bool isArabic,
    ThemeData theme,
    bool isDark,
    Color primaryColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CompoundDetailsScreen(compound: compound),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141C2B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E0D8),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0x0A0F1B2B),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with delivery badge & cash discount
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: CachedNetworkImage(
                    imageUrl: compound.coverImage,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: isArabic ? 12 : null,
                  left: isArabic ? null : 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.amberGold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      compound.localizedDelivery(isArabic),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: isArabic ? 12 : null,
                  right: isArabic ? null : 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${compound.cashDiscountPercent}% ${isArabic ? "خصم كاش" : "Cash Off"}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Developer row
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: compound.developerLogo,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => const Icon(Icons.business_rounded, size: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          compound.developerName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Compound Title
                  Text(
                    compound.localizedName(isArabic),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: primaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          compound.localizedLocation(isArabic),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Unit types pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2838) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      compound.unitTypesSummary(isArabic),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Payment Plan & Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          compound.localizedPaymentPlan(isArabic),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isArabic ? 'الأسعار تبدأ من' : 'Starting From',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: isDark ? AppColors.textSecondary : const Color(0xFF94A3B8),
                            ),
                          ),
                          Text(
                            compound.formattedStartingPrice(isArabic),
                            style: AppTypography.priceTag.copyWith(
                              fontSize: 15.5,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
