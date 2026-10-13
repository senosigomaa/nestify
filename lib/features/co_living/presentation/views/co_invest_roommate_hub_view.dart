import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';

/// CoInvestRoommateHubView showcases verified co-buyers and roommates seeking
/// syndication partners for luxury architectural properties.
class CoInvestRoommateHubView extends StatefulWidget {
  const CoInvestRoommateHubView({super.key});

  @override
  State<CoInvestRoommateHubView> createState() =>
      _CoInvestRoommateHubViewState();
}

class _CoInvestRoommateHubViewState extends State<CoInvestRoommateHubView> {
  String _activeFilter = 'all';

  final List<Map<String, dynamic>> _partners = [
    {
      'id': 'p1',
      'name': 'Sari Al-Mansoor',
      'role': 'Senior ML Systems Lead',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      'targetProperty': 'The Obsidian Zenith Penthouse',
      'targetNeighborhood': 'Shibuya Sky Corridor, Neo-Tokyo',
      'equityTarget': '33.3% Equity Share',
      'capitalCommitment': '\$483,333 Upfront • \$2,480/mo',
      'matchScore': 98,
      'lifestyle': ['Remote AI Engineer', 'Acoustic Sanctuary', 'Dog Lover', 'Third-Wave Coffee'],
      'category': 'founder',
      'isVerified': true,
    },
    {
      'id': 'p2',
      'name': 'Elena Rostova',
      'role': 'Industrial Design Architect',
      'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
      'targetProperty': 'Kreuzberg Bauhaus Concrete Loft',
      'targetNeighborhood': 'Paul-Lincke-Ufer, Berlin',
      'equityTarget': '50.0% Equity Share',
      'capitalCommitment': '\$445,000 Upfront • \$2,120/mo',
      'matchScore': 95,
      'lifestyle': ['Minimalist', 'Acoustic Studio Glass', 'Early Bird', 'Cyclist'],
      'category': 'remote',
      'isVerified': true,
    },
    {
      'id': 'p3',
      'name': 'Omar Farooq',
      'role': 'FinTech Founder',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
      'targetProperty': 'Mission Bio-Climatic Sky Villa',
      'targetNeighborhood': 'Valencia Arts Corridor, SF',
      'equityTarget': '25.0% Equity Share',
      'capitalCommitment': '\$495,000 Upfront • \$2,980/mo',
      'matchScore': 92,
      'lifestyle': ['Tech Founder', 'Tesla EV', 'Organic Living', 'No Pets'],
      'category': 'founder',
      'isVerified': true,
    },
    {
      'id': 'p4',
      'name': 'Maya Chen',
      'role': 'Spatial Computing Lead',
      'avatar': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=400&q=80',
      'targetProperty': 'DUMBO Timber Glasshouse',
      'targetNeighborhood': 'Water Street Wharf, Brooklyn',
      'equityTarget': '33.3% Equity Share',
      'capitalCommitment': '\$583,333 Upfront • \$3,150/mo',
      'matchScore': 96,
      'lifestyle': ['VR Enthusiast', '10Gbps Fiber', 'Cat Friendly', 'Quiet Hours'],
      'category': 'pet',
      'isVerified': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredPartners {
    if (_activeFilter == 'remote') {
      return _partners.where((p) => p['category'] == 'remote').toList();
    }
    if (_activeFilter == 'founder') {
      return _partners.where((p) => p['category'] == 'founder').toList();
    }
    if (_activeFilter == 'pet') {
      return _partners.where((p) => p['category'] == 'pet').toList();
    }
    return _partners;
  }

  void _showJoinGroupDialog(Map<String, dynamic> partner, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.25)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(partner['avatar']),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              partner['name'],
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              partner['targetProperty'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.surfaceDarkElevated
                          : const Color(0xFFF8F6F0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildRow(context, 'Target Equity Share', partner['equityTarget']),
                        const Divider(height: 14),
                        _buildRow(context, 'Financial Commitment', partner['capitalCommitment']),
                        const Divider(height: 14),
                        _buildRow(context, 'Escrow Provider', 'Nestify Smart Title Escrow LLC'),
                        const Divider(height: 14),
                        _buildRow(context, 'Legal Structure', 'Tenants-in-Common (TIC) Agreement'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Theme.of(context).cardColor,
                            content: Row(
                              children: [
                                Icon(
                                  Icons.handshake_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n.translate('group_request_sent'),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Text(l10n.translate('connect_partner')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final list = _filteredPartners;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.translate('coliving_hub_title'),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          '${list.length} PARTNERS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.translate('coliving_hub_subtitle'),
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: l10n.translate('filter_all_partners'),
                      code: 'all',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: l10n.translate('filter_founders'),
                      code: 'founder',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: l10n.translate('filter_remote_workers'),
                      code: 'remote',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: l10n.translate('filter_pet_lovers'),
                      code: 'pet',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Partner Cards List (with 120 bottom padding for persistent navigation bar)
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final p = list[index];
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.25)
                              : const Color(0x0A0F1B2B),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Partner Header
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(p['avatar']),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        p['name'],
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      if (p['isVerified']) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.verified_rounded,
                                          size: 14,
                                          color: primaryColor,
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    p['role'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                '${p['matchScore']}% MATCH',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Target Compound Box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDarkElevated
                                : const Color(0xFFF8F6F0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['targetProperty'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p['targetNeighborhood'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    p['equityTarget'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                  Text(
                                    p['capitalCommitment'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Lifestyle Tags
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children:
                              (p['lifestyle'] as List<String>).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : const Color(0xFFF0EDE6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor, width: 1.2),
                            ),
                            onPressed: () => _showJoinGroupDialog(p, l10n),
                            child: Text(l10n.translate('connect_partner')),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({required String label, required String code}) {
    final isSelected = _activeFilter == code;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _activeFilter = code);
      },
      selectedColor: primaryColor.withValues(alpha: 0.2),
      backgroundColor: isDark ? AppColors.surfaceDarkElevated : const Color(0xFFF0EDE6),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? primaryColor : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
      ),
      side: BorderSide(
        color: isSelected ? primaryColor : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E2DC)),
      ),
    );
  }
}
