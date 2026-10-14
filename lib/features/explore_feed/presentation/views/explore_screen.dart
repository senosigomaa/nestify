import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_bloc.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_event.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_state.dart';
import 'package:nestify/features/explore_feed/presentation/widgets/swipeable_property_card.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/features/property_details/presentation/views/property_details_screen.dart';
import 'package:nestify/features/vibe_radar/presentation/widgets/vibe_radar_sheet.dart';

/// ExploreScreen presents the Tinder-style swipeable deck for modern PropTech,
/// featuring gesture controls, action buttons, neighborhood filtering, and saved portfolio.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  void _showSavedPortfolioSheet(
    BuildContext context,
    List<PropertyEntity> savedProperties,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (modalContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.neonCyan,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Saved Portfolio',
                        style: AppTypography.headlineMedium,
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${savedProperties.length} PROPERTIES',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (savedProperties.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 64,
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No saved properties yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Swipe right on properties you love to save them here.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: savedProperties.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final prop = savedProperties[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(modalContext).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  PropertyDetailsScreen(property: prop),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDarkElevated,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: prop.images.first,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      prop.formattedPrice,
                                      style: AppTypography.priceTag.copyWith(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context, ExploreFeedState state) {
    final cities = [
      'All Global Hubs',
      'Neo-Tokyo',
      'Berlin',
      'San Francisco',
      'Zurich',
      'Brooklyn',
      'Austin',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Architectural Hub',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cities.map((city) {
                  final isAll = city == 'All Global Hubs';
                  final isSelected = isAll
                      ? state.selectedNeighborhood == null
                      : state.selectedNeighborhood == city;

                  return ChoiceChip(
                    label: Text(city),
                    selected: isSelected,
                    onSelected: (selected) {
                      Navigator.of(modalCtx).pop();
                      context.read<ExploreFeedBloc>().add(
                            FilterNeighborhoodEvent(isAll ? null : city),
                          );
                    },
                    selectedColor: AppColors.neonCyan.withValues(alpha: 0.2),
                    backgroundColor: AppColors.surfaceDarkElevated,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.neonCyan
                          : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.neonCyan
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<ExploreFeedBloc, ExploreFeedState>(
          listener: (context, state) {
            if (state.status == ExploreStatus.error &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.passRed,
                  content: Text(state.errorMessage!),
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Top App Bar Header
                _buildTopHeader(context, state),

                // Card Stack Area
                Expanded(
                  child: state.status == ExploreStatus.loading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : state.isDeckEmpty
                          ? _buildEmptyDeckView(context)
                          : _buildCardStack(context, state),
                ),

                // Bottom Action Controls
                _buildActionControls(context, state),
                const SizedBox(height: 78),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, ExploreFeedState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button + Logo & Branding
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsetsDirectional.only(end: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF141C2B).withValues(alpha: 0.9)
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
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppColors.cyanGradient
                      : const LinearGradient(
                          colors: [Color(0xFFC5A880), Color(0xFFD4AF37)],
                        ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.35),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.home_work_rounded,
                    color: isDark ? AppColors.backgroundDark : Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NESTIFY',
                    style: AppTypography.headlineLarge.copyWith(
                      fontSize: 17,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                    ),
                  ),
                  Text(
                    'PROPTECH DISCOVERY',
                    style: TextStyle(
                      fontSize: 8.5,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Hub Filter Chip & Portfolio Button
          Row(
            children: [
              GestureDetector(
                onTap: () => _showFilterDialog(context, state),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDarkElevated : const Color(0xFFF3F0EA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: state.selectedNeighborhood != null
                          ? primaryColor
                          : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        size: 14,
                        color: state.selectedNeighborhood != null
                            ? primaryColor
                            : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        state.selectedNeighborhood ?? (Directionality.of(context) == TextDirection.rtl ? 'كل المناطق' : 'All Hubs'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: state.selectedNeighborhood != null
                              ? primaryColor
                              : (isDark ? Colors.white : const Color(0xFF0F1B2B)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Saved Portfolio Icon
              GestureDetector(
                onTap: () =>
                    _showSavedPortfolioSheet(context, state.savedProperties),
                child: Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDarkElevated : const Color(0xFFF3F0EA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.favorite_rounded,
                          size: 20,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    if (state.savedProperties.isNotEmpty)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.amberGold,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${state.savedProperties.length}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppColors.backgroundDark,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack(BuildContext context, ExploreFeedState state) {
    final deck = state.activeDeck;

    return Stack(
      children: [
        // Background card for 3D depth preview
        if (deck.length > 1)
          Positioned.fill(
            child: Transform.scale(
              scale: 0.94,
              child: Transform.translate(
                offset: const Offset(0, 18),
                child: Opacity(
                  opacity: 0.5,
                  child: SwipeablePropertyCard(
                    property: deck[1],
                    isTopCard: false,
                    onSwipeLeft: () {},
                    onSwipeRight: () {},
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),

        // Interactive Top Card
        if (deck.isNotEmpty)
          SwipeablePropertyCard(
            key: ValueKey(deck[0].id),
            property: deck[0],
            isTopCard: true,
            onSwipeLeft: () {
              context.read<ExploreFeedBloc>().add(SwipeLeftEvent(deck[0]));
            },
            onSwipeRight: () {
              context.read<ExploreFeedBloc>().add(SwipeRightEvent(deck[0]));
            },
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PropertyDetailsScreen(property: deck[0]),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyDeckView(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceDarkElevated,
                border: Border.all(
                  color: AppColors.borderCyan,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: AppColors.neonCyan,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.translate('all_caught_up'),
              style: AppTypography.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.translate('all_caught_up_desc'),
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ExploreFeedBloc>().add(const ResetFeedDeckEvent());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.translate('recharge_deck')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionControls(BuildContext context, ExploreFeedState state) {
    final topCard = state.currentTopCard;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Undo Button
          _buildActionButton(
            icon: Icons.undo_rounded,
            color: AppColors.amberGold,
            size: 46,
            isEnabled: state.canUndo,
            onTap: () {
              context.read<ExploreFeedBloc>().add(const UndoLastSwipeEvent());
            },
          ),

          // 2. Pass / Dislike (Left Swipe)
          _buildActionButton(
            icon: Icons.close_rounded,
            color: AppColors.passRed,
            size: 60,
            isEnabled: topCard != null,
            onTap: () {
              if (topCard != null) {
                context.read<ExploreFeedBloc>().add(SwipeLeftEvent(topCard));
              }
            },
          ),

          // 3. Vibe Radar Quick Sheet
          _buildActionButton(
            icon: Icons.radar_rounded,
            color: AppColors.cyanVariant,
            size: 50,
            isEnabled: topCard != null,
            onTap: () {
              if (topCard != null) {
                VibeRadarSheet.show(context, topCard);
              }
            },
          ),

          // 4. Like / Save (Right Swipe)
          _buildActionButton(
            icon: Icons.favorite_rounded,
            color: AppColors.neonCyan,
            size: 60,
            isEnabled: topCard != null,
            onTap: () {
              if (topCard != null) {
                context.read<ExploreFeedBloc>().add(SwipeRightEvent(topCard));
              }
            },
          ),

          // 5. Deep Dive Details / Tour
          _buildActionButton(
            icon: Icons.fullscreen_rounded,
            color: Colors.white,
            size: 46,
            isEnabled: topCard != null,
            onTap: () {
              if (topCard != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PropertyDetailsScreen(property: topCard),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.surfaceDarkCard
              : AppColors.surfaceDarkElevated.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(
            color: isEnabled
                ? color.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.05),
            width: 1.5,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Icon(
            icon,
            size: size * 0.48,
            color: isEnabled ? color : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
