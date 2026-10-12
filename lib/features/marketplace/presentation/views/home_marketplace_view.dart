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

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
                              gradient: AppColors.cyanGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.neonCyan.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.style_rounded,
                                  size: 15,
                                  color: AppColors.backgroundDark,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  l10n.translate('mode_switch_swipe'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.backgroundDark,
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

                // 2. Global Search Bar & Interactive Filter Trigger
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDarkCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.translate('search_placeholder'),
                          hintStyle: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.neonCyan,
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
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    color: AppColors.textMuted,
                                    size: 18,
                                  ),
                                )
                              : const Icon(
                                  Icons.tune_rounded,
                                  color: AppColors.neonCyan,
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
                        color: AppColors.surfaceDarkElevated,
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
                          style: AppTypography.headlineMedium,
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
                              const Icon(
                                Icons.local_fire_department_rounded,
                                color: AppColors.sunsetOrange,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.translate('section_hot_deals'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            l10n.translate('view_all'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neonCyan,
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
                          style: AppTypography.headlineMedium,
                        ),
                        Text(
                          '${feed.length} ${l10n.translate('properties_count')}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Properties Grid / List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
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
                    color: AppColors.surfaceDark.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.neonCyan,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonCyan.withValues(alpha: 0.35),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.compare_arrows_rounded,
                        color: AppColors.neonCyan,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _comparePropertyB == null
                              ? '${_comparePropertyA!.title} (1/2 selected)'
                              : 'Comparing 2 units',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
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
    return PopupMenuButton<String>(
      onSelected: (loc) {
        setState(() {
          _selectedLocation = loc;
        });
      },
      color: AppColors.surfaceDarkElevated,
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
          const Icon(
            Icons.location_on_rounded,
            color: AppColors.neonCyan,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            _selectedLocation,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.neonCyan,
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
          color: isSelected ? AppColors.neonCyan : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isSelected ? AppColors.backgroundDark : AppColors.textMuted,
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
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isSelected ? AppColors.neonCyan : AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedCategory = id);
      },
      selectedColor: AppColors.neonCyan.withValues(alpha: 0.18),
      backgroundColor: AppColors.surfaceDarkElevated,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? AppColors.neonCyan : AppColors.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.neonCyan : Colors.white.withValues(alpha: 0.08),
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
          color: AppColors.surfaceDarkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.sunsetOrange.withValues(alpha: 0.35),
            width: 1.2,
          ),
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
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.sunsetOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${property.rentalYieldPct}% ROI',
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
                    property.formattedPrice,
                    style: AppTypography.priceTag.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    property.developerName,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.neonCyan,
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
          color: AppColors.surfaceDarkCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isComparing
                ? AppColors.neonCyan
                : AppColors.borderLight,
            width: isComparing ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
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
                      color: AppColors.backgroundDark.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.neonCyan.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 13,
                          color: AppColors.neonCyan,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.translate('verified_100'),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
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
                        color: AppColors.amberGold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.view_in_ar_rounded,
                            size: 13,
                            color: AppColors.backgroundDark,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '360° VR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.backgroundDark,
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
                          backgroundColor: AppColors.surfaceDarkElevated,
                          content: Text(
                            l10n.translate('saved_to_portfolio'),
                            style: const TextStyle(color: AppColors.neonCyan),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark.withValues(alpha: 0.75),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.neonCyan,
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
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neonCyan,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          property.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Neighborhood
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.neighborhood,
                          style: AppTypography.bodySmall,
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
                        style: AppTypography.priceTag.copyWith(fontSize: 22),
                      ),
                      if (property.priceType == 'buy') ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${l10n.translate('down_payment')}: ${property.formattedDownPayment}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.amberGold,
                              ),
                            ),
                            Text(
                              '${l10n.translate('monthly_installment')}: ${property.formattedMonthlyInstallment}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
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
                            color: const Color(0xFF69F0AE).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            property.isFurnished
                                ? l10n.translate('furnished')
                                : l10n.translate('unfurnished'),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF69F0AE),
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
                                ? AppColors.neonCyan
                                : AppColors.surfaceDarkElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isComparing
                                  ? AppColors.neonCyan
                                  : Colors.white24,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.compare_arrows_rounded,
                                size: 13,
                                color: isComparing
                                    ? AppColors.backgroundDark
                                    : AppColors.neonCyan,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.translate('select_to_compare'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isComparing
                                      ? AppColors.backgroundDark
                                      : AppColors.textPrimary,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkElevated,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
