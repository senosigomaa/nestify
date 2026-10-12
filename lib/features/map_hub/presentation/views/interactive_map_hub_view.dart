import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/core/network/mock_properties_data.dart';
import 'package:nestify/features/explore_feed/data/models/property_model.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';
import 'package:nestify/features/property_details/presentation/views/property_details_screen.dart';

/// InteractiveMapHubView delivers a dynamic radar and spatial intelligence map
/// with custom property pins, real-time noise & transit filters, and glassmorphic preview cards.
class InteractiveMapHubView extends StatefulWidget {
  const InteractiveMapHubView({super.key});

  @override
  State<InteractiveMapHubView> createState() => _InteractiveMapHubViewState();
}

class _InteractiveMapHubViewState extends State<InteractiveMapHubView> {
  late List<PropertyEntity> _allProperties;
  PropertyEntity? _selectedProperty;

  // Active Map Filter toggles
  bool _filterQuiet = false; // < 40 dB
  bool _filterCoffee = false; // <= 2 mins
  bool _filterMetro = false; // <= 8 mins

  // Mock map marker coordinates (normalized 0.0 - 1.0)
  final Map<String, Offset> _markerCoords = {
    'prop_001': const Offset(0.32, 0.38),
    'prop_002': const Offset(0.68, 0.28),
    'prop_003': const Offset(0.25, 0.65),
    'prop_004': const Offset(0.78, 0.72),
    'prop_005': const Offset(0.52, 0.48),
    'prop_006': const Offset(0.40, 0.82),
  };

  @override
  void initState() {
    super.initState();
    _allProperties = MockPropertiesData.rawProperties
        .map((json) => PropertyModel.fromJson(json))
        .toList();
    _selectedProperty = _allProperties.first;
  }

  List<PropertyEntity> get _filteredProperties {
    return _allProperties.where((p) {
      if (_filterQuiet && p.noiseLevelDb >= 40) return false;
      if (_filterCoffee && p.coffeeShopProximityMins > 2) return false;
      if (_filterMetro && p.commuteTechHubMins > 8) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final visibleProperties = _filteredProperties;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Futuristic Dark Neon Map Canvas
          GestureDetector(
            onTap: () {
              // Tap on empty space deselects or maintains selection
            },
            child: CustomPaint(
              painter: _CyberMapPainter(),
              child: Container(),
            ),
          ),

          // 2. Interactive Property Markers
          ...visibleProperties.map((prop) {
            final coord = _markerCoords[prop.id] ?? const Offset(0.5, 0.5);
            final isSelected = _selectedProperty?.id == prop.id;

            return Positioned(
              left: MediaQuery.of(context).size.width * coord.dx - 40,
              top: MediaQuery.of(context).size.height * coord.dy - 50,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedProperty = prop;
                  });
                },
                child: _buildMapMarker(prop, isSelected),
              ),
            );
          }),

          // 3. Top Header & Live Filter Pills
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title Pill
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.radar_rounded,
                              color: AppColors.neonCyan,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.translate('map_title'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${visibleProperties.length} ${l10n.translate('properties_count')}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.neonCyan,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Pills Carousel
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          icon: Icons.volume_off_rounded,
                          label: l10n.translate('filter_quiet'),
                          isActive: _filterQuiet,
                          onTap: () => setState(() => _filterQuiet = !_filterQuiet),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          icon: Icons.coffee_rounded,
                          label: l10n.translate('filter_coffee'),
                          isActive: _filterCoffee,
                          onTap: () =>
                              setState(() => _filterCoffee = !_filterCoffee),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          icon: Icons.subway_rounded,
                          label: l10n.translate('filter_metro'),
                          isActive: _filterMetro,
                          onTap: () => setState(() => _filterMetro = !_filterMetro),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Floating Glassmorphic Property Preview Card (Bottom)
          if (_selectedProperty != null)
            Positioned(
              bottom: 100, // Above bottom navigation bar
              left: 16,
              right: 16,
              child: _buildPreviewCard(_selectedProperty!, l10n)
                  .animate()
                  .slideY(begin: 0.3, duration: 300.ms, curve: Curves.easeOutCubic)
                  .fadeIn(),
            ),
        ],
      ),
    );
  }

  Widget _buildMapMarker(PropertyEntity property, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.neonCyan
                : AppColors.surfaceDark.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.white : AppColors.neonCyan,
              width: isSelected ? 2 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.neonCyan.withValues(alpha: 0.6)
                    : Colors.black.withValues(alpha: 0.4),
                blurRadius: isSelected ? 16 : 8,
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.apartment_rounded,
                size: 13,
                color: isSelected
                    ? AppColors.backgroundDark
                    : AppColors.neonCyan,
              ),
              const SizedBox(width: 4),
              Text(
                property.formattedPrice,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? AppColors.backgroundDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        // Marker Pin Pointer Triangle
        CustomPaint(
          size: const Size(12, 8),
          painter: _TrianglePainter(
            color: isSelected ? AppColors.neonCyan : AppColors.surfaceDark,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.neonCyan.withValues(alpha: 0.25)
                  : AppColors.surfaceDark.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive
                    ? AppColors.neonCyan
                    : Colors.white.withValues(alpha: 0.1),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isActive ? AppColors.neonCyan : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color:
                        isActive ? AppColors.neonCyan : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(PropertyEntity property, AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Photo Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: property.images.first,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),

              // Details & Specs
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      property.formattedPrice,
                      style: AppTypography.priceTag.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      property.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.graphic_eq_rounded,
                          size: 12,
                          color: AppColors.neonCyan,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${property.noiseLevelDb} dB',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.neonCyan,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.local_cafe_outlined,
                          size: 12,
                          color: AppColors.amberGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${property.coffeeShopProximityMins}m',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.amberGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Navigation Action Button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                PropertyDetailsScreen(property: property),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.cyanGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.translate('view_property'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.backgroundDark,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: AppColors.backgroundDark,
                            ),
                          ],
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
    );
  }
}

/// CustomPainter rendering a dark futuristic city grid with metro lines and river curve
class _CyberMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background Dark Slate
    final bgPaint = Paint()..color = const Color(0xFF090D15);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // City Grid Lines
    final gridPaint = Paint()
      ..color = const Color(0xFF131B2A)
      ..strokeWidth = 1.0;

    const step = 45.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // River / Bay Curve
    final riverPaint = Paint()
      ..color = const Color(0xFF0D2137)
      ..strokeWidth = 32.0
      ..style = PaintingStyle.stroke;

    final riverPath = Path()
      ..moveTo(0, size.height * 0.45)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.35,
        size.width * 0.65,
        size.height * 0.65,
        size.width,
        size.height * 0.55,
      );
    canvas.drawPath(riverPath, riverPaint);

    // Transit / Metro Neon Line
    final metroPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.35)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final metroPath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.2)
      ..lineTo(size.width * 0.45, size.height * 0.5)
      ..lineTo(size.width * 0.85, size.height * 0.8);
    canvas.drawPath(metroPath, metroPaint);

    // Secondary Amber Transit Line
    final amberLinePaint = Paint()
      ..color = AppColors.amberGold.withValues(alpha: 0.25)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final amberPath = Path()
      ..moveTo(size.width * 0.8, size.height * 0.15)
      ..lineTo(size.width * 0.5, size.height * 0.45)
      ..lineTo(size.width * 0.2, size.height * 0.85);
    canvas.drawPath(amberPath, amberLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Small triangle pointer for map pin
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
