import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/core/network/mock_properties_data.dart';
import 'package:nestify/features/explore_feed/data/models/property_model.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';
import 'package:nestify/features/marketplace/presentation/widgets/direct_connect_buttons.dart';
import 'package:nestify/features/property_details/presentation/views/property_details_screen.dart';

/// CategoryPropertiesScreen presents dedicated category exploration
/// for premier Egyptian real estate (شقق للبيع، شقق للإيجار، فلل للبيع، فلل للإيجار).
/// Features real-time search, compound filtering, sorting, grid/list toggle,
/// and direct WhatsApp / phone contact.
class CategoryPropertiesScreen extends StatefulWidget {
  final String categoryKey;
  final String? customTitle;

  const CategoryPropertiesScreen({
    super.key,
    required this.categoryKey,
    this.customTitle,
  });

  @override
  State<CategoryPropertiesScreen> createState() =>
      _CategoryPropertiesScreenState();
}

class _CategoryPropertiesScreenState extends State<CategoryPropertiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;
  String _selectedLocationFilter = 'all'; // 'all', 'new_cairo', 'zayed', 'new_capital'
  String _sortBy = 'default'; // 'default', 'price_asc', 'price_desc', 'ready_move'

  late List<PropertyEntity> _allCategoryProperties;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProperties() {
    final rawList = MockPropertiesData.rawProperties;
    final all = rawList.map((j) => PropertyModel.fromJson(j)).toList();

    _allCategoryProperties = all.where((p) {
      switch (widget.categoryKey) {
        case 'apartments_sale':
          return p.category == 'apartment' && p.priceType == 'buy';
        case 'apartments_rent':
          return p.category == 'apartment' && p.priceType == 'rent';
        case 'villas_sale':
          return (p.category == 'villa' || p.category == 'townhouse') &&
              p.priceType == 'buy';
        case 'villas_rent':
          return (p.category == 'villa' || p.category == 'townhouse') &&
              p.priceType == 'rent';
        case 'townhouses_sale':
          return p.category == 'townhouse' && p.priceType == 'buy';
        case 'all':
        default:
          return true;
      }
    }).toList();
  }

  List<PropertyEntity> _getFilteredProperties() {
    final query = _searchController.text.trim().toLowerCase();
    var list = _allCategoryProperties.where((p) {
      // Search query filter
      if (query.isNotEmpty) {
        final matchesTitle = p.title.toLowerCase().contains(query);
        final matchesCompound = p.compoundName.toLowerCase().contains(query);
        final matchesNeighborhood = p.neighborhood.toLowerCase().contains(query);
        final matchesDev = p.developerName.toLowerCase().contains(query);
        if (!matchesTitle && !matchesCompound && !matchesNeighborhood && !matchesDev) {
          return false;
        }
      }

      // Location filter
      if (_selectedLocationFilter != 'all') {
        final text = '${p.neighborhood} ${p.compoundName}'.toLowerCase();
        if (_selectedLocationFilter == 'new_cairo') {
          if (!text.contains('تجمع') && !text.contains('cairo') && !text.contains('مدينتي')) {
            return false;
          }
        } else if (_selectedLocationFilter == 'zayed') {
          if (!text.contains('زايد') && !text.contains('zayed') && !text.contains('أكتوبر')) {
            return false;
          }
        } else if (_selectedLocationFilter == 'new_capital') {
          if (!text.contains('العاصمة') && !text.contains('capital')) {
            return false;
          }
        }
      }

      return true;
    }).toList();

    // Sorting
    if (_sortBy == 'price_asc') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'price_desc') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'ready_move') {
      list.sort((a, b) {
        if (a.delivery == 'ready_to_move' && b.delivery != 'ready_to_move') return -1;
        if (b.delivery == 'ready_to_move' && a.delivery != 'ready_to_move') return 1;
        return 0;
      });
    }

    return list;
  }

  String _getCategoryTitle(AppLocalizations l10n) {
    if (widget.customTitle != null) return widget.customTitle!;
    switch (widget.categoryKey) {
      case 'apartments_sale':
        return l10n.isArabic ? 'شقق للبيع' : 'Apartments for Sale';
      case 'apartments_rent':
        return l10n.isArabic ? 'شقق للإيجار' : 'Apartments for Rent';
      case 'villas_sale':
        return l10n.isArabic ? 'فلل للبيع' : 'Villas for Sale';
      case 'villas_rent':
        return l10n.isArabic ? 'فلل للإيجار' : 'Villas for Rent';
      case 'townhouses_sale':
        return l10n.isArabic ? 'تاون هاوس للبيع' : 'Townhouses for Sale';
      case 'all':
      default:
        return l10n.isArabic ? 'جميع العقارات' : 'All Properties';
    }
  }

  String _getCategorySubtitle(AppLocalizations l10n) {
    switch (widget.categoryKey) {
      case 'apartments_sale':
        return l10n.isArabic
            ? 'أفضل شقق وبنتهاوس بالتجمع وزايد والعاصمة بأنظمة سداد حتى ٩ سنوات'
            : 'Premier apartments & penthouses with flexible payment plans up to 9 years';
      case 'apartments_rent':
        return l10n.isArabic
            ? 'شقق ودوبلكس مفروشة وفندقية للإيجار الشهري بأرقى المجمعات السكنية'
            : 'Luxury furnished & serviced apartments for monthly rent';
      case 'villas_sale':
        return l10n.isArabic
            ? 'فلل مستقلة وقصور راقية من كبار المطورين العقاريين بمقدمات تبدأ من ٥%'
            : 'Standalone luxury villas from top developers with down payments from 5%';
      case 'villas_rent':
        return l10n.isArabic
            ? 'فلل فاخرة بحمامات سباحة خاصة وحدائق واسعة للإيجار السكني والدبلوماسي'
            : 'Exclusive private pool villas for executive and diplomatic lease';
      default:
        return l10n.isArabic
            ? 'عقارات مختارة بعناية في أرقى كمبوندات مصر'
            : 'Curated architectural listings in premier Egyptian compounds';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final filteredList = _getFilteredProperties();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar with Back Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF141C2B).withValues(alpha: 0.95)
                              : Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : const Color(0xFFE5E0D8),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            isRtl
                                ? Icons.arrow_forward_ios_rounded
                                : Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getCategoryTitle(l10n),
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${filteredList.length} ${l10n.isArabic ? "عقار متاح الآن" : "properties available"}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Toggle Grid / List
                    IconButton(
                      onPressed: () => setState(() => _isGridView = !_isGridView),
                      icon: Icon(
                        _isGridView
                            ? Icons.view_agenda_rounded
                            : Icons.grid_view_rounded,
                        color: primaryColor,
                      ),
                      tooltip: _isGridView ? 'عرض القائمة' : 'عرض شبكي',
                    ),
                  ],
                ),
              ),
            ),

            // Subtitle Description
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  _getCategorySubtitle(l10n),
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFFE2DDD5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.isArabic
                          ? 'ابحث باسم الكمبوند، الحي أو المطور...'
                          : 'Search compound, area or developer...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: primaryColor,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Location Filter Chips Rail
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    _buildLocationChip(
                      id: 'all',
                      label: l10n.isArabic ? 'الكل' : 'All',
                      theme: theme,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildLocationChip(
                      id: 'new_cairo',
                      label: l10n.isArabic ? 'التجمع الخامس' : 'New Cairo',
                      theme: theme,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildLocationChip(
                      id: 'zayed',
                      label: l10n.isArabic ? 'الشيخ زايد' : 'Sheikh Zayed',
                      theme: theme,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildLocationChip(
                      id: 'new_capital',
                      label: l10n.isArabic ? 'العاصمة الإدارية' : 'New Capital',
                      theme: theme,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 14),
                    // Quick Sort Trigger
                    PopupMenuButton<String>(
                      initialValue: _sortBy,
                      onSelected: (val) => setState(() => _sortBy = val),
                      color: isDark ? const Color(0xFF1E2838) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'default',
                          child: Text(l10n.isArabic ? 'الترتيب الافتراضي' : 'Default'),
                        ),
                        PopupMenuItem(
                          value: 'price_asc',
                          child: Text(l10n.isArabic ? 'الأقل سعراً أولاً' : 'Price: Low to High'),
                        ),
                        PopupMenuItem(
                          value: 'price_desc',
                          child: Text(l10n.isArabic ? 'الأعلى سعراً أولاً' : 'Price: High to Low'),
                        ),
                        PopupMenuItem(
                          value: 'ready_move',
                          child: Text(l10n.isArabic ? 'استلام فوري أولاً' : 'Ready to Move First'),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: isDark ? 0.18 : 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.sort_rounded, size: 14, color: primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              l10n.isArabic ? 'ترتيب' : 'Sort',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Empty State or Property Items
            if (filteredList.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_work_outlined,
                        size: 64,
                        color: isDark ? AppColors.textMuted : const Color(0xFFCBD5E1),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.isArabic
                            ? 'لا توجد عقارات مطابقة لبحثك'
                            : 'No matching properties found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.isArabic
                            ? 'جرّب البحث بكلمة أخرى أو تعديل الموقع'
                            : 'Try adjusting your search query or location filter',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_isGridView)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final property = filteredList[index];
                      return _buildGridCard(context, property, l10n, theme, isDark);
                    },
                    childCount: filteredList.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final property = filteredList[index];
                      return _buildListCard(context, property, l10n, theme, isDark);
                    },
                    childCount: filteredList.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationChip({
    required String id,
    required String label,
    required ThemeData theme,
    required bool isDark,
  }) {
    final isSelected = _selectedLocationFilter == id;
    final primaryColor = theme.colorScheme.primary;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedLocationFilter = id);
      },
      selectedColor: primaryColor.withValues(alpha: isDark ? 0.22 : 0.16),
      backgroundColor: isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected
            ? primaryColor
            : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
      ),
      side: BorderSide(
        color: isSelected
            ? primaryColor
            : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5)),
      ),
    );
  }

  Widget _buildListCard(
    BuildContext context,
    PropertyEntity property,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    final primaryColor = theme.colorScheme.primary;
    final isForRent = property.priceType == 'rent';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PropertyDetailsScreen(property: property),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E0D8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Badges
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 190,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: property.images.isNotEmpty
                          ? property.images.first
                          : 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=800&q=80',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark ? const Color(0xFF1E2838) : const Color(0xFFF0EDE6),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? const Color(0xFF1E2838) : const Color(0xFFF0EDE6),
                        child: const Icon(Icons.home_work_rounded, size: 40),
                      ),
                    ),
                    // Gradient shadow for badge readability
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 70,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Badges Top Row
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Offering Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              property.localizedOfferingType(l10n.isArabic),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          // Cash discount or Rent badge
                          if (!isForRent && property.cashDiscountPercent > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                l10n.isArabic
                                    ? 'خصم ${property.cashDiscountPercent}% كاش'
                                    : '${property.cashDiscountPercent}% Cash Off',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          else if (isForRent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                l10n.isArabic ? 'إيجار شهري' : 'Monthly Rent',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Compound & Neighborhood
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.compoundName} • ${property.neighborhood}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    property.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isForRent
                                ? (l10n.isArabic ? 'الإيجار الشهري' : 'Monthly Rent')
                                : (l10n.isArabic ? 'السعر الإجمالي' : 'Total Price'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            property.localizedPrice(l10n.isArabic),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                            ),
                          ),
                        ],
                      ),
                      if (!isForRent && property.downPaymentPrice > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              l10n.isArabic ? 'المقدم المطلوب' : 'Down Payment',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              property.localizedDownPayment(l10n.isArabic),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Specs Row (Bedrooms, Bathrooms, Area, Finishing)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildSpecTag(
                          icon: Icons.king_bed_outlined,
                          text: '${property.bedrooms} ${l10n.isArabic ? "غرف" : "Beds"}',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 6),
                        _buildSpecTag(
                          icon: Icons.bathtub_outlined,
                          text: '${property.bathrooms} ${l10n.isArabic ? "حمام" : "Baths"}',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 6),
                        _buildSpecTag(
                          icon: Icons.straighten_rounded,
                          text: '${(property.squareFeet * 0.0929).round()} م²',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 6),
                        _buildSpecTag(
                          icon: Icons.handyman_outlined,
                          text: property.localizedFinishing(l10n.isArabic),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Direct Action Buttons (WhatsApp & Call)
                  DirectConnectButtons(property: property),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    PropertyEntity property,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PropertyDetailsScreen(property: property),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E0D8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: property.images.isNotEmpty
                      ? property.images.first
                      : 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=800&q=80',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: isDark ? const Color(0xFF1E2838) : const Color(0xFFF0EDE6),
                    child: const Icon(Icons.home_work_rounded, size: 24),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.compoundName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    property.localizedPrice(l10n.isArabic),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  DirectConnectButtons(property: property, isCompact: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecTag({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
