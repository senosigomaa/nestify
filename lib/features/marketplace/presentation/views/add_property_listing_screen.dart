import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/core/network/mock_properties_data.dart';
import 'package:nestify/features/explore_feed/data/models/property_model.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_bloc.dart';
import 'package:nestify/features/explore_feed/presentation/bloc/explore_feed_event.dart';
import 'package:nestify/features/property_details/presentation/views/property_details_screen.dart';

/// AddPropertyListingScreen provides a 3-step listing flow
/// tailored for the Egyptian real estate market, fully aligned with PropertyEntity/PropertyModel:
/// 1. Form Sections & Fields (Transaction type, Category, Compound/Location, Conditional Financials, Specs, Media/VR, Bilingual, Contact).
/// 2. Listing Tier selection (Free Starter, Featured 750 EGP, Enterprise Pro 2,500 EGP).
/// 3. Visa/Card & Fawry payment checkout with instant listing creation and state propagation.
class AddPropertyListingScreen extends StatefulWidget {
  const AddPropertyListingScreen({super.key});

  @override
  State<AddPropertyListingScreen> createState() =>
      _AddPropertyListingScreenState();
}

class _AddPropertyListingScreenState extends State<AddPropertyListingScreen> {
  int _currentStep = 0; // 0: Details, 1: Tier, 2: Payment

  // 1. Transaction Type: 'cash_sale', 'installment_sale', 'rent'
  String _transactionType = 'installment_sale';

  // 2. Category / Property Type: 'apartment', 'villa', 'townhouse', 'duplex', 'penthouse'
  String _propertyType = 'apartment';

  // 3. Compound & Location
  String _selectedCompound = 'Mountain View iCity';
  final TextEditingController _compoundCustomController = TextEditingController();
  String _selectedLocation = 'التجمع الخامس (New Cairo)';
  final TextEditingController _addressController = TextEditingController(
    text: 'شارع التسعين الجنوبي، بجوار الجامعة الأمريكية',
  );

  // 4. Financials (Strictly Conditional)
  final TextEditingController _monthlyRentController =
      TextEditingController(text: '35000');
  final TextEditingController _cashPriceController =
      TextEditingController(text: '7200000');
  final TextEditingController _installmentPriceController =
      TextEditingController(text: '8500000');
  final TextEditingController _downPaymentController =
      TextEditingController(text: '850000');
  int _installmentYears = 8;
  int _cashDiscountPercent = 20;
  int _securityDepositMonths = 2;
  int _minLeaseYears = 1;
  final List<String> _selectedRentalTerms = ['عائلات فقط', 'شامل الصيانة'];
  int _maintenanceFeePercent = 8;

  // 5. Specifications
  final TextEditingController _areaController =
      TextEditingController(text: '185');
  int _bedrooms = 3;
  int _bathrooms = 2;
  String _floor = 'الدور الثالث (Third Floor)';
  bool _hasElevator = true;
  String _finishing = 'fully_finished'; // 'core_and_shell', 'semi_finished', 'fully_finished', 'furnished'

  // 6. Media & Visuals
  final List<String> _uploadedImages = [
    'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b?auto=format&fit=crop&w=1200&q=80',
  ];
  bool _hasVirtualTour360 = true;

  // 7. Bilingual Details
  final TextEditingController _titleArController = TextEditingController(
    text: 'شقة فاخرة للبيع في التجمع الخامس (ماونتن فيو)',
  );
  final TextEditingController _titleEnController = TextEditingController(
    text: 'Luxury Apartment for Sale in New Cairo (Mountain View)',
  );
  final TextEditingController _descArController = TextEditingController(
    text: 'شقة بإطلالة مفتوحة على السنترال بارك، تشطيب ألترا سوبر لوكس، تتضمن جراج خاص ومصعد.',
  );
  final TextEditingController _descEnController = TextEditingController(
    text: 'Prime view overlooking Central Park, ultra super lux finish with private parking and elevator.',
  );

  // 8. Contact Info
  final TextEditingController _advertiserNameController =
      TextEditingController(text: 'ساري المنصور');
  final TextEditingController _advertiserPhoneController =
      TextEditingController(text: '+201206667376');
  bool _isWhatsAppEnabled = true;

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

  // Static options lists
  static const List<String> _compoundsList = [
    'Mountain View iCity',
    'Palm Hills New Cairo',
    'SODIC VYE Sheikh Zayed',
    'Mivida Emaar',
    'Madinaty Talaat Moustafa',
    'Hyde Park New Cairo',
    'Badya Palm Hills',
    'Il Bosco New Capital',
    'Zed East New Cairo',
    'أخرى / خارج كمبوند',
  ];

  static const List<String> _locationsList = [
    'التجمع الخامس (New Cairo)',
    'الشيخ زايد (Sheikh Zayed)',
    'العاصمة الإدارية (New Capital)',
    'مدينتي (Madinaty)',
    'السادس من أكتوبر (6th of October)',
    'مدينة المستقبل (Mostakbal City)',
    'المعادي (Maadi)',
  ];

  static const List<Map<String, dynamic>> _propertyTypes = [
    {'id': 'apartment', 'ar': 'شقة', 'en': 'Apartment', 'icon': Icons.apartment_rounded},
    {'id': 'villa', 'ar': 'فيلا مستقلة', 'en': 'Villa', 'icon': Icons.villa_rounded},
    {'id': 'townhouse', 'ar': 'تاون هاوس', 'en': 'Townhouse', 'icon': Icons.holiday_village_rounded},
    {'id': 'duplex', 'ar': 'دوبلكس', 'en': 'Duplex', 'icon': Icons.layers_rounded},
    {'id': 'penthouse', 'ar': 'بنتهاوس', 'en': 'Penthouse', 'icon': Icons.roofing_rounded},
  ];

  static const List<Map<String, String>> _finishingStatuses = [
    {'id': 'core_and_shell', 'ar': 'بدون تشطيب', 'en': 'Core & Shell'},
    {'id': 'semi_finished', 'ar': 'نصف تشطيب', 'en': 'Semi Finished'},
    {'id': 'fully_finished', 'ar': 'تشطيب كامل', 'en': 'Fully Finished'},
    {'id': 'furnished', 'ar': 'مفروش', 'en': 'Furnished'},
  ];

  static const List<String> _floorLevels = [
    'الدور الأرضي بحديقة (Ground Floor)',
    'الدور الأول (First Floor)',
    'الدور الثاني (Second Floor)',
    'الدور الثالث (Third Floor)',
    'الدور الرابع (Fourth Floor)',
    'الدور الخامس فأعلى (High Floor)',
    'الدور الأخير مع روف (Penthouse)',
  ];

  static const List<String> _availableRentalTerms = [
    'عائلات فقط',
    'شامل الصيانة',
    'مفروش ومكيف',
    'دفع شهري',
    'دفع ربع سنوي',
    'غير شامل الفواتير',
    'عقد سنوي موثق',
  ];

  static const List<String> _mockPhotoPool = [
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1600573472550-8090b5e0745e?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1613490493576-7fde63acd811?auto=format&fit=crop&w=1200&q=80',
  ];

  @override
  void dispose() {
    _compoundCustomController.dispose();
    _addressController.dispose();
    _monthlyRentController.dispose();
    _cashPriceController.dispose();
    _installmentPriceController.dispose();
    _downPaymentController.dispose();
    _areaController.dispose();
    _titleArController.dispose();
    _titleEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _advertiserNameController.dispose();
    _advertiserPhoneController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  String _formatPrice(double val) {
    if (val <= 0 || val.isNaN || val.isInfinite) return '0';
    final parts = val.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write(',');
      buffer.write(parts[i]);
    }
    return buffer.toString();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_titleArController.text.trim().isEmpty &&
          _titleEnController.text.trim().isEmpty) {
        _showToast('يرجى كتابة عنوان الإعلان');
        return;
      }
      if (_addressController.text.trim().isEmpty) {
        _showToast('يرجى إدخال العنوان بالتفصيل');
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_selectedTier == 'starter') {
        _completeSubmission();
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

  PropertyModel _constructPropertyModel() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final propertyId = 'user_prop_$now';

    final isRent = _transactionType == 'rent';
    final isCash = _transactionType == 'cash_sale';
    final isInstallment = _transactionType == 'installment_sale';

    double price = 0.0;
    if (isRent) {
      price = double.tryParse(_monthlyRentController.text.replaceAll(',', '').trim()) ?? 35000.0;
    } else if (isCash) {
      price = double.tryParse(_cashPriceController.text.replaceAll(',', '').trim()) ?? 7200000.0;
    } else {
      price = double.tryParse(_installmentPriceController.text.replaceAll(',', '').trim()) ?? 8500000.0;
    }

    final downPayment = isInstallment
        ? (double.tryParse(_downPaymentController.text.replaceAll(',', '').trim()) ?? (price * 0.10))
        : 0.0;

    final areaSqm = double.tryParse(_areaController.text.trim()) ?? 185.0;
    final squareFeet = (areaSqm * 10.7639).round();

    final compoundName = _selectedCompound == 'أخرى / خارج كمبوند'
        ? (_compoundCustomController.text.trim().isEmpty
            ? 'خارج كمبوند'
            : _compoundCustomController.text.trim())
        : _selectedCompound;

    final monthlyInstallment = isInstallment
        ? PropertyEntity.calculateInstallment(
            price: price,
            years: _installmentYears,
            downPaymentRatio: price > 0 ? (downPayment / price) : 0.10,
          ).toDouble()
        : 0.0;

    final titleAr = _titleArController.text.trim();
    final titleEn = _titleEnController.text.trim();
    final descAr = _descArController.text.trim();
    final descEn = _descEnController.text.trim();

    final displayTitle = titleAr.isNotEmpty
        ? titleAr
        : (titleEn.isNotEmpty ? titleEn : 'عقار فاخر للنشر في $compoundName');
    final displayDesc = descAr.isNotEmpty
        ? descAr
        : (descEn.isNotEmpty ? descEn : 'عقار مميز بموقع استراتيجي كامل الخدمات.');

    return PropertyModel(
      id: propertyId,
      title: displayTitle,
      neighborhood: '$_selectedLocation - ${_addressController.text.trim()}',
      price: price,
      priceType: isRent ? 'rent' : 'buy',
      images: _uploadedImages.isNotEmpty
          ? List<String>.from(_uploadedImages)
          : [
              'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
            ],
      vibeMatchPercentage: 96,
      noiseLevelDb: 34,
      coffeeShopProximityMins: 3,
      petFriendly: true,
      bedrooms: _bedrooms,
      bathrooms: _bathrooms,
      squareFeet: squareFeet,
      isVerified: true,
      description: displayDesc,
      commuteTechHubMins: 10,
      walkScore: 92,
      greenScore: 88,
      nightlifeScore: 85,
      sunOrientation: 'بحري (North-Facing)',
      amenities: [
        if (_hasElevator) 'مصعد (Elevator)',
        if (_finishing == 'furnished') 'مفروش ومكيف بالكامل',
        if (_hasVirtualTour360) 'جولة افتراضية 360°',
        'أمن وحراسة 24/7',
        'موقف سيارات مغطى',
        'عدادات رسمية (كهرباء ومياه)',
      ],
      styleVariants: {
        'AR_Title': titleAr,
        'EN_Title': titleEn,
        'AR_Desc': descAr,
        'EN_Desc': descEn,
        'floor': _floor,
        'address': _addressController.text.trim(),
        'publisher': _advertiserNameController.text.trim(),
        'tier': _selectedTier,
        'hasElevator': _hasElevator ? 'true' : 'false',
      },
      developerName: compoundName.isNotEmpty && compoundName != 'خارج كمبوند'
          ? compoundName
          : _advertiserNameController.text.trim(),
      downPaymentPrice: downPayment,
      monthlyInstallmentPrice: monthlyInstallment,
      installmentYears: isInstallment ? _installmentYears : 0,
      deliveryYear: 2026,
      isFurnished: _finishing == 'furnished',
      rentalYieldPct: isRent ? 12.5 : 9.8,
      hasVirtualTour360: _hasVirtualTour360,
      contactPhone: _advertiserPhoneController.text.trim(),
      contactWhatsApp:
          _isWhatsAppEnabled ? _advertiserPhoneController.text.trim() : '',
      category: _propertyType,
      currencySymbol: 'EGP',
      finishing: _finishing,
      delivery: 'ready_to_move',
      maintenanceRatio: _maintenanceFeePercent / 100.0,
      offeringType: 'resale',
      cashDiscountPercent: isCash ? _cashDiscountPercent : 0,
      compoundName: compoundName,
      isCashOnly: isCash,
      isInvestmentOpportunity: !isRent && _cashDiscountPercent >= 20,
      securityDepositMonths: isRent ? _securityDepositMonths : 0,
      minLeaseYears: isRent ? _minLeaseYears : 0,
      rentalTerms: isRent ? List<String>.from(_selectedRentalTerms) : const [],
    );
  }

  Future<void> _completeSubmission() async {
    setState(() => _isProcessingPayment = true);
    await Future.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;
    setState(() => _isProcessingPayment = false);

    final newProperty = _constructPropertyModel();

    // 1. Persist to Mock Data & Hive storage
    MockPropertiesData.addProperty(newProperty.toJson());

    // 2. Dispatch event to ExploreFeedBloc
    try {
      context.read<ExploreFeedBloc>().add(AddNewPropertyEvent(newProperty));
    } catch (_) {}

    // 3. Show Success Bottom Sheet
    _showSuccessBottomSheet(newProperty);
  }

  void _showSuccessBottomSheet(PropertyModel newProperty) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetCtx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Success Icon Ring
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  border: Border.all(
                    color: const Color(0xFF10B981),
                    width: 2.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: Color(0xFF10B981),
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                l10n.isArabic
                    ? 'تم نشر وتأكيد إعلانك بنجاح!'
                    : 'Listing Published Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.isArabic
                    ? 'أصبح عقارك معروضاً الآن للمشترين والمستثمرين في السوق العقاري، نتائج البحث، وقسم إعلاناتي.'
                    : 'Your property is now live across marketplace feeds, category filters, and profile listings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 18),

              // Property Mini-Preview Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE2DDD5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: newProperty.images.first,
                        width: 78,
                        height: 78,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Container(
                          width: 78,
                          height: 78,
                          color: isDark
                              ? const Color(0xFF1E2838)
                              : const Color(0xFFE2DDD5),
                          child: const Icon(Icons.apartment_rounded, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  newProperty.forRent
                                      ? (l10n.isArabic ? 'للإيجار الشهري' : 'For Rent')
                                      : newProperty.isCashOnly
                                          ? (l10n.isArabic ? 'بيع كاش' : 'Cash Sale')
                                          : (l10n.isArabic ? 'بيع بالتقسيط' : 'Installment'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              Text(
                                '#EG-${newProperty.id.hashCode.abs() % 90000 + 10000}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textMuted
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            newProperty.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            newProperty.compoundName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondary
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.formatPrice(
                              newProperty.price,
                              currencySymbol: 'EGP',
                              isArabic: l10n.isArabic,
                              isMonthly: newProperty.forRent,
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Primary Action: "معاينة الإعلان في التطبيق"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: Text(
                    l10n.isArabic
                        ? 'معاينة الإعلان في التطبيق'
                        : 'Preview Listing in App',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor:
                        isDark ? const Color(0xFF0B0E14) : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(bottomSheetCtx).pop(); // dismiss sheet
                    Navigator.of(context).pop(); // dismiss add property screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            PropertyDetailsScreen(property: newProperty),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Secondary Action: "العودة للسوق العقاري"
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: const Icon(Icons.storefront_rounded, size: 18),
                  label: Text(
                    l10n.isArabic ? 'العودة للسوق العقاري' : 'Back to Marketplace',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(bottomSheetCtx).pop(); // dismiss sheet
                    Navigator.of(context).pop(); // dismiss add property screen
                  },
                ),
              ),
            ],
          ),
        );
      },
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
      l10n.isArabic ? 'الدفع والتأكيد' : 'Payment',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE5E0D8),
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
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : const Color(0xFFCBD5E1)),
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
                                : (isDark
                                    ? AppColors.textSecondary
                                    : const Color(0xFF64748B)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Transaction Type Segmented Toggle [ للبيع كاش | للبيع بالتقسيط | للإيجار الشهري ]
        Text(
          l10n.isArabic ? 'نوع المعاملة العقارية' : 'Transaction Type',
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
                title: l10n.isArabic ? 'للبيع كاش' : 'Cash Sale',
                subtitle: l10n.isArabic ? 'دفع فوري' : 'Instant Cash',
                isSelected: _transactionType == 'cash_sale',
                onTap: () => setState(() => _transactionType = 'cash_sale'),
                theme: theme,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSelectablePill(
                title: l10n.isArabic ? 'للبيع بالتقسيط' : 'Installment',
                subtitle: l10n.isArabic ? 'أقساط ميسرة' : 'Payment Plan',
                isSelected: _transactionType == 'installment_sale',
                onTap: () => setState(() => _transactionType = 'installment_sale'),
                theme: theme,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSelectablePill(
                title: l10n.isArabic ? 'للإيجار الشهري' : 'Monthly Rent',
                subtitle: l10n.isArabic ? 'إيجار سنوي' : 'Rental Lease',
                isSelected: _transactionType == 'rent',
                onTap: () => setState(() => _transactionType = 'rent'),
                theme: theme,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // 2. Category / Property Type [ شقة | فيلا مستقلة | تاون هاوس | دوبلكس | بنتهاوس ]
        Text(
          l10n.isArabic ? 'نوع العقار والتصنيف' : 'Property Category',
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
          children: _propertyTypes.map((type) {
            final id = type['id'] as String;
            final label = l10n.isArabic ? type['ar'] as String : type['en'] as String;
            final icon = type['icon'] as IconData;
            return _buildCategoryChip(id, label, icon, theme, isDark);
          }).toList(),
        ),
        const SizedBox(height: 18),

        // 3. Compound & Location
        Text(
          l10n.isArabic ? 'المشروع والكمبوند' : 'Compound & Project',
          style: TextStyle(
            fontSize: 13,
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
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE2DDD5),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCompound,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF1E2838) : Colors.white,
              items: _compoundsList.map((comp) {
                return DropdownMenuItem(
                  value: comp,
                  child: Text(
                    comp,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCompound = val);
              },
            ),
          ),
        ),
        if (_selectedCompound == 'أخرى / خارج كمبوند') ...[
          const SizedBox(height: 10),
          _buildTextField(
            controller: _compoundCustomController,
            label: l10n.isArabic ? 'اسم المشروع أو المنطقة' : 'Project / Area Name',
            hint: l10n.isArabic
                ? 'مثال: حي النرجس، بيت الوطن، اللوتس...'
                : 'e.g. Bait Al Watan, Al Narges...',
            theme: theme,
            isDark: isDark,
          ),
        ],
        const SizedBox(height: 14),

        // District / City Selector
        Text(
          l10n.isArabic ? 'المدينة / المنطقة' : 'District / City',
          style: TextStyle(
            fontSize: 13,
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
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE2DDD5),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLocation,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF1E2838) : Colors.white,
              items: _locationsList.map((loc) {
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

        // Detailed Address
        _buildTextField(
          controller: _addressController,
          label: l10n.isArabic ? 'العنوان بالتفصيل والشارع' : 'Detailed Address & Street',
          hint: l10n.isArabic
              ? 'شارع التسعين الجنوبي، بجوار الجامعة الأمريكية'
              : 'e.g. South 90th Street, near AUC',
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(height: 18),

        // 4. Financials (Conditional based on transaction)
        _buildConditionalFinancialsSection(l10n, theme, isDark),
        const SizedBox(height: 18),

        // 5. Specifications: Area, Bedrooms, Bathrooms, Floor, Elevator, Finishing
        _buildSpecificationsSection(l10n, theme, isDark),
        const SizedBox(height: 18),

        // 6. Media & Visuals (Photo slots & VR 360)
        _buildMediaAndVRSection(l10n, theme, isDark),
        const SizedBox(height: 18),

        // 7. Bilingual Details (AR & EN Titles & Descriptions)
        _buildBilingualDetailsSection(l10n, theme, isDark),
        const SizedBox(height: 18),

        // 8. Contact Info (Publisher Name, Phone, WhatsApp)
        _buildContactInfoSection(l10n, theme, isDark),
        const SizedBox(height: 12),
      ],
    );
  }

  // CONDITIONAL FINANCIALS SECTION
  Widget _buildConditionalFinancialsSection(
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    final primaryColor = theme.colorScheme.primary;

    if (_transactionType == 'rent') {
      // RENT FINANCIALS
      final monthlyRent = double.tryParse(_monthlyRentController.text.replaceAll(',', '').trim()) ?? 0.0;
      final securityDepositAmount = monthlyRent * _securityDepositMonths;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.key_rounded, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.isArabic ? 'البيانات المالية للإيجار' : 'Rental Financials',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Monthly Rent
            _buildTextField(
              controller: _monthlyRentController,
              label: l10n.isArabic ? 'قيمة الإيجار الشهري (ج.م)' : 'Monthly Rent (EGP)',
              hint: '35000',
              keyboardType: TextInputType.number,
              theme: theme,
              isDark: isDark,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),

            // Security Deposit & Minimum Lease Period Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.isArabic ? 'مبلغ التأمين (شهور)' : 'Security Deposit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildCounter(
                        value: _securityDepositMonths,
                        suffix: l10n.isArabic ? 'شهور' : 'mo',
                        onMinus: () {
                          if (_securityDepositMonths > 1) {
                            setState(() => _securityDepositMonths--);
                          }
                        },
                        onPlus: () {
                          if (_securityDepositMonths < 6) {
                            setState(() => _securityDepositMonths++);
                          }
                        },
                        theme: theme,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.isArabic
                            ? 'إجمالي التأمين: ${_formatPrice(securityDepositAmount)} ج.م'
                            : 'Deposit: ${_formatPrice(securityDepositAmount)} EGP',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.isArabic ? 'الحد الأدنى للعقد' : 'Min Lease Period',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildCounter(
                        value: _minLeaseYears,
                        suffix: l10n.isArabic ? 'سنوات' : 'yr',
                        onMinus: () {
                          if (_minLeaseYears > 1) {
                            setState(() => _minLeaseYears--);
                          }
                        },
                        onPlus: () {
                          if (_minLeaseYears < 5) {
                            setState(() => _minLeaseYears++);
                          }
                        },
                        theme: theme,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.isArabic ? 'عقد موثق سنوي' : 'Renewable yearly',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Rental Terms Multi-Select
            Text(
              l10n.isArabic ? 'شروط وتفاصيل عقد الإيجار' : 'Rental Lease Terms',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F1B2B),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _availableRentalTerms.map((term) {
                final isSelected = _selectedRentalTerms.contains(term);
                return FilterChip(
                  label: Text(term),
                  selected: isSelected,
                  selectedColor: primaryColor.withValues(alpha: isDark ? 0.25 : 0.16),
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
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedRentalTerms.add(term);
                      } else {
                        _selectedRentalTerms.remove(term);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      );
    } else if (_transactionType == 'cash_sale') {
      // CASH SALE FINANCIALS
      final cashPrice = double.tryParse(_cashPriceController.text.replaceAll(',', '').trim()) ?? 0.0;
      final discountAmount = cashPrice * (_cashDiscountPercent / 100.0);
      final netCashPrice = cashPrice - discountAmount;
      final maintenanceAmount = cashPrice * (_maintenanceFeePercent / 100.0);

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monetization_on_rounded, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.isArabic ? 'البيانات المالية للبيع كاش' : 'Cash Sale Financials',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Total Cash Price
            _buildTextField(
              controller: _cashPriceController,
              label: l10n.isArabic ? 'إجمالي السعر قبل الخصم (ج.م)' : 'Total Price (EGP)',
              hint: '7200000',
              keyboardType: TextInputType.number,
              theme: theme,
              isDark: isDark,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),

            // Immediate Cash Discount %
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.isArabic ? 'نسبة الخصم الفوري للكاش' : 'Instant Cash Discount %',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildCounter(
                        value: _cashDiscountPercent,
                        suffix: '%',
                        onMinus: () {
                          if (_cashDiscountPercent > 0) {
                            setState(() => _cashDiscountPercent -= 5);
                          }
                        },
                        onPlus: () {
                          if (_cashDiscountPercent < 40) {
                            setState(() => _cashDiscountPercent += 5);
                          }
                        },
                        theme: theme,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.isArabic ? 'وديعة الصيانة' : 'Maintenance Ratio',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildCounter(
                        value: _maintenanceFeePercent,
                        suffix: '%',
                        onMinus: () {
                          if (_maintenanceFeePercent > 5) {
                            setState(() => _maintenanceFeePercent--);
                          }
                        },
                        onPlus: () {
                          if (_maintenanceFeePercent < 15) {
                            setState(() => _maintenanceFeePercent++);
                          }
                        },
                        theme: theme,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Net Cash Price Live Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.isArabic ? 'قيمة الخصم النقدي:' : 'Discount Amount:',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                      Text(
                        '- ${_formatPrice(discountAmount)} ج.م ($_cashDiscountPercent%)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.isArabic ? 'صافي سعر الكاش النهائي:' : 'Net Cash Price:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                        ),
                      ),
                      Text(
                        '${_formatPrice(netCashPrice)} ج.م',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.isArabic ? 'وديعة الصيانة ($_maintenanceFeePercent%):' : 'Maintenance:',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '${_formatPrice(maintenanceAmount)} ج.م',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // INSTALLMENT SALE FINANCIALS
      final totalPrice = double.tryParse(_installmentPriceController.text.replaceAll(',', '').trim()) ?? 0.0;
      final downPayment = double.tryParse(_downPaymentController.text.replaceAll(',', '').trim()) ?? 0.0;
      final downPaymentRatio = totalPrice > 0 ? (downPayment / totalPrice) : 0.10;
      final monthly = PropertyEntity.calculateInstallment(
        price: totalPrice,
        years: _installmentYears,
        downPaymentRatio: downPaymentRatio,
      );
      final quarterly = monthly * 3;
      final maintenanceAmount = totalPrice * (_maintenanceFeePercent / 100.0);

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.isArabic ? 'البيانات المالية للبيع بالتقسيط' : 'Installment Financials',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Total Price
            _buildTextField(
              controller: _installmentPriceController,
              label: l10n.isArabic ? 'السعر الإجمالي للعقار (ج.م)' : 'Total Price (EGP)',
              hint: '8500000',
              keyboardType: TextInputType.number,
              theme: theme,
              isDark: isDark,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),

            // Down Payment & Years Row
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
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.isArabic ? 'سنوات السداد' : 'Installment Years',
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
                          if (_installmentYears > 1) {
                            setState(() => _installmentYears--);
                          }
                        },
                        onPlus: () {
                          if (_installmentYears < 12) {
                            setState(() => _installmentYears++);
                          }
                        },
                        theme: theme,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Quick Down Payment Ratios (5%, 10%, 15%, 20%)
            Row(
              children: [
                Text(
                  l10n.isArabic ? 'نسبة سريعة:' : 'Quick ratio:',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 6),
                ...[0.05, 0.10, 0.15, 0.20].map((ratio) {
                  final pct = (ratio * 100).toInt();
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () {
                        final calculated = (totalPrice * ratio).round();
                        setState(() {
                          _downPaymentController.text = calculated.toString();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Text(
                          '$pct%',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 14),

            // Live Simulator Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.isArabic ? 'القسط الشهري المتساوي:' : 'Monthly Installment:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                        ),
                      ),
                      Text(
                        '${_formatPrice(monthly.toDouble())} ج.م / شهر',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.isArabic ? 'القسط الربع سنوي:' : 'Quarterly Installment:',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                      Text(
                        '${_formatPrice(quarterly.toDouble())} ج.م / كل ٣ شهور',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.isArabic ? 'وديعة الصيانة ($_maintenanceFeePercent%):' : 'Maintenance Ratio:',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '${_formatPrice(maintenanceAmount)} ج.م (عند الاستلام 2026)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  // SPECIFICATIONS SECTION
  Widget _buildSpecificationsSection(
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    final primaryColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.isArabic ? 'مواصفات وتجهيزات العقار' : 'Property Specifications',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Area, Bedrooms, Bathrooms
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
                      onPlus: () {
                        if (_bedrooms < 8) setState(() => _bedrooms++);
                      },
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
                      onPlus: () {
                        if (_bathrooms < 6) setState(() => _bathrooms++);
                      },
                      theme: theme,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Floor Level & Elevator Row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.isArabic ? 'الدور والارتفاع' : 'Floor Level',
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
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : const Color(0xFFE2DDD5),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _floor,
                          isExpanded: true,
                          dropdownColor: isDark ? const Color(0xFF1E2838) : Colors.white,
                          items: _floorLevels.map((fl) => DropdownMenuItem(
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
                              ? primaryColor.withValues(alpha: isDark ? 0.22 : 0.12)
                              : (isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _hasElevator
                                ? primaryColor
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : const Color(0xFFE2DDD5)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _hasElevator
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 16,
                              color: _hasElevator ? primaryColor : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _hasElevator
                                  ? (l10n.isArabic ? 'متوفر' : 'Yes')
                                  : (l10n.isArabic ? 'لا يوجد' : 'No'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _hasElevator
                                    ? primaryColor
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
          const SizedBox(height: 16),

          // Finishing Status: [ بدون تشطيب | نصف تشطيب | تشطيب كامل | مفروش ]
          Text(
            l10n.isArabic ? 'حالة ونوع التشطيب' : 'Finishing Status',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F1B2B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _finishingStatuses.map((fin) {
              final id = fin['id']!;
              final title = l10n.isArabic ? fin['ar']! : fin['en']!;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _buildFinishingPill(
                    id: id,
                    title: title,
                    theme: theme,
                    isDark: isDark,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // MEDIA & VR SECTION
  Widget _buildMediaAndVRSection(
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    final primaryColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.photo_library_rounded, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.isArabic ? 'الصور والوسائط المرئية' : 'Media & Visuals',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                    ),
                  ),
                ],
              ),
              Text(
                '${_uploadedImages.length} صور مرفوعة',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Photo Upload Slots
          SizedBox(
            height: 95,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                // Add photo slot
                GestureDetector(
                  onTap: () {
                    final nextImg = _mockPhotoPool[
                        _uploadedImages.length % _mockPhotoPool.length];
                    setState(() {
                      _uploadedImages.add(nextImg);
                    });
                    _showToast(l10n.isArabic
                        ? 'تمت إضافة صورة واقعية بنجاح'
                        : 'Property photo added');
                  },
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded, color: primaryColor, size: 26),
                        const SizedBox(height: 4),
                        Text(
                          l10n.isArabic ? 'إضافة صورة' : 'Add Photo',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Uploaded Thumbnails
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
                          child: CachedNetworkImage(
                            imageUrl: imgUrl,
                            width: 90,
                            height: 95,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                        // Cover Badge for index 0
                        if (idx == 0)
                          Positioned(
                            bottom: 4,
                            left: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.isArabic ? 'الرئيسية' : 'Cover',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        // Remove Button
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              if (_uploadedImages.length > 1) {
                                setState(() => _uploadedImages.removeAt(idx));
                              } else {
                                _showToast(l10n.isArabic
                                    ? 'يجب الإبقاء على صورة واحدة على الأقل'
                                    : 'Keep at least one photo');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
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
          const SizedBox(height: 14),

          // VR / 360 Virtual Tour Toggle Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hasVirtualTour360
                    ? primaryColor.withValues(alpha: 0.5)
                    : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.view_in_ar_rounded, color: primaryColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.isArabic ? 'جولة واقع افتراضي 360°' : '360° Virtual Tour Available',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.isArabic
                            ? 'يزيد تفاعل المشترين والمستثمرين بنسبة 60%'
                            : 'Boosts buyer engagement by over 60%',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _hasVirtualTour360,
                  activeThumbColor: primaryColor,
                  onChanged: (val) => setState(() => _hasVirtualTour360 = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BILINGUAL DETAILS SECTION
  Widget _buildBilingualDetailsSection(
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    final primaryColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate_rounded, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.isArabic ? 'العناوين والوصف (ثنائي اللغة)' : 'Bilingual Details (AR / EN)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title AR
          _buildTextField(
            controller: _titleArController,
            label: l10n.isArabic ? 'عنوان الإعلان بالعربية *' : 'Title in Arabic *',
            hint: 'مثال: شقة للبيع في التجمع الخامس (ماونتن فيو)',
            textDirection: TextDirection.rtl,
            theme: theme,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          // Title EN
          _buildTextField(
            controller: _titleEnController,
            label: l10n.isArabic ? 'Title in English (باللغة الإنجليزية)' : 'Title in English',
            hint: 'e.g. Luxury Apartment for Sale in New Cairo',
            textDirection: TextDirection.ltr,
            theme: theme,
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // Desc AR
          _buildTextField(
            controller: _descArController,
            label: l10n.isArabic ? 'وصف العقار بالعربية' : 'Description in Arabic',
            hint: 'اكتب مواصفات العقار، نوع التشطيب، الإطلالة، والخدمات...',
            textDirection: TextDirection.rtl,
            maxLines: 3,
            theme: theme,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          // Desc EN
          _buildTextField(
            controller: _descEnController,
            label: l10n.isArabic ? 'Description in English (الوصف بالإنجليزية)' : 'Description in English',
            hint: 'Property features, view, finishes, and compound amenities...',
            textDirection: TextDirection.ltr,
            maxLines: 3,
            theme: theme,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // CONTACT INFO SECTION
  Widget _buildContactInfoSection(
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    final primaryColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_phone_rounded, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.isArabic ? 'بيانات التواصل للمعلن' : 'Publisher Contact Info',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F1B2B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildTextField(
            controller: _advertiserNameController,
            label: l10n.isArabic ? 'اسم المعلن / الوكيل' : 'Publisher Name',
            hint: 'ساري المنصور',
            theme: theme,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          _buildTextField(
            controller: _advertiserPhoneController,
            label: l10n.isArabic ? 'رقم الهاتف للتواصل' : 'Contact Phone Number',
            hint: '+201206667376',
            keyboardType: TextInputType.phone,
            theme: theme,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // WhatsApp Toggle
          GestureDetector(
            onTap: () => setState(() => _isWhatsAppEnabled = !_isWhatsAppEnabled),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isWhatsAppEnabled
                    ? const Color(0xFF10B981).withValues(alpha: isDark ? 0.18 : 0.1)
                    : (isDark ? const Color(0xFF1E2838) : const Color(0xFFF3F0EA)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isWhatsAppEnabled
                      ? const Color(0xFF10B981)
                      : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2DDD5)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_rounded,
                    color: _isWhatsAppEnabled ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.isArabic
                          ? 'تفعيل زر واتساب المباشر للرد الفوري على المشترين'
                          : 'Enable direct WhatsApp button for instant leads',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _isWhatsAppEnabled
                            ? (isDark ? Colors.white : const Color(0xFF0F1B2B))
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Icon(
                    _isWhatsAppEnabled
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: _isWhatsAppEnabled ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
          title: l10n.isArabic ? 'باقة عادية (مجاناً)' : 'Standard Tier',
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
          title: l10n.isArabic ? 'الباقة المميزة "Featured"' : 'Featured Tier',
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
              ? 'دفع فوري آمن ومحمي بأعلى معايير الأمان المصرفية لتفعيل الإعلان فورياً.'
              : 'Secure encrypted card processing powered by Central Bank standards.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 16),

        // Payment Method Selector
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
                      ? 'يمكنك التوجه لأي منفذ فوري أو الدفع عبر MyFawry / إنستاباي لتفعيل الإعلان فورياً.'
                      : 'Pay at any Fawry retail outlet, or through MyFawry app / InstaPay for instant publishing.',
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
              // Card Brand
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
                    _completeSubmission();
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
    String? subtitle,
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? primaryColor
                    : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? primaryColor.withValues(alpha: 0.8)
                      : (isDark ? AppColors.textMuted : const Color(0xFF94A3B8)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    String id,
    String label,
    IconData icon,
    ThemeData theme,
    bool isDark,
  ) {
    final isSelected = _propertyType == id;
    final primaryColor = theme.colorScheme.primary;

    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected
            ? primaryColor
            : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
      ),
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
