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

/// InteractiveBookingSheet provides a luxury VIP booking experience
/// supporting both Nordic Light and Obsidian Dark modes, with full Arabic & English localization.
/// Allows clients to schedule private in-person tours or Apple Vision Pro spatial VR walkthroughs.
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
  late String _selectedSlot;
  bool _requestChauffeur = true;
  bool _requestVrKit = false;
  bool _isConfirmed = false;

  final List<String> _timeSlotsAr = [
    'صباحاً (شروق هادئ) ٠٩:٣٠',
    'ظهراً (إضاءة كاملة) ١١:٠٠',
    'عصراً (الغروب الذهبي) ٠٤:٣٠',
    'مساءً (أضواء الليل) ٠٨:٠٠',
  ];

  final List<String> _timeSlotsEn = [
    '09:30 AM (Morning Dawn)',
    '11:00 AM (Midday Light)',
    '04:30 PM (Golden Hour)',
    '08:00 PM (Evening Lights)',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSlot = _timeSlotsAr[1];
  }

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final containerBg = isDark
        ? const Color(0xFF141C2B).withValues(alpha: 0.98)
        : Colors.white.withValues(alpha: 0.98);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFE5E0D8);

    final timeSlots = l10n.isArabic ? _timeSlotsAr : _timeSlotsEn;
    if (!timeSlots.contains(_selectedSlot)) {
      _selectedSlot = timeSlots[1];
    }

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
            color: containerBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                blurRadius: 28,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _isConfirmed
                ? _buildConfirmationView(l10n, theme, isDark)
                : _buildFormView(l10n, theme, isDark, timeSlots),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
    List<String> timeSlots,
  ) {
    final primaryColor = theme.colorScheme.primary;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F1B2B);
    final descColor = isDark ? AppColors.textSecondary : const Color(0xFF475569);

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
              color: isDark
                  ? Colors.white.withValues(alpha: 0.25)
                  : const Color(0xFFCBD5E1),
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
            color: titleColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.property.title} • ${widget.property.neighborhood}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),

        // 1. Tour Format Selector (In-Person VIP vs Spatial VR)
        Text(
          l10n.translate('tour_mode'),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: descColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildModeSelector(
                icon: Icons.person_pin_circle_outlined,
                title: l10n.isArabic ? 'معاينة ميدانية VIP' : 'IN-PERSON VIP',
                isSelected: !_isVrTour,
                onTap: () => setState(() => _isVrTour = false),
                theme: theme,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildModeSelector(
                icon: Icons.view_in_ar_rounded,
                title: l10n.isArabic ? 'جولة واقع افتراضي (VR)' : 'SPATIAL VR TOUR',
                isSelected: _isVrTour,
                onTap: () => setState(() => _isVrTour = true),
                theme: theme,
                isDark: isDark,
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
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: descColor,
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
                    data: Theme.of(context),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: isDark ? 0.4 : 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.isArabic
                          ? '${AppLocalizations.convertToArabicDigits(_selectedDate.year)}-${AppLocalizations.convertToArabicDigits(_selectedDate.month.toString().padLeft(2, '0'))}-${AppLocalizations.convertToArabicDigits(_selectedDate.day.toString().padLeft(2, '0'))}'
                          : '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
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
            children: timeSlots.map((slot) {
              final isSelected = slot == _selectedSlot;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedSlot = slot);
                  },
                  selectedColor: primaryColor.withValues(alpha: isDark ? 0.22 : 0.18),
                  backgroundColor: isDark
                      ? const Color(0xFF1E2838)
                      : const Color(0xFFF3F0EA),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? primaryColor : const Color(0xFF0F1B2B))
                        : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? primaryColor
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFFE2DDD5)),
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
            title: l10n.isArabic
                ? 'مرافقة سيارة فاخرة وسائق VIP'
                : 'Luxury Chauffeur Escort',
            subtitle: l10n.isArabic
                ? 'توصيل بسيارة مرسيدس EQS أو لوسيد إير من موقعك'
                : 'Mercedes EQS private transfer to compound',
            value: _requestChauffeur,
            onChanged: (val) => setState(() => _requestChauffeur = val),
            theme: theme,
            isDark: isDark,
          ),
        ] else ...[
          _buildAddonSwitch(
            icon: Icons.headset_mic_rounded,
            title: l10n.isArabic
                ? 'توصيل طقم نظارة الواقع الافتراضي'
                : 'Spatial VR Headset Delivery',
            subtitle: l10n.isArabic
                ? 'توصيل نظارة Apple Vision Pro مهيأة إلى مكان إقامتك'
                : 'Dispatched to your residence before the tour',
            value: _requestVrKit,
            onChanged: (val) => setState(() => _requestVrKit = val),
            theme: theme,
            isDark: isDark,
          ),
        ],
        const SizedBox(height: 22),

        // Confirm Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: isDark ? const Color(0xFF0B0E14) : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: _onConfirm,
            child: Text(
              l10n.translate('confirm_booking'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationView(
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    final primaryColor = theme.colorScheme.primary;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F1B2B);

    final tourFormat = _isVrTour
        ? (l10n.isArabic ? 'جولة واقع افتراضي (VR)' : 'Spatial VR Tour')
        : (l10n.isArabic ? 'معاينة ميدانية VIP' : 'In-Person VIP Tour');

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
            color: primaryColor.withValues(alpha: 0.15),
            border: Border.all(color: primaryColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 18,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              color: primaryColor,
              size: 40,
            ),
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 18),
        Text(
          l10n.translate('booking_confirmed'),
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E2838)
                : const Color(0xFFFBF9F5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE5E0D8),
            ),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                l10n.isArabic ? 'نوع الجولة' : 'Tour Format',
                tourFormat,
                isDark,
              ),
              const Divider(height: 16),
              _buildSummaryRow(
                l10n.isArabic ? 'التاريخ والوقت' : 'Date & Time',
                l10n.isArabic
                    ? '${AppLocalizations.convertToArabicDigits(_selectedDate.month)}/${AppLocalizations.convertToArabicDigits(_selectedDate.day)} • $_selectedSlot'
                    : '${_selectedDate.month}/${_selectedDate.day} @ $_selectedSlot',
                isDark,
              ),
              if (_requestChauffeur && !_isVrTour) ...[
                const Divider(height: 16),
                _buildSummaryRow(
                  l10n.isArabic ? 'المرافقة الفاخرة' : 'Escort',
                  l10n.isArabic
                      ? 'مرسيدس EQS بسائق خاص معتمدة'
                      : 'Mercedes EQS Chauffeur Confirmed',
                  isDark,
                ),
              ],
              if (_requestVrKit && _isVrTour) ...[
                const Divider(height: 16),
                _buildSummaryRow(
                  l10n.isArabic ? 'طقم الواقع الافتراضي' : 'Spatial Kit',
                  l10n.isArabic
                      ? 'إرسال Apple Vision Pro لمقر إقامتك'
                      : 'Vision Pro Dispatched to Residence',
                  isDark,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: isDark ? const Color(0xFF0B0E14) : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.isArabic ? 'تم / العودة للوحدة' : 'Done',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
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
    required ThemeData theme,
    required bool isDark,
  }) {
    final primaryColor = theme.colorScheme.primary;
    final cardBg = isDark
        ? const Color(0xFF1E2838)
        : const Color(0xFFFBF9F5);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.22 : 0.14)
              : cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE5E0D8)),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? primaryColor
                  : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? primaryColor : const Color(0xFF0F1B2B))
                      : (isDark ? Colors.white : const Color(0xFF334155)),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
    required ThemeData theme,
    required bool isDark,
  }) {
    final primaryColor = theme.colorScheme.primary;
    final cardBg = isDark
        ? const Color(0xFF1E2838)
        : const Color(0xFFFBF9F5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? primaryColor.withValues(alpha: 0.6)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE5E0D8)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F1B2B),
            ),
          ),
        ),
      ],
    );
  }
}
