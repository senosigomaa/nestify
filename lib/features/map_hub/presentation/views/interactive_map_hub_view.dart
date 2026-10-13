import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/core/network/mock_properties_data.dart';
import 'package:nestify/features/explore_feed/data/models/property_model.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';
import 'package:nestify/features/property_details/presentation/views/property_details_screen.dart';

/// InteractiveMapHubView delivers a dynamic radar and spatial intelligence map
/// powered by real Google Maps SDK with custom property pins, real-time noise & transit filters,
/// dual-theme styling (Obsidian Dark / Nordic Minimalist), and glassmorphic preview cards.
class InteractiveMapHubView extends StatefulWidget {
  const InteractiveMapHubView({super.key});

  @override
  State<InteractiveMapHubView> createState() => _InteractiveMapHubViewState();
}

class _InteractiveMapHubViewState extends State<InteractiveMapHubView> {
  GoogleMapController? _mapController;
  late List<PropertyEntity> _allProperties;
  PropertyEntity? _selectedProperty;

  // Active Map Filter toggles
  bool _filterQuiet = false; // < 40 dB
  bool _filterCoffee = false; // <= 2 mins
  bool _filterMetro = false; // <= 8 mins

  // Egyptian Real Estate Centers: New Cairo & Sheikh Zayed
  static const LatLng _newCairoCenter = LatLng(30.0131, 31.4913);
  static const LatLng _sheikhZayedCenter = LatLng(30.0543, 30.9763);
  LatLng _currentCenter = _newCairoCenter;

  // Property Geo-coordinates in New Cairo and Sheikh Zayed
  final Map<String, LatLng> _propertyCoords = {
    'prop_001': const LatLng(30.0180, 31.4950), // New Cairo 5th Settlement
    'prop_002': const LatLng(30.0560, 30.9780), // Sheikh Zayed / October
    'prop_003': const LatLng(30.0110, 31.4870), // Golden Square, New Cairo
    'prop_004': const LatLng(30.0510, 30.9690), // SODIC West, Sheikh Zayed
    'prop_005': const LatLng(30.0240, 31.5030), // South 90th St, New Cairo
    'prop_006': const LatLng(30.0090, 31.4780), // Choueifat, New Cairo
  };

  // Custom Google Maps Dark Styling (Obsidian / Slate Luxury)
  static const String _darkMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#141c2b"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#8ec3b9"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#141c2b"}]},
  {"featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [{"color": "#d4af37"}]},
  {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#6f9ba5"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#1b2d28"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#1e293b"}]},
  {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#212a37"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#2d3748"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#0b1320"}]}
]
''';

  // Custom Google Maps Light Styling (Nordic Minimalist Ivory / Gold)
  static const String _lightMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#fbf9f5"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#0f1b2b"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#ffffff"}]},
  {"featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [{"color": "#c5a880"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#e2ebe4"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#ffffff"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#f3ede2"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#cce3de"}]}
]
''';

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

  Set<Marker> _buildMarkers(bool isArabic) {
    final markers = <Marker>{};
    for (final prop in _filteredProperties) {
      final position = _propertyCoords[prop.id] ?? _newCairoCenter;
      final isSelected = _selectedProperty?.id == prop.id;

      markers.add(
        Marker(
          markerId: MarkerId(prop.id),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected
                ? BitmapDescriptor.hueCyan
                : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: prop.title,
            snippet: prop.localizedPrice(isArabic),
          ),
          onTap: () {
            setState(() {
              _selectedProperty = prop;
            });
          },
        ),
      );
    }
    return markers;
  }

  void _switchHub(LatLng target) {
    setState(() {
      _currentCenter = target;
    });
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 13.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final visibleProperties = _filteredProperties;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Real Google Maps SDK Integration (Explicit Full-Screen Bounds)
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(30.0131, 31.4913),
                zoom: 12.0,
              ),
              style: isDark ? _darkMapStyle : _lightMapStyle,
              markers: _buildMarkers(l10n.isArabic),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              mapToolbarEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: (_) {
                // Keep preview or dismiss on outside tap
              },
            ),
          ),

          // 2. Top Header & Live Filter Pills
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Row: Title Pill & Hub Switcher
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title & Count Pill with Flexible Overflow Protection
                      Flexible(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: theme.cardColor.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.radar_rounded,
                                    color: primaryColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          l10n.translate('map_title'),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${visibleProperties.length} ${l10n.translate('properties_count')}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
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
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Location Quick Jump Pill (New Cairo / Zayed)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter:
                              ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.cardColor.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildHubButton(
                                  label: l10n.isArabic
                                      ? 'التجمع الخامس'
                                      : 'New Cairo',
                                  isSelected:
                                      _currentCenter == _newCairoCenter,
                                  onTap: () => _switchHub(_newCairoCenter),
                                  isDark: isDark,
                                ),
                                _buildHubButton(
                                  label: l10n.isArabic
                                      ? 'الشيخ زايد'
                                      : 'Zayed',
                                  isSelected:
                                      _currentCenter == _sheikhZayedCenter,
                                  onTap: () =>
                                      _switchHub(_sheikhZayedCenter),
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

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
                          onTap: () => setState(
                              () => _filterQuiet = !_filterQuiet),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          icon: Icons.coffee_rounded,
                          label: l10n.translate('filter_coffee'),
                          isActive: _filterCoffee,
                          onTap: () => setState(
                              () => _filterCoffee = !_filterCoffee),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          icon: Icons.subway_rounded,
                          label: l10n.translate('filter_metro'),
                          isActive: _filterMetro,
                          onTap: () => setState(
                              () => _filterMetro = !_filterMetro),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Property Preview Card (Bottom - 120dp safe offset)
          if (_selectedProperty != null)
            Positioned(
              bottom: 120, // Above persistent bottom navigation bar
              left: 16,
              right: 16,
              child: _buildPreviewCard(_selectedProperty!, l10n, isDark)
                  .animate()
                  .slideY(
                    begin: 0.3,
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(),
            ),
        ],
      ),
    );
  }

  Widget _buildHubButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? (isDark ? AppColors.backgroundDark : Colors.white)
                : (isDark ? AppColors.textSecondary : const Color(0xFF0F1B2B)),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isActive
                  ? primaryColor.withValues(alpha: 0.25)
                  : theme.cardColor.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive
                    ? primaryColor
                    : theme.colorScheme.outlineVariant,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isActive
                      ? primaryColor
                      : (isDark
                          ? AppColors.textSecondary
                          : const Color(0xFF64748B)),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? primaryColor
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(
    PropertyEntity property,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: primaryColor.withValues(alpha: isDark ? 0.4 : 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : const Color(0x1A0F1B2B),
                blurRadius: 20,
                offset: const Offset(0, 8),
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
                  width: 86,
                  height: 86,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),

              // Details & Specs
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      property.localizedPrice(l10n.isArabic),
                      style: AppTypography.priceTag.copyWith(
                        fontSize: 16,
                        color: primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      property.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      property.neighborhood,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Metrics Strip with Horizontal Scroll to prevent overflow
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildMetricChip(
                            Icons.volume_down_rounded,
                            '${property.noiseLevelDb} dB',
                            isDark,
                          ),
                          const SizedBox(width: 6),
                          _buildMetricChip(
                            Icons.coffee_rounded,
                            '${property.coffeeShopProximityMins} ${l10n.translate('mins')}',
                            isDark,
                          ),
                          const SizedBox(width: 6),
                          _buildMetricChip(
                            Icons.trending_up_rounded,
                            '${property.rentalYieldPct}% ROI',
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Action Arrow button
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          PropertyDetailsScreen(property: property),
                    ),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String label, bool isDark) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDarkElevated
            : const Color(0xFFF4F0E8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: primaryColor,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondary
                  : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
