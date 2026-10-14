import 'package:flutter/material.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/localization/app_localizations.dart';

/// AddPropertyListingScreen provides a 3-step listing flow
/// tailored for the Egyptian real estate market, featuring:
/// 1. Egyptian Property details (Finishing, Compound, Down payment, Installments).
/// 2. Listing Tier selection (Free, Featured 750 EGP, Enterprise Pro 2,500 EGP).
/// 3. Instant Visa/MasterCard card checkout with visual card preview and instant activation.
class AddPropertyListingScreen extends StatefulWidget {
  const AddPropertyListingScreen({super.key});

  @override
  State<AddPropertyListingScreen> createState() =>
      _AddPropertyListingScreenState();
}

class _AddPropertyListingScreenState extends State<AddPropertyListingScreen> {
  int _currentStep = 0; // 0: Details, 1: Tier, 2: Payment

  // Step 1: Property Form Controllers & States
  String _transactionType = 'buy'; // 'buy' or 'rent'
  String _propertyType = 'apartment'; // 'apartment', 'villa', 'duplex', 'townhouse'
  // Bilingual Title Controllers
  final TextEditingController _titleArController = TextEditingController(
    text: 'شقة فاخرة للبيع في التجمع الخامس (ماونتن فيو)',
  );
  final TextEditingController _titleEnController = TextEditingController(
    text: 'Luxury Apartment for Sale in New Cairo (Mountain View)',
  );

  // Bilingual Description Controllers
  final TextEditingController _descArController = TextEditingController(
    text: 'شقة بإطلالة مفتوحة على السنترال بارك، تشطيب ألترا سوبر لوكس، تتضمن جراج خاص ومصعد.',
  );
  final TextEditingController _descEnController = TextEditingController(
    text: 'Prime view overlooking Central Park, ultra super lux finish with private parking and elevator.',
  );

  final TextEditingController _compoundController = TextEditingController(
    text: 'Mountain View iCity',
  );
  String _selectedLocation = 'التجمع الخامس (New Cairo)';
  final TextEditingController _areaController = TextEditingController(text: '185');
  int _bedrooms = 3;
  int _bathrooms = 2;
  final TextEditingController _totalPriceController = TextEditingController(
    text: '8500000',
  );
  final TextEditingController _downPaymentController = TextEditingController(
    text: '850000',
  );
  int _installmentYears = 8;
  String _finishing = 'fully_finished'; // 'fully_finished', 'semi_finished', 'core_and_shell'
  String _floor = 'الدور الثالث (Third Floor)';
  bool _hasElevator = true;
  final TextEditingController _advertiserNameController =
      TextEditingController(text: 'ساري المنصور');
  final TextEditingController _advertiserPhoneController =
      TextEditingController(text: '+201206667376');

  // Mock uploaded photos
  final List<String> _uploadedImages = [
    'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b?auto=format&fit=crop&w=800&q=80',
  ];

  // Step 2: Listing Tier Selection
  String _selectedTier = 'featured'; // 'starter', 'featured', 'pro'

  // Step 3: Payment Method & Details
  String _paymentMethod = 'card'; // 'card' or 'fawry'
  final TextEditingController _cardNumberController = TextEditingController(
    text: '5342 8920 1938 4242',
  );
  final TextEditingController _cardHolderController = TextEditingController(
    text: 'MOHAMED AHMED',
  );
  final TextEditingController _cardExpiryController = TextEditingController(
    text: '08/28',
  );
  final TextEditingController _cardCvvController = TextEditingController(
    text: '892',
  );

  bool _isProcessingPayment = false;

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _compoundController.dispose();
    _areaController.dispose();
    _totalPriceController.dispose();
    _downPaymentController.dispose();
    _advertiserNameController.dispose();
    _advertiserPhoneController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_titleArController.text.trim().isEmpty &&
          _titleEnController.text.trim().isEmpty) {
        _showToast('يرجى كتابة عنوان الإعلان');
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_selectedTier == 'starter') {
        _showSuccessDialog();
      } else {
        setState(() => _currentStep = 2);
      }
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessingPayment = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _isProcessingPayment = false);
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final tierTitle = _selectedTier == 'starter'
        ? (l10n.isArabic ? 'الباقة العادية (مجاناً)' : 'Standard Free Tier')
        : _selectedTier == 'featured'
            ? (l10n.isArabic ? 'الباقة المميزة Featured (٧٥٠ ج.م)' : 'Featured Tier (750 EGP)')
            : (l10n.isArabic ? 'باقة الشركات برو (٢,٥٠٠ ج.م)' : 'Enterprise Pro (2,500 EGP)');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withValues(alpha: 0.18),
                border: Border.all(color: const Color(0xFF10B981), width: 2),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF10B981),
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.isArabic
                  ? 'تم استلام وتأكيد نشر إعلانك بنجاح!'
                  : 'Listing Submitted & Published Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F1B2B),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.isArabic ? 'رقم الإعلان' : 'Listing Ref',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                        ),
                      ),
                      const Text(
                        '#EG-94821',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.isArabic ? 'نوع الباقة' : 'Active Tier',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        tierTitle,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.isArabic
                  ? 'سيتم توجيه جميع المشترين والمستثمرين المهتمين مباشرة إلى رقم واتساب الخاص بك (+201206667376).'
                  : 'All interested buyers will be routed directly to your WhatsApp (+201206667376).',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.4,
                color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isDark ? const Color(0xFF0B0E14) : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  l10n.isArabic ? 'العودة للرئيسية' : 'Back to Home',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
          ),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          l10n.isArabic ? 'أضف عقارك للنشر' : 'List Your Property',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Progress Bar
            _buildStepIndicator(l10n, theme, isDark),
            const SizedBox(height: 8),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: _currentStep == 0
                    ? _buildStep1Details(l10n, theme, isDark)
                    : _currentStep == 1
                        ? _buildStep2Tiers(l10n, theme, isDark)
                        : _buildStep3Payment(l10n, theme, isDark),
              ),
            ),

            // Bottom Floating Bar
            _buildBottomActionBar(l10n, theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    final primaryColor = theme.colorScheme.primary;

    final steps = [
      l10n.isArabic ? 'بيانات العقار' : 'Details',
      l10n.isArabic ? 'باقة النشر' : 'Listing Tier',
      l10n.isArabic ? 'الدفع بالفيزا' : 'Payment',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E0D8),
          ),
        ),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepIndex = index ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: _currentStep > stepIndex
                    ? primaryColor
                    : (isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFCBD5E1)),
              ),
            );
          }
          final stepIndex = index ~/ 2;
          final isActive = _currentStep == stepIndex;
          final isDone = _currentStep > stepIndex;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone || isActive
                      ? primaryColor
                      : (isDark ? const Color(0xFF1E2838) : const Color(0xFFE2DDD5)),
                ),
                child: Center(
                  child: isDone
                      ? Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: isDark ? const Color(0xFF0B0E14) : Colors.white,
                        )
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isActive
                                ? (isDark ? const Color(0xFF0B0E14) : Colors.white)
                                : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive
                      ? (isDark ? Colors.white : const Color(0xFF0F1B2B))
                      : (isDark ? AppColors.textMuted : const Color(0xFF94A3B8)),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // STEP 1: PROPERTY DETAILS FORM
  Widget _buildStep1Details(
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    final primaryColor = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Transaction Type Segment (للبيع / للإيجار)
        Text(
          l10n.isArabic ? 'نوع المعاملة' : 'Transaction Type',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSelectablePill(
                title: l10n.isArabic ? 'للبيع (تمليك)' : 'For Sale',
                isSelected: _transactionType == 'buy',
                onTap: () => setState(() => _transactionType = 'buy'),
                theme: theme,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSelectablePill(
                title: l10n.isArabic ? 'للإيجار' : 'For Rent',
                isSelected: _transactionType == 'rent',
                onTap: () => setState(() => _transactionType = 'rent'),
                theme: theme,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Property Type Selector
        Text(
          l10n.isArabic ? 'نوع العقار' : 'Property Type',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTypeChip('apartment', l10n.isArabic ? 'شقة' : 'Apartment', theme, isDark),
            _buildTypeChip('villa', l10n.isArabic ? 'فيلا مستقلة' : 'Villa', theme, isDark),
            _buildTypeChip('duplex', l10n.isArabic ? 'دوبلكس' : 'Duplex', theme, isDark),
            _buildTypeChip('townhouse', l10n.isArabic ? 'تاون هاوس' : 'Townhouse', theme, isDark),
            _buildTypeChip('penthouse', l10n.isArabic ? 'بنتهاوس' : 'Penthouse', theme, isDark),
          ],
        ),
        const SizedBox(height: 18),

        // Title Input (Bilingual: Arabic & English)
        Text(
          l10n.isArabic ? 'عنوان الإعلان' : 'Property Title',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _titleArController,
          label: l10n.isArabic ? 'عنوان الإعلان بالعربية' : 'Title in Arabic',
          hint: l10n.isArabic
              ? 'مثال: شقة للبيع في التجمع الخامس'
              : 'e.g. Apartment for sale in New Cairo',
          textDirection: TextDirection.rtl,
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _titleEnController,
          label: l10n.isArabic ? 'Title in English (باللغة الإنجليزية)' : 'Title in English',
          hint: 'e.g., Luxury Apartment for Sale in New Cairo',
          textDirection: TextDirection.ltr,
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(height: 14),

        // Location Dropdown & Compound Name Row
        Text(
          l10n.isArabic ? 'المدينة / المنطقة' : 'Location / Area',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLocation,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF1E2838) : Colors.white,
              items: [
                'التجمع الخامس (New Cairo)',
                'الشيخ زايد (Sheikh Zayed)',
                'العاصمة الإدارية (New Capital)',
                'السادس من أكتوبر (6th of October)',
                'المعادي (Maadi)',
                'الساحل الشمالي (North Coast)',
              ].map((loc) {
                return DropdownMenuItem(
                  value: loc,
                  child: Text(
                    loc,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedLocation = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Compound Name
        _buildTextField(
          controller: _compoundController,
          label: l10n.isArabic ? 'اسم الكمبوند (إن وجد)' : 'Compound Name',
          hint: 'مثال: بالم هيلز، سوديك، هايد بارك...',
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(height: 14),

        // Specs: Area, Bedrooms, Bathrooms
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _areaController,
                label: l10n.isArabic ? 'المساحة (م²)' : 'Area (sqm)',
                hint: '185',
                keyboardType: TextInputType.number,
                theme: theme,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.isArabic ? 'غرف النوم' : 'Bedrooms',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildCounter(
                    value: _bedrooms,
                    onMinus: () {
                      if (_bedrooms > 1) setState(() => _bedrooms--);
                    },
                    onPlus: () => setState(() => _bedrooms++),
                    theme: theme,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.isArabic ? 'الحمامات' : 'Bathrooms',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildCounter(
                    value: _bathrooms,
                    onMinus: () {
                      if (_bathrooms > 1) setState(() => _bathrooms--);
                    },
                    onPlus: () => setState(() => _bathrooms++),
                    theme: theme,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Financials: Total Price, Down Payment, Years
        _buildTextField(
          controller: _totalPriceController,
          label: _transactionType == 'buy'
              ? (l10n.isArabic ? 'السعر الإجمالي (ج.م)' : 'Total Price (EGP)')
              : (l10n.isArabic ? 'الإيجار الشهري (ج.م)' : 'Monthly Rent (EGP)'),
          hint: '8500000',
          keyboardType: TextInputType.number,
          theme: theme,
          isDark: isDark,
        ),
        if (_transactionType == 'buy') ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _downPaymentController,
                  label: l10n.isArabic ? 'المقدم المطلوب (ج.م)' : 'Down Payment',
                  hint: '850000',
                  keyboardType: TextInputType.number,
                  theme: theme,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.isArabic ? 'سنوات التقسيط' : 'Installment Years',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildCounter(
                      value: _installmentYears,
                      suffix: l10n.isArabic ? 'سنوات' : 'yrs',
                      onMinus: () {
                        if (_installmentYears > 1) setState(() => _installmentYears--);
                      },
                      onPlus: () {
                        if (_installmentYears < 12) setState(() => _installmentYears++);
                      },
                      theme: theme,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),

        // Finishing Status
        Text(
          l10n.isArabic ? 'حالة التشطيب' : 'Finishing Status',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildFinishingPill(
                id: 'fully_finished',
                title: l10n.isArabic ? 'تشطيب كامل' : 'Finished',
                theme: theme,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFinishingPill(
                id: 'semi_finished',
                title: l10n.isArabic ? 'نصف تشطيب' : 'Semi',
                theme: theme,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFinishingPill(
                id: 'core_and_shell',
                title: l10n.isArabic ? 'بدون تشطيب' : 'Core & Shell',
                theme: theme,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Image Upload Section
        Text(
          l10n.isArabic ? 'صور العقار (${_uploadedImages.length} صور مرفوعة)' : 'Property Photos',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              // Add photo button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _uploadedImages.add(
                      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80',
                    );
                  });
                  _showToast(l10n.isArabic ? 'تمت إضافة صورة جديدة' : 'Photo added');
                },
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.4),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_rounded, color: primaryColor, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        l10n.isArabic ? 'إضافة صورة' : 'Add Photo',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
              // Thumbnails
              ..._uploadedImages.asMap().entries.map((entry) {
                final idx = entry.key;
                final imgUrl = entry.value;
                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 10),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          imgUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _uploadedImages.removeAt(idx)),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Floor & Elevator
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.isArabic ? 'الدور' : 'Floor Level',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _floor,
                        isExpanded: true,
                        dropdownColor: isDark ? const Color(0xFF1E2838) : Colors.white,
                        items: [
                          'الدور الأرضي (Ground Floor)',
                          'الدور الأول (First Floor)',
                          'الدور الثاني (Second Floor)',
                          'الدور الثالث (Third Floor)',
                          'الدور الرابع (Fourth Floor)',
                          'الدور الأخير مع روف (Penthouse)',
                        ].map((fl) => DropdownMenuItem(
                          value: fl,
                          child: Text(
                            fl,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                            ),
                          ),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _floor = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.isArabic ? 'المصعد (أسانسير)' : 'Elevator',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => setState(() => _hasElevator = !_hasElevator),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: _hasElevator
                            ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.12)
                            : (isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _hasElevator
                              ? theme.colorScheme.primary
                              : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _hasElevator ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 16,
                            color: _hasElevator ? theme.colorScheme.primary : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _hasElevator ? (l10n.isArabic ? 'متوفر' : 'Yes') : (l10n.isArabic ? 'لا يوجد' : 'No'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _hasElevator
                                  ? theme.colorScheme.primary
                                  : (isDark ? Colors.white : const Color(0xFF0F1B2B)),
                            ),
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
        const SizedBox(height: 18),

        // Description Input (Bilingual: Arabic & English)
        Text(
          l10n.isArabic ? 'تفاصيل ووصف الإعلان' : 'Property Description',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _descArController,
          label: l10n.isArabic
              ? 'تفاصيل ووصف العقار بالعربية (المميزات، التشطيب، الخدمات)'
              : 'Description in Arabic (Features, finishes, amenities)',
          hint: l10n.isArabic
              ? 'اكتب تفاصيل العقار، نوع التشطيب، الخدمات، والإطلالة...'
              : 'Write property details, finishes, amenities, and views...',
          textDirection: TextDirection.rtl,
          maxLines: 3,
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _descEnController,
          label: l10n.isArabic
              ? 'Description in English (الوصف بالإنجليزية)'
              : 'Description in English (Key features, finishes, amenities)',
          hint: 'Key features, finishes, compound amenities, views...',
          textDirection: TextDirection.ltr,
          maxLines: 3,
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(height: 18),

        // Advertiser Contact Information
        Text(
          l10n.isArabic ? 'بيانات التواصل للمعلن' : 'Advertiser Contact Info',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _advertiserNameController,
          label: l10n.isArabic ? 'اسم المعلن / الوكيل' : 'Advertiser Name',
          hint: 'ساري المنصور',
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _advertiserPhoneController,
          label: l10n.isArabic ? 'رقم الهاتف للتواصل وواتساب' : 'Phone / WhatsApp',
          hint: '+201206667376',
          keyboardType: TextInputType.phone,
          theme: theme,
          isDark: isDark,
        ),
      ],
    );
  }

  // STEP 2: CHOOSE LISTING TIER
  Widget _buildStep2Tiers(
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.isArabic ? 'اختر باقة الترويج المناسبة لعقارك' : 'Choose Your Listing Tier',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.isArabic
              ? 'تتيح لك باقات نيستيفاي الوصول الفوري لأكثر من ٥٠٠ ألف مشتري ومستثمر جاد في مصر والخليج.'
              : 'Promote your property to over 500,000 verified buyers across Egypt & the Gulf.',
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 18),

        // Tier 1: Starter (Free)
        _buildTierCard(
          id: 'starter',
          title: l10n.isArabic ? 'باقة عادية' : 'Standard Tier',
          price: l10n.isArabic ? 'مجاناً - ٠ ج.م' : 'Free - 0 EGP',
          features: [
            l10n.isArabic ? 'إعلان واحد نشط لمدة ٣٠ يوماً' : '1 active listing for 30 days',
            l10n.isArabic ? 'ظهور قياسي في نتائج البحث' : 'Standard search ranking',
            l10n.isArabic ? 'استقبال رسائل المشترين عبر التطبيق' : 'Receive inquiries in app',
          ],
          badge: l10n.isArabic ? 'مجانية' : 'Free',
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        // Tier 2: Featured (750 EGP) - Best Value
        _buildTierCard(
          id: 'featured',
          title: l10n.isArabic ? 'باقة مميزة "Featured"' : 'Featured Tier',
          price: l10n.isArabic ? '٧٥٠ ج.م' : '750 EGP',
          features: [
            l10n.isArabic ? 'شارة ذهبية "مميز" تزيد المشاهدات ٥ أضعاف' : 'Gold "Featured" badge (5x views)',
            l10n.isArabic ? 'الظهور في صدارة نتائج البحث والصفحة الرئيسية' : 'Top position in search results',
            l10n.isArabic ? 'زر واتساب فوري يربط المشتري بك مباشرة (+201206667376)' : 'Direct 1-click WhatsApp button',
            l10n.isArabic ? 'إشعار فوري عند تفاعل أي عميل مع إعلانك' : 'Instant buyer lead push notification',
          ],
          badge: l10n.isArabic ? 'الأكثر طلباً ومبيعاً ⭐' : 'Best Value ⭐',
          isRecommended: true,
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        // Tier 3: Enterprise Pro (2,500 EGP)
        _buildTierCard(
          id: 'pro',
          title: l10n.isArabic ? 'باقة الشركات برو' : 'Enterprise Pro',
          price: l10n.isArabic ? '٢,٥٠٠ ج.م' : '2,500 EGP',
          features: [
            l10n.isArabic ? 'تثبيت الإعلان في البانر الرئيسي للتطبيق' : 'Hero carousel banner placement',
            l10n.isArabic ? 'جولة واقع افتراضي 360° مجانية' : 'Complimentary 360° VR tour badge',
            l10n.isArabic ? 'حملة إعلانية ممولة على منصات السوشيال ميديا' : 'Dedicated social media ad campaign',
            l10n.isArabic ? 'مستشار عقاري معتمد لغلق الصفقات نيابة عنك' : 'Dedicated broker closing advisor',
          ],
          badge: 'VIP PRO',
          theme: theme,
          isDark: isDark,
        ),
      ],
    );
  }

  // STEP 3: INSTANT VISA / MASTER CARD PAYMENT SHEET
  Widget _buildStep3Payment(
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    final primaryColor = theme.colorScheme.primary;
    final amount = _selectedTier == 'featured' ? '٧٥٠ ج.م' : '٢,٥٠٠ ج.م';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.isArabic ? 'الدفع الإلكتروني وتأكيد النشر' : 'Instant Card Checkout',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.isArabic
              ? 'دفع فوري آمن ومحمي بأعلى معايير الأمان المصرفية.'
              : 'Secure encrypted card processing powered by Central Bank standards.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 16),

        // Payment Method Selector (Visa/Mastercard vs Fawry Pay)
        Text(
          l10n.isArabic ? 'طريقة السداد' : 'Payment Method',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _paymentMethod = 'card'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _paymentMethod == 'card'
                        ? primaryColor.withValues(alpha: isDark ? 0.2 : 0.12)
                        : (isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _paymentMethod == 'card'
                          ? primaryColor
                          : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5)),
                      width: _paymentMethod == 'card' ? 1.6 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card_rounded,
                          size: 18,
                          color: _paymentMethod == 'card'
                              ? primaryColor
                              : (isDark ? AppColors.textSecondary : const Color(0xFF64748B))),
                      const SizedBox(width: 8),
                      Text(
                        l10n.isArabic ? 'بطاقة بنكية / فيزا' : 'Visa / MasterCard',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _paymentMethod == 'card' ? FontWeight.w800 : FontWeight.w600,
                          color: _paymentMethod == 'card'
                              ? primaryColor
                              : (isDark ? Colors.white : const Color(0xFF0F1B2B)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _paymentMethod = 'fawry'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _paymentMethod == 'fawry'
                        ? const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.2 : 0.12)
                        : (isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _paymentMethod == 'fawry'
                          ? const Color(0xFFF59E0B)
                          : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5)),
                      width: _paymentMethod == 'fawry' ? 1.6 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long_rounded,
                          size: 18, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 8),
                      Text(
                        l10n.isArabic ? 'فوري باي (Fawry)' : 'Fawry Pay',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _paymentMethod == 'fawry' ? FontWeight.w800 : FontWeight.w600,
                          color: _paymentMethod == 'fawry'
                              ? const Color(0xFFF59E0B)
                              : (isDark ? Colors.white : const Color(0xFF0F1B2B)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        if (_paymentMethod == 'card') ...[
          // Visual Credit Card Preview
          _buildVisualCardPreview(theme, isDark),
          const SizedBox(height: 20),

          // Card Inputs
          _buildTextField(
            controller: _cardNumberController,
            label: l10n.isArabic ? 'رقم البطاقة (16 رقم)' : 'Card Number',
            hint: '5342 8920 1938 4242',
            keyboardType: TextInputType.number,
            theme: theme,
            isDark: isDark,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),

          _buildTextField(
            controller: _cardHolderController,
            label: l10n.isArabic ? 'اسم حامل البطاقة (بالإنجليزية)' : 'Cardholder Name',
            hint: 'MOHAMED AHMED',
            theme: theme,
            isDark: isDark,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cardExpiryController,
                  label: l10n.isArabic ? 'تاريخ الانتهاء' : 'Expiry Date',
                  hint: '08/28',
                  theme: theme,
                  isDark: isDark,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _cardCvvController,
                  label: 'CVV',
                  hint: '892',
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  theme: theme,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ] else ...[
          // FAWRY PAY CODE CONTAINER
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF2C2415),
                        const Color(0xFF1E1A14),
                      ]
                    : [
                        const Color(0xFFFFFBEB),
                        Colors.white,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.qr_code_2_rounded,
                              color: Color(0xFFF59E0B), size: 24),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.isArabic ? 'كود الدفع المرجعي لفوري' : 'Fawry Reference Code',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                              ),
                            ),
                            Text(
                              l10n.isArabic ? 'صالح لمدة ٤٨ ساعة' : 'Valid for 48 Hours',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFF59E0B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.copy_rounded, size: 18, color: Color(0xFFF59E0B)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141C2B) : const Color(0xFFF3F0EA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '948  210  57',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.isArabic
                      ? 'يمكنك التوجه لأي منفذ فوري، أو الدفع مباشرة عبر تطبيق MyFawry أو المحافظ الإلكترونية وإنستاباي لتفعيل الإعلان فورياً.'
                      : 'Pay at any Fawry retail outlet, or through MyFawry app / E-wallets / InstaPay for instant publishing.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Security Badge
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.isArabic
                      ? 'مدفوعات مشفرة وآمنة بنسبة 100% عبر بنك مصر / فوري بلس.'
                      : '100% secure payment encrypted by Banque Misr & Fawry.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Payment Total Summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.isArabic ? 'المبلغ المطلوب سداده:' : 'Total Amount:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisualCardPreview(ThemeData theme, bool isDark) {
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F1B2B),
            Color(0xFF1E2F48),
            Color(0xFF16253B),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F1B2B).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chip Graphic
              Container(
                width: 38,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white24),
                ),
                child: Center(
                  child: Container(
                    width: 24,
                    height: 16,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Card Brand (Visa / Mastercard)
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEB001B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-8, 0),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Card Number
          Text(
            _cardNumberController.text.isEmpty
                ? '•••• •••• •••• 4242'
                : _cardNumberController.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          // Holder & Expiry
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CARDHOLDER',
                    style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1),
                  ),
                  Text(
                    _cardHolderController.text.isEmpty
                        ? 'MOHAMED AHMED'
                        : _cardHolderController.text.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'VALID THRU',
                    style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1),
                  ),
                  Text(
                    _cardExpiryController.text.isEmpty ? '08/28' : _cardExpiryController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // BOTTOM ACTION BAR
  Widget _buildBottomActionBar(
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    final primaryColor = theme.colorScheme.primary;

    String btnText;
    if (_currentStep == 0) {
      btnText = l10n.isArabic ? 'المتابعة لاختيار باقة النشر ->' : 'Next: Choose Tier ->';
    } else if (_currentStep == 1) {
      if (_selectedTier == 'starter') {
        btnText = l10n.isArabic ? 'تأكيد ونشر الإعلان فوراً (مجاناً)' : 'Publish Free Listing Now';
      } else {
        btnText = l10n.isArabic ? 'المتابعة للدفع بالفيزا ->' : 'Proceed to Card Payment ->';
      }
    } else {
      final amount = _selectedTier == 'featured' ? '٧٥٠ ج.م' : '٢,٥٠٠ ج.م';
      btnText = l10n.isArabic
          ? 'دفع $amount وتأكيد نشر الإعلان فوراً'
          : 'Pay $amount & Publish Now';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E0D8),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: isDark ? const Color(0xFF0B0E14) : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          onPressed: _isProcessingPayment
              ? null
              : () {
                  if (_currentStep == 2) {
                    _processPayment();
                  } else {
                    _nextStep();
                  }
                },
          child: _isProcessingPayment
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: isDark ? const Color(0xFF0B0E14) : Colors.white,
                  ),
                )
              : Text(
                  btnText,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
        ),
      ),
    );
  }

  Widget _buildTierCard({
    required String id,
    required String title,
    required String price,
    required List<String> features,
    required String badge,
    bool isRecommended = false,
    required ThemeData theme,
    required bool isDark,
  }) {
    final isSelected = _selectedTier == id;
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () => setState(() => _selectedTier = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.16 : 0.08)
              : (isDark ? const Color(0xFF1E2838) : const Color(0xFFFBF9F5)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E0D8)),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isRecommended
                        ? const Color(0xFF10B981)
                        : primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isRecommended ? Colors.white : primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              price,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            ...features.map((feat) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: primaryColor, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        feat,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    ValueChanged<String>? onChanged,
    TextDirection? textDirection,
    int maxLines = 1,
    required ThemeData theme,
    required bool isDark,
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
              color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            textDirection: textDirection,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F1B2B),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintTextDirection: textDirection,
              hintStyle: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounter({
    required int value,
    String? suffix,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onMinus,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black12,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove, size: 14),
            ),
          ),
          Text(
            suffix != null ? '$value $suffix' : '$value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F1B2B),
            ),
          ),
          GestureDetector(
            onTap: onPlus,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black12,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectablePill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
  }) {
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.22 : 0.14)
              : (isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5)),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? primaryColor
                  : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(
    String id,
    String label,
    ThemeData theme,
    bool isDark,
  ) {
    final isSelected = _propertyType == id;
    final primaryColor = theme.colorScheme.primary;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _propertyType = id);
      },
      selectedColor: primaryColor.withValues(alpha: isDark ? 0.22 : 0.16),
      backgroundColor: isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected
            ? primaryColor
            : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
      ),
      side: BorderSide(
        color: isSelected
            ? primaryColor
            : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5)),
      ),
    );
  }

  Widget _buildFinishingPill({
    required String id,
    required String title,
    required ThemeData theme,
    required bool isDark,
  }) {
    final isSelected = _finishing == id;
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () => setState(() => _finishing = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.22 : 0.14)
              : (isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5)),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? primaryColor
                  : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
            ),
          ),
        ),
      ),
    );
  }
}
