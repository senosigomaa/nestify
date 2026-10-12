import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_bloc.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_event.dart';

/// InteractiveBookingSheet provides a commercial-grade VIP booking experience
/// allowing clients to reserve physical private tours or Apple Vision Pro spatial VR walkthroughs,
/// with luxury chauffeur escort options.
class InteractiveBookingSheet extends StatefulWidget {
  final PropertyEntity property;

  const InteractiveBookingSheet({
    super.key,
    required this.property,
  });

  static Future<void> show(BuildContext context, PropertyEntity property) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ExploreFeedBloc>(),
        child: InteractiveBookingSheet(property: property),
      ),
    );
  }

  @override
  State<InteractiveBookingSheet> createState() =>
      _InteractiveBookingSheetState();
}

class _InteractiveBookingSheetState extends State<InteractiveBookingSheet> {
  bool _isVrTour = false;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 2));
  String _selectedSlot = '11:00 AM (Midday Light)';
  bool _requestChauffeur = true;
  bool _requestVrKit = false;
  bool _isConfirmed = false;

  final List<String> _timeSlots = [
    '09:30 AM (Morning Dawn)',
    '11:00 AM (Midday Light)',
    '02:30 PM (Afternoon Sun)',
    '05:30 PM (Golden Hour)',
  ];

  void _onConfirm() {
    context.read<ExploreFeedBloc>().add(
          BookTourRequestedEvent(
            property: widget.property,
            tourDate: _selectedDate,
          ),
        );
    setState(() {
      _isConfirmed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            22,
            16,
            22,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: AppColors.borderLight, width: 1.2),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _isConfirmed
                ? _buildConfirmationView(l10n)
                : _buildFormView(l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(AppLocalizations l10n) {
    return Column(
      key: const ValueKey('form_view'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag Handle
        Center(
          child: Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Title
        Text(
          l10n.translate('book_tour_title'),
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.property.title} • ${widget.property.neighborhood}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.neonCyan,
          ),
        ),
        const SizedBox(height: 16),

        // 1. Tour Format Selector (Physical vs VR)
        Text(
          l10n.translate('tour_mode'),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildModeSelector(
                icon: Icons.person_pin_circle_outlined,
                title: l10n.translate('mode_physical'),
                isSelected: !_isVrTour,
                onTap: () => setState(() => _isVrTour = false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildModeSelector(
                icon: Icons.view_in_ar_rounded,
                title: l10n.translate('mode_vr'),
                isSelected: _isVrTour,
                onTap: () => setState(() => _isVrTour = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 2. Date Selection
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.translate('select_date'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: AppColors.neonCyan,
                        surface: AppColors.surfaceDark,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: AppColors.neonCyan,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
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
          ],
        ),
        const SizedBox(height: 10),

        // 3. Time Slot Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _timeSlots.map((slot) {
              final isSelected = slot == _selectedSlot;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedSlot = slot);
                  },
                  selectedColor: AppColors.amberGold.withValues(alpha: 0.2),
                  backgroundColor: AppColors.surfaceDarkElevated,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.amberGold
                        : AppColors.textSecondary,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.amberGold
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // 4. Luxury Concierge Add-Ons
        if (!_isVrTour) ...[
          _buildAddonSwitch(
            icon: Icons.directions_car_filled_rounded,
            title: l10n.translate('chauffeur_option'),
            subtitle: l10n.translate('chauffeur_desc'),
            value: _requestChauffeur,
            onChanged: (val) => setState(() => _requestChauffeur = val),
          ),
        ] else ...[
          _buildAddonSwitch(
            icon: Icons.headset_mic_rounded,
            title: l10n.translate('vr_kit_option'),
            subtitle: l10n.translate('vr_kit_desc'),
            value: _requestVrKit,
            onChanged: (val) => setState(() => _requestVrKit = val),
          ),
        ],
        const SizedBox(height: 22),

        // Confirm Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _onConfirm,
            child: Text(l10n.translate('confirm_booking')),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationView(AppLocalizations l10n) {
    return Column(
      key: const ValueKey('confirmed_view'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.neonCyan.withValues(alpha: 0.15),
            border: Border.all(color: AppColors.neonCyan, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.3),
                blurRadius: 18,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: AppColors.neonCyan,
              size: 40,
            ),
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 18),
        Text(
          l10n.translate('booking_confirmed'),
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceDarkElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                'Tour Format',
                _isVrTour ? 'Immersive Spatial VR' : 'In-Person VIP Tour',
              ),
              const Divider(height: 16),
              _buildSummaryRow(
                'Date & Time',
                '${_selectedDate.month}/${_selectedDate.day} @ $_selectedSlot',
              ),
              if (_requestChauffeur && !_isVrTour) ...[
                const Divider(height: 16),
                _buildSummaryRow('Escort', 'Mercedes EQS Chauffeur Confirmed'),
              ],
              if (_requestVrKit && _isVrTour) ...[
                const Divider(height: 16),
                _buildSummaryRow('Spatial Kit', 'Vision Pro Dispatched to Residence'),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonCyan.withValues(alpha: 0.15)
              : AppColors.surfaceDarkElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.neonCyan
                : Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.neonCyan : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color:
                      isSelected ? AppColors.neonCyan : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddonSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? AppColors.borderCyan : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neonCyan, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.neonCyan,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
