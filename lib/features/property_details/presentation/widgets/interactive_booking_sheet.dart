import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/features/chat/data/chat_mock_service.dart';
import 'package:nestify/features/chat/presentation/views/chat_conversation_screen.dart';
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

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;

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
    _nameController = TextEditingController(text: 'أحمد الشناوي');
    _phoneController = TextEditingController(text: '+201206667376');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final clientName = _nameController.text.trim().isEmpty
        ? 'عميل مهتم'
        : _nameController.text.trim();
    final clientPhone = _phoneController.text.trim().isEmpty
        ? '+201206667376'
        : _phoneController.text.trim();
    final notes = _notesController.text.trim();

    context.read<ExploreFeedBloc>().add(
          BookTourRequestedEvent(
            property: widget.property,
            tourDate: _selectedDate,
          ),
        );

    final conv = ChatMockService.instance.startOrGetConversation(
      property: widget.property,
      clientName: clientName,
      clientPhone: clientPhone,
      tourSlot:
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')} ($_selectedSlot)',
      notes: notes.isNotEmpty ? notes : null,
    );

    Navigator.of(context).pop(); // Dismiss bottom sheet
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatConversationScreen(conversation: conv),
      ),
    );
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
          child: _buildFormView(l10n, theme, isDark, timeSlots),
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
        const SizedBox(height: 14),

        // 1. Client Contact Information (Name & Phone)
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _nameController,
                label: l10n.translate('client_name'),
                hint: l10n.isArabic ? 'مثال: أحمد الشناوي' : 'e.g. Ahmed Shennawy',
                icon: Icons.person_outline_rounded,
                theme: theme,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildInputField(
                controller: _phoneController,
                label: l10n.translate('phone_number'),
                hint: '+201206667376',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                theme: theme,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 2. Tour Format Selector (In-Person VIP vs Spatial VR)
        Text(
          l10n.translate('tour_mode'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: descColor,
          ),
        ),
        const SizedBox(height: 6),
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
        const SizedBox(height: 14),

        // 3. Date Selection
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.translate('select_date'),
              style: TextStyle(
                fontSize: 12,
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
        const SizedBox(height: 8),

        // 4. Time Slot Chips
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
        const SizedBox(height: 12),

        // 5. Inspection Notes (ملاحظات المعاينة)
        _buildInputField(
          controller: _notesController,
          label: l10n.translate('inspection_notes'),
          hint: l10n.isArabic
              ? 'مثال: الاستفسار عن خطة السداد وإمكانية المعاينة العائلية'
              : 'e.g. Inquire about payment plan or family viewing',
          icon: Icons.chat_outlined,
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(height: 20),

        // Confirm Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
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
            icon: const Icon(Icons.chat_bubble_rounded, size: 18),
            label: Text(
              l10n.translate('confirm_tour_and_chat'),
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ThemeData theme,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE2DDD5),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F1B2B),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
              ),
              prefixIcon: icon != null
                  ? Icon(icon, size: 18, color: theme.colorScheme.primary)
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
}
