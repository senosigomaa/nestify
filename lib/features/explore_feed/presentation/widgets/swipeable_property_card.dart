import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';
import 'match_score_badge.dart';

/// SwipeablePropertyCard offers a Tinder-style swipeable deck card with
/// smooth physics-based rotation, LIKE/PASS badges, photo carousel, and glassmorphic stats.
class SwipeablePropertyCard extends StatefulWidget {
  final PropertyEntity property;
  final bool isTopCard;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onTap;

  const SwipeablePropertyCard({
    super.key,
    required this.property,
    required this.isTopCard,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onTap,
  });

  @override
  State<SwipeablePropertyCard> createState() => _SwipeablePropertyCardState();
}

class _SwipeablePropertyCardState extends State<SwipeablePropertyCard>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  int _currentPhotoIndex = 0;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.isTopCard) return;
    _animController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isTopCard) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isTopCard) return;
    const threshold = 120.0;
    if (_dragOffset.dx > threshold) {
      _completeSwipe(toRight: true);
    } else if (_dragOffset.dx < -threshold) {
      _completeSwipe(toRight: false);
    } else {
      // Animate back to center
      _slideAnimation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );
      _slideAnimation.addListener(() {
        setState(() {
          _dragOffset = _slideAnimation.value;
        });
      });
      _animController.forward(from: 0.0);
    }
  }

  void _completeSwipe({required bool toRight}) {
    final targetX = toRight ? 500.0 : -500.0;
    _slideAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset(targetX, _dragOffset.dy),
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInQuad),
    );
    _slideAnimation.addListener(() {
      setState(() {
        _dragOffset = _slideAnimation.value;
      });
    });
    _animController.forward(from: 0.0).then((_) {
      if (toRight) {
        widget.onSwipeRight();
      } else {
        widget.onSwipeLeft();
      }
    });
  }

  void _nextPhoto() {
    if (widget.property.images.isEmpty) return;
    setState(() {
      _currentPhotoIndex =
          (_currentPhotoIndex + 1) % widget.property.images.length;
    });
  }

  void _prevPhoto() {
    if (widget.property.images.isEmpty) return;
    setState(() {
      _currentPhotoIndex =
          (_currentPhotoIndex - 1 + widget.property.images.length) %
              widget.property.images.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rotationAngle = (_dragOffset.dx / 400.0) * (pi / 16);
    final likeOpacity = (_dragOffset.dx / 120.0).clamp(0.0, 1.0);
    final passOpacity = (-_dragOffset.dx / 120.0).clamp(0.0, 1.0);

    return Positioned.fill(
      child: Transform.translate(
        offset: widget.isTopCard ? _dragOffset : Offset.zero,
        child: Transform.rotate(
          angle: widget.isTopCard ? rotationAngle : 0.0,
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onTap: widget.onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. Property Image Carousel
                    _buildImageLayer(),

                    // 2. Photo Navigation Taps (Left/Right half of upper card)
                    _buildPhotoTapControls(),

                    // 3. Top Gradient Scrim & Badges
                    _buildTopOverlay(),

                    // 4. Bottom Dark Scrim & Property Specs Overlay
                    _buildBottomInfo(),

                    // 5. Swipe Direction Indicators (LIKE / NOPE)
                    if (widget.isTopCard && likeOpacity > 0.05)
                      _buildSwipeOverlayBadge(
                        label: 'LIKE',
                        color: AppColors.neonCyan,
                        opacity: likeOpacity,
                        alignment: Alignment.topLeft,
                        angle: -0.25,
                      ),
                    if (widget.isTopCard && passOpacity > 0.05)
                      _buildSwipeOverlayBadge(
                        label: 'PASS',
                        color: AppColors.passRed,
                        opacity: passOpacity,
                        alignment: Alignment.topRight,
                        angle: 0.25,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageLayer() {
    final images = widget.property.images;
    final currentUrl = images.isNotEmpty ? images[_currentPhotoIndex] : '';

    return CachedNetworkImage(
      imageUrl: currentUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.surfaceDark,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.neonCyan,
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.surfaceDarkCard,
        child: const Center(
          child: Icon(
            Icons.apartment_rounded,
            size: 64,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoTapControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 240,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _prevPhoto,
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _nextPhoto,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopOverlay() {
    final imagesCount = widget.property.images.length;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Photo Indicator Dots
            if (imagesCount > 1)
              Row(
                children: List.generate(
                  imagesCount,
                  (index) => Expanded(
                    child: Container(
                      height: 3.5,
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      decoration: BoxDecoration(
                        color: index == _currentPhotoIndex
                            ? AppColors.neonCyan
                            : Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Verified Badge
                if (widget.property.isVerified)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: AppColors.neonCyan,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'VERIFIED ARCHITECTURE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Vibe Match Score
                MatchScoreBadge(
                  score: widget.property.vibeMatchPercentage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: AppColors.darkCardOverlay,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Price & Rent/Buy tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.property.formattedPrice,
                  style: AppTypography.priceTag.copyWith(
                    fontSize: 28,
                    color: AppColors.neonCyan,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amberGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.amberGold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    widget.property.priceType.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.amberGold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Title
            Text(
              widget.property.title,
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
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
                  size: 15,
                  color: AppColors.cyanVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.property.neighborhood,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Micro-stats Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildSpecPill(
                    icon: Icons.bed_outlined,
                    label: '${widget.property.bedrooms} Beds',
                  ),
                  const SizedBox(width: 8),
                  _buildSpecPill(
                    icon: Icons.bathtub_outlined,
                    label: '${widget.property.bathrooms} Baths',
                  ),
                  const SizedBox(width: 8),
                  _buildSpecPill(
                    icon: Icons.graphic_eq_rounded,
                    label: '${widget.property.noiseLevelDb} dB Noise',
                    highlightColor: AppColors.neonCyan,
                  ),
                  const SizedBox(width: 8),
                  _buildSpecPill(
                    icon: Icons.local_cafe_outlined,
                    label: '${widget.property.coffeeShopProximityMins}m Coffee',
                    highlightColor: AppColors.amberGold,
                  ),
                  if (widget.property.petFriendly) ...[
                    const SizedBox(width: 8),
                    _buildSpecPill(
                      icon: Icons.pets_outlined,
                      label: 'Pet Friendly',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Tap hint bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    size: 14,
                    color: AppColors.amberGold,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Tap for Sun-Path & Virtual Style Switcher',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecPill({
    required IconData icon,
    required String label,
    Color? highlightColor,
  }) {
    final activeColor = highlightColor ?? AppColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (highlightColor ?? Colors.white).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: activeColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: activeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeOverlayBadge({
    required String label,
    required Color color,
    required double opacity,
    required Alignment alignment,
    required double angle,
  }) {
    return Positioned(
      top: 90,
      left: alignment == Alignment.topLeft ? 32 : null,
      right: alignment == Alignment.topRight ? 32 : null,
      child: Transform.rotate(
        angle: angle,
        child: Opacity(
          opacity: opacity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
