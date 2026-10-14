import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/features/chat/data/chat_mock_service.dart';
import 'package:nestify/features/chat/presentation/views/chats_list_screen.dart';
import 'package:nestify/features/map_hub/presentation/views/interactive_map_hub_view.dart';
import 'package:nestify/features/marketplace/presentation/views/add_property_listing_screen.dart';
import 'package:nestify/features/marketplace/presentation/views/home_marketplace_view.dart';
import 'package:nestify/features/profile/presentation/views/profile_settings_view.dart';

/// MainNavigationShell provides the persistent glassmorphic navigation shell
/// uniting Marketplace, Interactive Map, Add Listing CTA, Chats Hub, and Profile.
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
    AddPropertyListingScreen(),
    ChatsListScreen(),
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
            left: 14,
            right: 14,
            bottom: MediaQuery.of(context).padding.bottom + 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
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
                  child: ValueListenableBuilder<int>(
                    valueListenable: ChatMockService.instance.totalUnreadNotifier,
                    builder: (context, unreadCount, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(
                            context: context,
                            index: 0,
                            icon: Icons.home_work_rounded,
                            activeIcon: Icons.home_work_rounded,
                            label: l10n.translate('nav_marketplace'),
                          ),
                          _buildNavItem(
                            context: context,
                            index: 1,
                            icon: Icons.radar_rounded,
                            activeIcon: Icons.radar_rounded,
                            label: l10n.translate('nav_map'),
                          ),
                          _buildNavItem(
                            context: context,
                            index: 2,
                            icon: Icons.add_circle_outline_rounded,
                            activeIcon: Icons.add_circle_rounded,
                            label: l10n.translate('nav_add_property'),
                            isCta: true,
                          ),
                          _buildNavItem(
                            context: context,
                            index: 3,
                            icon: Icons.chat_bubble_outline_rounded,
                            activeIcon: Icons.chat_bubble_rounded,
                            label: l10n.translate('nav_chats'),
                            badgeCount: unreadCount > 0 ? unreadCount : null,
                          ),
                          _buildNavItem(
                            context: context,
                            index: 4,
                            icon: Icons.person_outline_rounded,
                            activeIcon: Icons.person_rounded,
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
    IconData? activeIcon,
    required String label,
    int? badgeCount,
    bool isCta = false,
  }) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (isCta) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isSelected ? (activeIcon ?? icon) : icon,
                size: 20,
                color: isSelected
                    ? (isDark ? const Color(0xFF0F1B2B) : Colors.white)
                    : primaryColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? primaryColor
                    : (isDark ? AppColors.textSecondary : const Color(0xFF475569)),
              ),
            ),
          ],
        ),
      );
    }

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
          horizontal: isSelected ? 10 : 6,
          vertical: 5,
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
                  isSelected ? (activeIcon ?? icon) : icon,
                  size: 20,
                  color: isSelected
                      ? primaryColor
                      : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
                ),
                if (badgeCount != null)
                  Positioned(
                    top: -4,
                    right: -7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE11D48),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
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
