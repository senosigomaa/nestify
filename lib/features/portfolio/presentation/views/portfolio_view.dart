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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
                        style: AppTypography.headlineLarge,
                      ),
                      Text(
                        l10n.translate('membership_tier'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.amberGold,
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
                      color: AppColors.neonCyan,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDarkElevated,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: AppColors.neonCyan,
                  borderRadius: BorderRadius.circular(14),
                ),
                labelColor: AppColors.backgroundDark,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                tabs: [
                  Tab(text: l10n.translate('tab_saved')),
                  Tab(text: l10n.translate('tab_tours')),
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
                          ? _buildSavedGrid(saved)
                          : _buildSavedList(saved);
                    },
                  ),

                  // Tab 2: Scheduled Tours
                  _buildScheduledToursList(l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedList(List<PropertyEntity> saved) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
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
              color: AppColors.surfaceDarkCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
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
                        prop.formattedPrice,
                        style: AppTypography.priceTag.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prop.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prop.neighborhood,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.neonCyan,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedGrid(List<PropertyEntity> saved) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
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
              color: AppColors.surfaceDarkCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
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
                        prop.formattedPrice,
                        style: AppTypography.priceTag.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prop.title,
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
                        prop.neighborhood,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
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
      },
    );
  }

  Widget _buildScheduledToursList(AppLocalizations l10n) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: _mockTours.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final tour = _mockTours[index];
        final isVr = tour['isVr'] as bool;
        final hasChauffeur = tour['chauffeur'] as bool;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceDarkCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.3),
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
                      color: AppColors.neonCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${l10n.translate('tour_in')} ${tour['daysLeft']} ${l10n.translate('days')}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.amberGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isVr ? 'SPATIAL VR TOUR' : 'IN-PERSON VIP',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.amberGold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title & Date
              Text(
                tour['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tour['neighborhood'],
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Service details
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDarkElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.neonCyan,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${tour['date']} @ ${tour['time']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (hasChauffeur) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_car_filled_rounded,
                            size: 14,
                            color: Color(0xFF69F0AE),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.translate('chauffeur_assigned'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF69F0AE),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
