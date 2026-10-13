import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_bloc.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_state.dart';
import 'package:nestify/features/property_details/presentation/views/property_details_screen.dart';

/// PortfolioView provides a luxury wealth vault of favorited architecture
/// and scheduled VIP private & spatial VR tours with countdown trackers.
class PortfolioView extends StatefulWidget {
  const PortfolioView({super.key});

  @override
  State<PortfolioView> createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = false;

  // Mock scheduled tours list with real-time countdown data
  final List<Map<String, dynamic>> _mockTours = [
    {
      'id': 'tour_1',
      'title': 'The Obsidian Zenith Penthouse',
      'neighborhood': 'Shibuya Sky Corridor, Neo-Tokyo',
      'image':
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=800&q=80',
      'date': 'Oct 15, 2026',
      'time': '11:00 AM',
      'daysLeft': 2,
      'isVr': false,
      'chauffeur': true,
      'advisor': 'Kenji Takahashi (Spatial Architect)',
    },
    {
      'id': 'tour_2',
      'title': 'Kreuzberg Bauhaus Concrete Loft',
      'neighborhood': 'Paul-Lincke-Ufer, Berlin',
      'image':
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80',
      'date': 'Oct 19, 2026',
      'time': '05:30 PM (Sunset)',
      'daysLeft': 6,
      'isVr': true,
      'chauffeur': false,
      'advisor': 'Astrid Lindqvist (Spatial Advisor)',
    },
  ];

  // Monetization Listing Packages state
  String _activePlanId = 'starter';
  String _selectedPackageId = 'featured';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header & Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.translate('saved_portfolio'),
                        style: AppTypography.headlineLarge.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        l10n.translate('membership_tier'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                    icon: Icon(
                      _isGridView
                          ? Icons.view_list_rounded
                          : Icons.grid_view_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar with 3 Segments: Saved, Tours, Listing Packages
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF141C2B)
                    : const Color(0xFFEFECE6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: isDark ? 0.2 : 0.6,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: isDark ? const Color(0xFF0B0E14) : Colors.white,
                unselectedLabelColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                tabs: [
                  Tab(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(l10n.translate('tab_saved')),
                    ),
                  ),
                  Tab(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(l10n.translate('tab_tours')),
                    ),
                  ),
                  Tab(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(l10n.translate('tab_packages')),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Saved Properties from Feed Bloc
                  BlocBuilder<ExploreFeedBloc, ExploreFeedState>(
                    builder: (context, state) {
                      final saved = state.savedProperties;
                      if (saved.isEmpty) {
                        return _buildEmptyState(
                          icon: Icons.favorite_border_rounded,
                          title: l10n.translate('no_saved_properties'),
                          subtitle: l10n.translate('no_saved_desc'),
                        );
                      }
                      return _isGridView
                          ? _buildSavedGrid(saved, l10n)
                          : _buildSavedList(saved, l10n);
                    },
                  ),

                  // Tab 2: Scheduled Tours
                  _buildScheduledToursList(l10n),

                  // Tab 3: Monetization Listing Packages Hub
                  _buildListingPackagesView(l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedList(List<PropertyEntity> saved, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      itemCount: saved.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final prop = saved[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PropertyDetailsScreen(property: prop),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.2 : 0.6,
                ),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: prop.images.first,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.isArabic ? prop.localizedPrice(true) : prop.formattedPrice,
                        style: AppTypography.priceTag.copyWith(
                          fontSize: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              prop.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              prop.neighborhood,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedGrid(List<PropertyEntity> saved, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.76,
      ),
      itemCount: saved.length,
      itemBuilder: (context, index) {
        final prop = saved[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PropertyDetailsScreen(property: prop),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(
                  alpha: isDark ? 0.2 : 0.6,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: CachedNetworkImage(
                    imageUrl: prop.images.first,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.isArabic ? prop.localizedPrice(true) : prop.formattedPrice,
                        style: AppTypography.priceTag.copyWith(
                          fontSize: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              prop.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              prop.neighborhood,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScheduledToursList(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      itemCount: _mockTours.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final tour = _mockTours[index];
        final isVr = tour['isVr'] as bool;
        final hasChauffeur = tour['chauffeur'] as bool;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Countdown Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${l10n.translate('tour_in')} ${tour['daysLeft']} ${l10n.translate('days')}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isVr ? 'SPATIAL VR TOUR' : 'IN-PERSON VIP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title & Date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tour['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tour['neighborhood'],
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Service details
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF141C2B)
                      : const Color(0xFFF7F5F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: isDark ? 0.2 : 0.6,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${tour['date']} @ ${tour['time']}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    if (hasChauffeur) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.directions_car_filled_rounded,
                            size: 14,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.translate('chauffeur_assigned'),
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tour rescheduling concierge active. Contacting advisor...',
                            ),
                          ),
                        );
                      },
                      child: Text(l10n.translate('reschedule')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _mockTours.removeAt(index);
                      });
                    },
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.passRed,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Tab 3: Property Listing Packages & Monetization Hub
  // --------------------------------------------------------------------------
  Widget _buildListingPackagesView(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        // Intro & Current Active Plan Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.cardColor,
                isDark ? const Color(0xFF141C2B) : const Color(0xFFF3EFE8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('packages_title'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.translate('packages_subtitle'),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Package 1: باقة الانطلاق (Starter Launch - 0 EGP)
        _buildPackageCard(
          id: 'starter',
          title: l10n.translate('pkg_starter_title'),
          price: l10n.translate('pkg_starter_price'),
          badge: l10n.translate('pkg_starter_badge'),
          isPopular: false,
          accentColor: theme.colorScheme.secondary,
          features: [
            l10n.translate('pkg_starter_f1'),
            l10n.translate('pkg_starter_f2'),
          ],
          l10n: l10n,
        ),
        const SizedBox(height: 14),

        // Package 2: الباقة المميزة (Featured Plan - 750 EGP/mo)
        _buildPackageCard(
          id: 'featured',
          title: l10n.translate('pkg_featured_title'),
          price: l10n.translate('pkg_featured_price'),
          badge: l10n.translate('pkg_featured_badge'),
          isPopular: true,
          accentColor: theme.colorScheme.primary,
          features: [
            l10n.translate('pkg_featured_f1'),
            l10n.translate('pkg_featured_f2'),
            l10n.translate('pkg_featured_f3'),
            l10n.translate('pkg_featured_f4'),
          ],
          l10n: l10n,
        ),
        const SizedBox(height: 14),

        // Package 3: باقة الشركات والوسطاء (Broker Pro - 2,500 EGP/mo)
        _buildPackageCard(
          id: 'broker',
          title: l10n.translate('pkg_broker_title'),
          price: l10n.translate('pkg_broker_price'),
          badge: l10n.translate('pkg_broker_badge'),
          isPopular: false,
          accentColor: theme.colorScheme.primary,
          features: [
            l10n.translate('pkg_broker_f1'),
            l10n.translate('pkg_broker_f2'),
            l10n.translate('pkg_broker_f3'),
            l10n.translate('pkg_broker_f4'),
          ],
          l10n: l10n,
        ),
        const SizedBox(height: 20),

        // Upgrade Action Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              _showUpgradeConfirmationSheet(context, _selectedPackageId, l10n);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: isDark ? const Color(0xFF0B0E14) : Colors.white,
              elevation: 4,
              shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bolt_rounded,
                  size: 20,
                  color: isDark ? const Color(0xFF0B0E14) : Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _activePlanId == _selectedPackageId
                      ? l10n.translate('active_plan')
                      : l10n.translate('upgrade_package_now'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF0B0E14) : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard({
    required String id,
    required String title,
    required String price,
    required String badge,
    required bool isPopular,
    required Color accentColor,
    required List<String> features,
    required AppLocalizations l10n,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedPackageId == id;
    final isActive = _activePlanId == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackageId = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isPopular
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : theme.colorScheme.outlineVariant.withValues(
                        alpha: isDark ? 0.2 : 0.6,
                      )),
            width: isSelected || isPopular ? 1.8 : 1.0,
          ),
          boxShadow: isPopular || isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title, Badge, Selected Radio
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isPopular
                              ? Icons.star_rounded
                              : (id == 'starter'
                                  ? Icons.rocket_launch_outlined
                                  : Icons.business_center_rounded),
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFF0B0E14) : Colors.white,
                      ),
                    ),
                  )
                else if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.secondary,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      l10n.translate('active_plan'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Price Row - FittedBox to prevent any text truncation
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                price,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isPopular
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(
                alpha: isDark ? 0.2 : 0.6,
              ),
            ),
            const SizedBox(height: 12),

            // Features Checkmarks
            ...features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 15,
                      color: isPopular
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showUpgradeConfirmationSheet(
    BuildContext context,
    String packageId,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final title = packageId == 'starter'
        ? l10n.translate('pkg_starter_title')
        : (packageId == 'featured'
            ? l10n.translate('pkg_featured_title')
            : l10n.translate('pkg_broker_title'));

    final price = packageId == 'starter'
        ? l10n.translate('pkg_starter_price')
        : (packageId == 'featured'
            ? l10n.translate('pkg_featured_price')
            : l10n.translate('pkg_broker_price'));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 36,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.translate('confirm_upgrade'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: isDark ? 0.2 : 0.6,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.translate('current_active_plan'),
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 20,
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: isDark ? 0.2 : 0.6,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.security_rounded,
                          size: 16,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.isArabic
                                ? 'الدفع يتم بالجنيه المصري (EGP) عبر بوابة الدفع الآمنة'
                                : 'Billed in Egyptian Pounds (EGP) via encrypted gateway',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    setState(() {
                      _activePlanId = packageId;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: theme.cardColor,
                        content: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.translate('package_upgraded_success'),
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: isDark ? const Color(0xFF0B0E14) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.translate('confirm_upgrade'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFF0B0E14) : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
