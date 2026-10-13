import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/core/network/mock_properties_data.dart';
import 'package:nestify/features/explore_feed/data/models/property_model.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_bloc.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_event.dart';
import 'package:nestify/features/explore_feed/presentation/views/explore_screen.dart';
import 'package:nestify/features/marketplace/presentation/widgets/direct_connect_buttons.dart';
import 'package:nestify/features/marketplace/presentation/widgets/property_comparison_sheet.dart';
import 'package:nestify/core/theme/theme_bloc/theme_bloc.dart';
import 'package:nestify/core/theme/theme_bloc/theme_event.dart';
import 'package:nestify/core/theme/theme_bloc/theme_state.dart';
import 'package:nestify/features/property_details/presentation/views/property_details_screen.dart';

/// HomeMarketplaceView is the flagship commercial real estate marketplace screen,
/// rivaling Dubizzle and Property Finder with segmented sale/rent modes,
/// compound launches, direct WhatsApp lead conversion, and side-by-side unit comparison.
class HomeMarketplaceView extends StatefulWidget {
  const HomeMarketplaceView({super.key});

  @override
  State<HomeMarketplaceView> createState() => _HomeMarketplaceViewState();
}

class _HomeMarketplaceViewState extends State<HomeMarketplaceView> {
  // Transaction Mode: 'buy' vs 'rent'
  String _transactionType = 'buy';

  // Selected Category filter
  String _selectedCategory = 'all';

  // Selected Area Hub
  String _selectedLocation = 'New Cairo';

  // Search keyword query
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Compare selection slots
  PropertyEntity? _comparePropertyA;
  PropertyEntity? _comparePropertyB;

  late List<PropertyEntity> _allProperties;

  final List<Map<String, dynamic>> _compoundLaunches = [
    {
      'title': 'Palm Hills The Crown',
      'developer': 'Palm Hills Developments',
      'tag': 'خصم كاش 30% • تسليم 2026',
      'image':
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1000&q=80',
      'downPayment': '0% مقدم',
      'tenure': 'أقساط 8 سنوات',
    },
    {
      'title': 'SODIC VYE New Zayed',
      'developer': 'SODIC Real Estate',
      'tag': 'بدون مقدم 0% • حديقة خاصة',
      'image':
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1000&q=80',
      'downPayment': '5% مقدم',
      'tenure': 'أقساط 7 سنوات',
    },
    {
      'title': 'Emaar Marina Cove Towers',
      'developer': 'Emaar Properties',
      'tag': 'عائد استثماري 13.5% مضمون',
      'image':
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1000&q=80',
      'downPayment': '10% مقدم',
      'tenure': 'أقساط 6 سنوات',
    },
  ];

  @override
  void initState() {
    super.initState();
    _allProperties = MockPropertiesData.rawProperties
        .map((json) => PropertyModel.fromJson(json))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PropertyEntity> get _filteredProperties {
    return _allProperties.where((p) {
      if (p.priceType != _transactionType) return false;
      if (_selectedCategory != 'all' && p.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matches = p.title.toLowerCase().contains(query) ||
            p.neighborhood.toLowerCase().contains(query) ||
            p.developerName.toLowerCase().contains(query);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  List<PropertyEntity> get _hotDeals {
    return _allProperties.where((p) => p.rentalYieldPct >= 11.5).toList();
  }

  void _toggleCompare(PropertyEntity property) {
    setState(() {
      if (_comparePropertyA == null) {
        _comparePropertyA = property;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceDarkElevated,
            content: Text(
              '${property.title} added to comparison. Tap compare on a 2nd unit.',
              style: const TextStyle(color: AppColors.neonCyan),
            ),
          ),
        );
      } else if (_comparePropertyA?.id == property.id) {
        _comparePropertyA = null;
      } else if (_comparePropertyB == null) {
        _comparePropertyB = property;
        PropertyComparisonSheet.show(
          context,
          propertyA: _comparePropertyA!,
          propertyB: _comparePropertyB!,
        );
      } else if (_comparePropertyB?.id == property.id) {
        _comparePropertyB = null;
      } else {
        _comparePropertyB = property;
        PropertyComparisonSheet.show(
          context,
          propertyA: _comparePropertyA!,
          propertyB: _comparePropertyB!,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final feed = _filteredProperties;
    final hotDeals = _hotDeals;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Header with Location Dropdown & Swipe Mode Switcher
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Location Dropdown
                        _buildLocationSelector(l10n),

                        // Actions: Theme Switcher Toggle + Swipe Mode
                        Row(
                          children: [
                            BlocBuilder<ThemeBloc, ThemeState>(
                              builder: (context, themeState) {
                                final isDarkTheme = themeState.isDark;
                                return GestureDetector(
                                  onTap: () {
                                    context
                                        .read<ThemeBloc>()
                                        .add(const ToggleThemeEvent());
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: theme.cardColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: primaryColor.withValues(alpha: 0.6),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isDarkTheme
                                              ? Icons.light_mode_rounded
                                              : Icons.dark_mode_rounded,
                                          size: 14,
                                          color: primaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isDarkTheme
                                              ? (l10n.isArabic ? 'فاتح' : 'Light')
                                              : (l10n.isArabic ? 'داكن' : 'Dark'),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Switch to Tinder Swipe Deck Mode
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ExploreScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isDark
                                      ? AppColors.cyanGradient
                                      : const LinearGradient(
                                          colors: [Color(0xFFC5A880), Color(0xFFD4AF37)],
                                        ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.style_rounded,
                                      size: 15,
                                      color: isDark ? AppColors.backgroundDark : Colors.white,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      l10n.translate('mode_switch_swipe'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.backgroundDark : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Global Search Bar & Interactive Filter Trigger
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.transparent
                                : const Color(0x0A0F1B2B),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.translate('search_placeholder'),
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                                    size: 18,
                                  ),
                                )
                              : Icon(
                                  Icons.tune_rounded,
                                  color: primaryColor,
                                  size: 20,
                                ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),

                // 3. For Sale vs For Rent Segmented Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDarkElevated : const Color(0xFFF0EDE6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTransactionToggle(
                              title: l10n.translate('for_sale'),
                              type: 'buy',
                            ),
                          ),
                          Expanded(
                            child: _buildTransactionToggle(
                              title: l10n.translate('for_rent'),
                              type: 'rent',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),

                // 4. Category Pills Horizontal Rail
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildCategoryPill(
                          id: 'all',
                          label: l10n.translate('cat_all'),
                          icon: Icons.dashboard_outlined,
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryPill(
                          id: 'villa',
                          label: l10n.translate('cat_villas'),
                          icon: Icons.villa_outlined,
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryPill(
                          id: 'apartment',
                          label: l10n.translate('cat_apartments'),
                          icon: Icons.apartment_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryPill(
                          id: 'townhouse',
                          label: l10n.translate('cat_townhouse'),
                          icon: Icons.holiday_village_outlined,
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryPill(
                          id: 'studio',
                          label: l10n.translate('cat_studios'),
                          icon: Icons.single_bed_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // 5. Exclusive Compound Launches Hero Banner Carousel
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          l10n.translate('exclusive_launches'),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 170,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _compoundLaunches.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            final launch = _compoundLaunches[index];
                            return _buildLaunchBanner(launch);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // 6. Hot Investment Deals Section (ROI > 11%)
                if (hotDeals.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                color: theme.colorScheme.secondary,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.translate('section_hot_deals'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            l10n.translate('view_all'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: hotDeals.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          return _buildHotDealCard(hotDeals[index], l10n);
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 26)),
                ],

                // 7. Main Properties Section (For Sale / For Rent Feed)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _transactionType == 'buy'
                              ? l10n.translate('section_for_sale')
                              : l10n.translate('section_for_rent'),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${feed.length} ${l10n.translate('properties_count')}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Properties Grid / List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final prop = feed[index];
                        final isComparing = _comparePropertyA?.id == prop.id ||
                            _comparePropertyB?.id == prop.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildCommercialPropertyCard(
                            prop,
                            l10n,
                            isComparing,
                          ),
                        );
                      },
                      childCount: feed.length,
                    ),
                  ),
                ),
              ],
            ),

            // 8. Floating Active Comparison Bar
            if (_comparePropertyA != null)
              Positioned(
                bottom: 86,
                left: 20,
                right: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryColor,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.35),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.compare_arrows_rounded,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _comparePropertyB == null
                              ? '${_comparePropertyA!.title} (1/2 selected)'
                              : 'Comparing 2 units',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_comparePropertyB != null)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          onPressed: () {
                            PropertyComparisonSheet.show(
                              context,
                              propertyA: _comparePropertyA!,
                              propertyB: _comparePropertyB!,
                            );
                          },
                          child: const Text('View Comparison'),
                        )
                      else
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _comparePropertyA = null;
                            });
                          },
                          child: Text(
                            l10n.translate('clear_compare'),
                            style: const TextStyle(color: AppColors.passRed),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelector(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return PopupMenuButton<String>(
      onSelected: (loc) {
        setState(() {
          _selectedLocation = loc;
        });
      },
      color: isDark ? AppColors.surfaceDarkElevated : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'New Cairo',
          child: Text(l10n.translate('new_cairo')),
        ),
        PopupMenuItem(
          value: 'Sheikh Zayed',
          child: Text(l10n.translate('sheikh_zayed')),
        ),
        PopupMenuItem(
          value: 'New Capital',
          child: Text(l10n.translate('new_capital')),
        ),
        PopupMenuItem(
          value: 'Riyadh',
          child: Text(l10n.translate('riyadh')),
        ),
        PopupMenuItem(
          value: 'Dubai',
          child: Text(l10n.translate('dubai')),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on_rounded,
            color: primaryColor,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            _selectedLocation,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: primaryColor,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionToggle({
    required String title,
    required String type,
  }) {
    final isSelected = _transactionType == type;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _transactionType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? (isDark ? AppColors.backgroundDark : Colors.white)
                  : (isDark ? AppColors.textMuted : const Color(0xFF64748B)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPill({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedCategory == id;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final textSecondary = isDark ? AppColors.textSecondary : const Color(0xFF64748B);

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isSelected ? primaryColor : textSecondary,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedCategory = id);
      },
      selectedColor: primaryColor.withValues(alpha: 0.18),
      backgroundColor: isDark ? AppColors.surfaceDarkElevated : const Color(0xFFF0EDE6),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? primaryColor : textSecondary,
      ),
      side: BorderSide(
        color: isSelected
            ? primaryColor
            : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E2DC)),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildLaunchBanner(Map<String, dynamic> launch) {
    return Container(
      width: 290,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(launch['image']),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.85),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.amberGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                launch['tag'],
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.backgroundDark,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 14,
            right: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  launch['developer'],
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.neonCyan,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  launch['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${launch['downPayment']} • ${launch['tenure']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotDealCard(PropertyEntity property, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
        width: 220,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.secondary.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : const Color(0x0A0F1B2B),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: CachedNetworkImage(
                    imageUrl: property.images.first,
                    height: 115,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: l10n.isArabic ? null : 8,
                  right: l10n.isArabic ? 8 : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      l10n.isArabic
                          ? 'عائد سنوي ${AppLocalizations.convertToArabicDigits(property.rentalYieldPct)}%'
                          : '${property.rentalYieldPct}% Annual ROI',
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.localizedPrice(l10n.isArabic),
                    style: AppTypography.priceTag.copyWith(
                      fontSize: 16,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.developerName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
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
    );
  }

  Widget _buildCommercialPropertyCard(
    PropertyEntity property,
    AppLocalizations l10n,
    bool isComparing,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isComparing
                ? primaryColor
                : theme.colorScheme.outlineVariant,
            width: isComparing ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : const Color(0x0A0F1B2B),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Hero Photo
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  child: CachedNetworkImage(
                    imageUrl: property.images.first,
                    height: 190,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // 100% Verified Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.backgroundDark.withValues(alpha: 0.8)
                          : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 13,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.translate('verified_100'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 360 Virtual Tour tag
                if (property.hasVirtualTour360)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.view_in_ar_rounded,
                            size: 13,
                            color: isDark ? AppColors.backgroundDark : Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '360° VR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.backgroundDark : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Favorite Heart Button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      context
                          .read<ExploreFeedBloc>()
                          .add(SwipeRightEvent(property));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: isDark
                              ? AppColors.surfaceDarkElevated
                              : const Color(0xFF0F1B2B),
                          content: Text(
                            l10n.translate('saved_to_portfolio'),
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.backgroundDark.withValues(alpha: 0.75)
                            : Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? Colors.white24
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        color: primaryColor,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Body Information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Developer Name & Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        property.developerName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFF0EDE6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          property.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textSecondary
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    property.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Neighborhood
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.neighborhood,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Commercial Price & Payment Plan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        property.formattedPrice,
                        style: AppTypography.priceTag.copyWith(
                          fontSize: 22,
                          color: primaryColor,
                        ),
                      ),
                      if (property.priceType == 'buy') ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${l10n.translate('down_payment')}: ${property.formattedDownPayment}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            Text(
                              '${l10n.translate('monthly_installment')}: ${property.formattedMonthlyInstallment}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.textSecondary
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            property.isFurnished
                                ? l10n.translate('furnished')
                                : l10n.translate('unfurnished'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Micro-Specs Pill Row
                  Row(
                    children: [
                      _buildSpecPill(
                        Icons.bed_outlined,
                        '${property.bedrooms} ${l10n.translate('beds')}',
                      ),
                      const SizedBox(width: 6),
                      _buildSpecPill(
                        Icons.bathtub_outlined,
                        '${property.bathrooms} ${l10n.translate('baths')}',
                      ),
                      const SizedBox(width: 6),
                      _buildSpecPill(
                        Icons.square_foot_rounded,
                        '${property.areaSqm} ${l10n.translate('sqm')}',
                      ),
                      const Spacer(),
                      // Compare Toggle Button
                      GestureDetector(
                        onTap: () => _toggleCompare(property),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isComparing
                                ? primaryColor
                                : (isDark
                                    ? AppColors.surfaceDarkElevated
                                    : const Color(0xFFF4F0E8)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isComparing
                                  ? primaryColor
                                  : (isDark
                                      ? Colors.white24
                                      : theme.colorScheme.outlineVariant),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.compare_arrows_rounded,
                                size: 13,
                                color: isComparing
                                    ? (isDark
                                        ? AppColors.backgroundDark
                                        : Colors.white)
                                    : primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.translate('select_to_compare'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isComparing
                                      ? (isDark
                                          ? AppColors.backgroundDark
                                          : Colors.white)
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Direct Connect Actions (WhatsApp & Call)
                  DirectConnectButtons(property: property),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecPill(IconData icon, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkElevated : const Color(0xFFF4F0E8),
        borderRadius: BorderRadius.circular(10),
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
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
