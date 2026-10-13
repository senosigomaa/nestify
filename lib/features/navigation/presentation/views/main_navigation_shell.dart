import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/features/co_living/presentation/views/co_invest_roommate_hub_view.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_bloc.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_state.dart';
import 'package:nestify/features/map_hub/presentation/views/interactive_map_hub_view.dart';
import 'package:nestify/features/marketplace/presentation/views/home_marketplace_view.dart';
import 'package:nestify/features/portfolio/presentation/views/portfolio_view.dart';
import 'package:nestify/features/profile/presentation/views/profile_settings_view.dart';

/// MainNavigationShell provides the persistent glassmorphic navigation shell
/// uniting Marketplace, Interactive Map, Co-Invest Hub, Portfolio, and Profile.
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _destinations = const [
    HomeMarketplaceView(),
    InteractiveMapHubView(),
    CoInvestRoommateHubView(),
    PortfolioView(),
    ProfileSettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Screen Viewport (IndexedStack preserves tab states and memory)
          IndexedStack(
            index: _currentIndex,
            children: _destinations,
          ),

          // Floating Glassmorphic Bottom Navigation Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withValues(alpha: isDark ? 0.88 : 0.95),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.35),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.6)
                            : const Color(0x1A0F1B2B),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: BlocBuilder<ExploreFeedBloc, ExploreFeedState>(
                    builder: (context, feedState) {
                      final savedCount = feedState.savedProperties.length;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(
                            context: context,
                            index: 0,
                            icon: Icons.home_work_rounded,
                            label: l10n.translate('nav_marketplace'),
                          ),
                          _buildNavItem(
                            context: context,
                            index: 1,
                            icon: Icons.radar_rounded,
                            label: l10n.translate('nav_map'),
                          ),
                          _buildNavItem(
                            context: context,
                            index: 2,
                            icon: Icons.group_work_rounded,
                            label: l10n.translate('nav_coliving'),
                          ),
                          _buildNavItem(
                            context: context,
                            index: 3,
                            icon: Icons.favorite_rounded,
                            label: l10n.translate('nav_portfolio'),
                            badgeCount: savedCount > 0 ? savedCount : null,
                          ),
                          _buildNavItem(
                            context: context,
                            index: 4,
                            icon: Icons.person_outline_rounded,
                            label: l10n.translate('nav_profile'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    int? badgeCount,
  }) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.15 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: isSelected
              ? Border.all(
                  color: primaryColor.withValues(alpha: 0.4),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? primaryColor
                      : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
                ),
                if (badgeCount != null)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.backgroundDark : Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? primaryColor
                    : (isDark ? AppColors.textMuted : const Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
