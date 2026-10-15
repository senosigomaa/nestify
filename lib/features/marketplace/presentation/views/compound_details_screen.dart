import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/constants/app_typography.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/features/chat/data/chat_mock_service.dart';
import 'package:nestify/features/chat/presentation/views/chat_conversation_screen.dart';
import '../../domain/entities/compound_entity.dart';

/// CompoundDetailsScreen provides a rich, executive-grade overview for Off-Plan
/// and New Compound real-estate projects in Egypt (Cairo, Giza, New Capital).
class CompoundDetailsScreen extends StatefulWidget {
  final CompoundEntity compound;

  const CompoundDetailsScreen({
    super.key,
    required this.compound,
  });

  @override
  State<CompoundDetailsScreen> createState() => _CompoundDetailsScreenState();
}

class _CompoundDetailsScreenState extends State<CompoundDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activePhotoIndex = 0;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openEoiModal(BuildContext context, {CompoundUnitType? preferredUnit}) {
    final l10n = context.l10n;
    final isArabic = l10n.isArabic;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final nameController = TextEditingController(text: 'أحمد الشناوي');
    final phoneController = TextEditingController(text: '+201206667376');
    final notesController = TextEditingController();
    String? selectedUnit = preferredUnit?.localizedName(isArabic) ??
        (widget.compound.availableUnitTypes.isNotEmpty
            ? widget.compound.availableUnitTypes.first.localizedName(isArabic)
            : null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
            return Container(
              margin: EdgeInsets.only(bottom: bottomInset),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141C2B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.bookmark_add_rounded, color: primaryColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? 'سجل اهتمامك / طلب حجز (EOI)' : 'Register Interest (EOI)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.compound.localizedName(isArabic),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.secondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.of(modalCtx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Unit Selection Chips
                    if (widget.compound.availableUnitTypes.isNotEmpty) ...[
                      Text(
                        isArabic ? 'نوع الوحدة المفضلة:' : 'Preferred Unit Type:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.compound.availableUnitTypes.map((unit) {
                          final isSelected = selectedUnit == unit.localizedName(isArabic);
                          return ChoiceChip(
                            label: Text(
                              unit.localizedName(isArabic),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : const Color(0xFF0F1B2B)),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: primaryColor,
                            backgroundColor: isDark ? const Color(0xFF1E2838) : const Color(0xFFF1F5F9),
                            onSelected: (_) {
                              setModalState(() {
                                selectedUnit = unit.localizedName(isArabic);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Client Name
                    _buildInputField(
                      controller: nameController,
                      label: isArabic ? 'اسم العميل' : 'Client Name',
                      hint: 'أحمد الشناوي',
                      isDark: isDark,
                      primaryColor: primaryColor,
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),

                    // Client Phone
                    _buildInputField(
                      controller: phoneController,
                      label: isArabic ? 'رقم الهاتف للتواصل وواتساب' : 'Phone / WhatsApp',
                      hint: '+201206667376',
                      isDark: isDark,
                      primaryColor: primaryColor,
                      icon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    // Inquiry Notes
                    _buildInputField(
                      controller: notesController,
                      label: isArabic ? 'ملاحظات أو استفسار خاص (اختياري)' : 'Inquiry / Notes (Optional)',
                      hint: isArabic ? 'الميزانية، تاريخ الاستلام المفضل...' : 'Budget, preferred delivery...',
                      isDark: isDark,
                      primaryColor: primaryColor,
                      icon: Icons.chat_bubble_outline_rounded,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),

                    // Submit Action Button
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
                        onPressed: () {
                          final cName = nameController.text.trim().isEmpty
                              ? 'أحمد الشناوي'
                              : nameController.text.trim();
                          final cPhone = phoneController.text.trim().isEmpty
                              ? '+201206667376'
                              : phoneController.text.trim();
                          final notes = notesController.text.trim();

                          final conv = ChatMockService.instance.startCompoundInquiry(
                            compound: widget.compound,
                            clientName: cName,
                            clientPhone: cPhone,
                            selectedUnitType: selectedUnit,
                            notes: notes.isNotEmpty ? notes : null,
                          );

                          Navigator.of(modalCtx).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isArabic
                                    ? 'تم تسجيل طلب الاهتمام والحجز المبدئي بنجاح!'
                                    : 'EOI Inquiry registered successfully!',
                              ),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatConversationScreen(conversation: conv),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_bubble_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              isArabic
                                  ? 'تأكيد طلب الاهتمام والبدء بالمحادثة'
                                  : 'Confirm EOI & Start Chat',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    required Color primaryColor,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2838) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
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
              prefixIcon: Icon(icon, size: 18, color: primaryColor),
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isArabic = l10n.isArabic;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final compound = widget.compound;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Image & Header Sliver
              SliverAppBar(
                expandedHeight: 330,
                pinned: true,
                elevation: 0,
                backgroundColor: theme.scaffoldBackgroundColor,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: isDark
                        ? Colors.black54
                        : Colors.white.withValues(alpha: 0.85),
                    child: IconButton(
                      icon: Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.arrow_forward_ios_rounded
                            : Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: isDark
                          ? Colors.black54
                          : Colors.white.withValues(alpha: 0.85),
                      child: IconButton(
                        icon: Icon(
                          _isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 18,
                          color: _isSaved ? const Color(0xFFE11D48) : theme.colorScheme.onSurface,
                        ),
                        onPressed: () {
                          setState(() => _isSaved = !_isSaved);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isSaved
                                    ? (isArabic ? 'تم حفظ الكمبوند في المفضلة' : 'Compound saved to favorites')
                                    : (isArabic ? 'تمت إزالة الكمبوند من المفضلة' : 'Compound removed from favorites'),
                              ),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Photo Gallery Carousel
                      PageView.builder(
                        itemCount: compound.galleryImages.length,
                        onPageChanged: (i) => setState(() => _activePhotoIndex = i),
                        itemBuilder: (context, idx) {
                          return CachedNetworkImage(
                            imageUrl: compound.galleryImages[idx],
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(color: Colors.black12),
                            errorWidget: (_, _, _) => Container(
                              color: isDark ? const Color(0xFF1E2838) : const Color(0xFFE2E8F0),
                              child: const Icon(Icons.domain_rounded, size: 48, color: Colors.grey),
                            ),
                          );
                        },
                      ),

                      // Gradient Overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.4),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.75),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Photo Counter Indicator
                      Positioned(
                        bottom: 16,
                        right: isArabic ? 20 : null,
                        left: isArabic ? null : 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24, width: 0.8),
                          ),
                          child: Text(
                            '${_activePhotoIndex + 1} / ${compound.galleryImages.length}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Delivery Badge
                      Positioned(
                        top: 100,
                        right: isArabic ? 20 : null,
                        left: isArabic ? null : 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.amberGold,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            compound.localizedDelivery(isArabic),
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.backgroundDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main Details Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Developer & Title Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(shape: BoxShape.circle),
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: compound.developerLogo,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, _, _) => const Icon(
                                            Icons.business_rounded,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        compound.developerName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.secondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  compound.localizedName(isArabic),
                                  style: AppTypography.headlineLarge.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Location Row
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: primaryColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              compound.localizedLocation(isArabic),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Key Financial & Project Highlights Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF141C2B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE5E0D8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : const Color(0x0A0F1B2B),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildHighlightMetric(
                                  title: isArabic ? 'خطة السداد' : 'Payment Plan',
                                  value: compound.localizedPaymentPlan(isArabic),
                                  icon: Icons.payments_outlined,
                                  theme: theme,
                                  isDark: isDark,
                                ),
                                Container(
                                  height: 38,
                                  width: 1,
                                  color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                                ),
                                _buildHighlightMetric(
                                  title: isArabic ? 'خصم الكاش' : 'Cash Discount',
                                  value: '${compound.cashDiscountPercent}% ${isArabic ? "خصم فوري" : "Off"}',
                                  icon: Icons.discount_outlined,
                                  theme: theme,
                                  isDark: isDark,
                                  highlightColor: const Color(0xFF10B981),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildHighlightMetric(
                                  title: isArabic ? 'مساحة المشروع' : 'Total Area',
                                  value: '${compound.areaAcres.toInt()} ${isArabic ? "فدان" : "Acres"}',
                                  icon: Icons.landscape_outlined,
                                  theme: theme,
                                  isDark: isDark,
                                ),
                                Container(
                                  height: 38,
                                  width: 1,
                                  color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                                ),
                                _buildHighlightMetric(
                                  title: isArabic ? 'الأسعار تبدأ من' : 'Starting From',
                                  value: compound.formattedStartingPrice(isArabic),
                                  icon: Icons.sell_outlined,
                                  theme: theme,
                                  isDark: isDark,
                                  highlightColor: primaryColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Section: Breakdown of Available Unit Types
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isArabic ? 'نماذج الوحدات والأسعار المتاحة' : 'Available Unit Types & Pricing',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${compound.availableUnitTypes.length} ${isArabic ? "نماذج" : "Types"}',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Unit Type Cards
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: compound.availableUnitTypes.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (ctx, idx) {
                          final unit = compound.availableUnitTypes[idx];
                          return _buildUnitTypeCard(unit, isArabic, theme, isDark, primaryColor);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Master Plan & Layout Visualizer
                      Row(
                        children: [
                          Icon(Icons.map_rounded, color: primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isArabic ? 'المخطط العام للكمبوند (Master Plan)' : 'Compound Master Plan',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: compound.masterPlanImage,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => Container(
                                height: 200,
                                color: isDark ? const Color(0xFF1E2838) : const Color(0xFFF1F5F9),
                                child: const Center(child: Icon(Icons.architecture_rounded, size: 40)),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              left: 14,
                              right: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        isArabic
                                            ? 'مخطط معماري هندسي معتمد بمساحة ${compound.areaAcres.toInt()} فدان'
                                            : 'Official Architectural Master Plan (${compound.areaAcres.toInt()} Acres)',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Project Overview Narrative
                      Text(
                        isArabic ? 'عن المشروع والأسلوب المعماري' : 'Project Overview',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        compound.localizedOverview(isArabic),
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Amenities Grid
                      Text(
                        isArabic ? 'الخدمات والمرافق الحصرية' : 'Exclusive Amenities',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: compound.localizedAmenities(isArabic).map((amenity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF141C2B) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline_rounded, size: 14, color: primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  amenity,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : const Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Bottom Bar with EOI Action Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F1B2B).withValues(alpha: 0.92)
                        : Colors.white.withValues(alpha: 0.94),
                    border: Border(
                      top: BorderSide(
                        color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Starting Price Column
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'الأسعار تبدأ من' : 'Starting From',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                compound.formattedStartingPrice(isArabic),
                                style: AppTypography.priceTag.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Prominent CTA Button: سجل اهتمامك / طلب حجز (EOI)
                      Expanded(
                        flex: 6,
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
                          onPressed: () => _openEoiModal(context),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.bookmark_add_rounded, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  isArabic ? 'سجل اهتمامك / طلب حجز (EOI)' : 'Register Interest (EOI)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightMetric({
    required String title,
    required String value,
    required IconData icon,
    required ThemeData theme,
    required bool isDark,
    Color? highlightColor,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (highlightColor ?? theme.colorScheme.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: highlightColor ?? theme.colorScheme.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: highlightColor ?? (isDark ? Colors.white : const Color(0xFF0F1B2B)),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitTypeCard(
    CompoundUnitType unit,
    bool isArabic,
    ThemeData theme,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141C2B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(unit.icon, color: primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.localizedName(isArabic),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${unit.startingAreaSqm} م² • ${unit.bedrooms} • ${unit.localizedFinishing(isArabic)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isArabic ? 'تبدأ من' : 'From',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppColors.textSecondary : const Color(0xFF94A3B8),
                ),
              ),
              Text(
                unit.formattedPrice(isArabic),
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _openEoiModal(context, preferredUnit: unit),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isArabic ? 'حجز EOI +' : 'EOI +',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
