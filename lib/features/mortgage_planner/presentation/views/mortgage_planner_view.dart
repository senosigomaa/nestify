import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nestify/core/localization/app_localizations.dart';

/// EgyptianMortgagePlannerView provides an authentic, comprehensive
/// mortgage and installment planner tailored for the Cairo & Giza property market.
/// Replaces the unrealistic co-living hub with genuine Egyptian real-estate financing calculations.
class EgyptianMortgagePlannerView extends StatefulWidget {
  const EgyptianMortgagePlannerView({super.key});

  @override
  State<EgyptianMortgagePlannerView> createState() =>
      _EgyptianMortgagePlannerViewState();
}

class _EgyptianMortgagePlannerViewState extends State<EgyptianMortgagePlannerView> {
  // Property Price (in EGP)
  double _propertyPrice = 12000000.0; // 12M EGP default
  double _downPaymentPct = 10.0; // 10% default
  int _years = 8; // 8 years default
  bool _showQuarterly = false;
  int _financingMode = 0; // 0 = Developer Direct (0% Interest), 1 = CBE Mortgage Initiative (8%)

  // Preset Compounds
  final List<Map<String, dynamic>> _presets = const [
    {
      'name_ar': 'بالم هيلز (التجمع)',
      'name_en': 'Palm Hills (New Cairo)',
      'price': 14500000.0,
      'down': 10.0,
      'years': 8,
    },
    {
      'name_ar': 'سوديك فاي (زايد)',
      'name_en': 'SODIC VYE (Zayed)',
      'price': 24000000.0,
      'down': 10.0,
      'years': 7,
    },
    {
      'name_ar': 'البوسكو (العاصمة)',
      'name_en': 'Il Bosco (New Capital)',
      'price': 6800000.0,
      'down': 10.0,
      'years': 9,
    },
    {
      'name_ar': 'ماونتن فيو (آي سيتي)',
      'name_en': 'Mountain View (iCity)',
      'price': 8900000.0,
      'down': 10.0,
      'years': 8,
    },
  ];

  Future<void> _openWhatsAppAdvisor(BuildContext context) async {
    final l10n = context.l10n;
    final message = l10n.isArabic
        ? 'السلام عليكم، أود استشارة خبير تمويل عقاري بخصوص خطة سداد لوحدة بقيمة ${AppLocalizations.formatPrice(_propertyPrice, currencySymbol: "ج.م", isArabic: true)} مع مقدم ${_downPaymentPct.toInt()}% وتقسيط على $_years سنوات المعروضة في نيستيفاي.'
        : 'Hello, I would like to consult a mortgage advisor regarding a payment plan for a unit valued at ${AppLocalizations.formatPrice(_propertyPrice, currencySymbol: "EGP")} with ${_downPaymentPct.toInt()}% down payment over $_years years on Nestify.';

    const phone = '201206667376';
    final encodedMsg = Uri.encodeComponent(message);
    final whatsappUri = Uri.parse('https://wa.me/$phone?text=$encodedMsg');

    try {
      final launched = await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showToast(context, '${l10n.isArabic ? "واتساب المستشار" : "Advisor WhatsApp"}: +$phone');
      }
    } catch (_) {
      if (context.mounted) {
        _showToast(context, '${l10n.isArabic ? "واتساب المستشار" : "Advisor WhatsApp"}: +$phone');
      }
    }
  }

  Future<void> _callAdvisor(BuildContext context) async {
    final l10n = context.l10n;
    const phone = '+201206667376';
    final callUri = Uri.parse('tel:$phone');

    try {
      final launched = await launchUrl(callUri);
      if (!launched && context.mounted) {
        _showToast(context, '${l10n.isArabic ? "الاتصال بالمستشار" : "Call Advisor"}: $phone');
      }
    } catch (_) {
      if (context.mounted) {
        _showToast(context, '${l10n.isArabic ? "الاتصال بالمستشار" : "Call Advisor"}: $phone');
      }
    }
  }

  void _showToast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E3A2B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isArabic = l10n.isArabic;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    // Calculations based on financing mode:
    final downPaymentAmount = _propertyPrice * (_downPaymentPct / 100.0);
    final remainingPrincipal = _propertyPrice - downPaymentAmount;

    double monthlyPayment;
    final totalMonths = _years * 12;
    if (totalMonths <= 0) {
      monthlyPayment = 0.0;
    } else if (_financingMode == 0) {
      // Direct Developer: 0% Interest (Equal Installments)
      monthlyPayment = remainingPrincipal / totalMonths;
    } else {
      // CBE Mortgage Initiative (approx 8% annual diminishing rate)
      const annualRate = 0.08;
      final monthlyRate = annualRate / 12.0;
      monthlyPayment = (remainingPrincipal *
              monthlyRate *
              (1.0 + (monthlyRate * totalMonths))) /
          totalMonths;
    }
    if (!monthlyPayment.isFinite || monthlyPayment.isNaN || monthlyPayment < 0) {
      monthlyPayment = 0.0;
    }

    final quarterlyPayment = monthlyPayment * 3;
    final maintenanceDeposit = _propertyPrice * 0.08;
    final cashSavings = _propertyPrice * 0.25; // 25% cash discount average
    final cashPrice = _propertyPrice - cashSavings;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.translate('mortgage_planner_title'),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.translate('mortgage_planner_subtitle'),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calculate_rounded,
                      color: primaryColor,
                      size: 26,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Mode Tabs: Developer Direct vs Bank Mortgage
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141C2B) : const Color(0xFFEFECE5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _financingMode = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _financingMode == 0
                                ? (isDark ? theme.cardColor : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _financingMode == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            l10n.translate('developer_direct_tab'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: _financingMode == 0
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: _financingMode == 0
                                  ? primaryColor
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _financingMode = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _financingMode == 1
                                ? (isDark ? theme.cardColor : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _financingMode == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            l10n.translate('bank_mortgage_tab'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: _financingMode == 1
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: _financingMode == 1
                                  ? primaryColor
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Quick Presets
              Text(
                isArabic ? 'نماذج كمبوندات جاهزة للحساب:' : 'Quick Compound Presets:',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _presets.map((preset) {
                    final name = isArabic ? preset['name_ar'] : preset['name_en'];
                    final priceVal = preset['price'] as double;
                    final isSelected = (_propertyPrice - priceVal).abs() < 1000;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _propertyPrice = priceVal;
                          _downPaymentPct = (preset['down'] as double);
                          _years = (preset['years'] as int);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor.withValues(alpha: 0.18)
                              : theme.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                            width: isSelected ? 1.4 : 1,
                          ),
                        ),
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? primaryColor : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Property Price Slider
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.translate('total_price'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            AppLocalizations.formatPrice(_propertyPrice, currencySymbol: "ج.م", isArabic: isArabic),
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: primaryColor,
                        thumbColor: primaryColor,
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _propertyPrice,
                        min: 3000000.0,
                        max: 40000000.0,
                        divisions: 37,
                        onChanged: (val) => setState(() => _propertyPrice = val),
                      ),
                    ),

                    const Divider(height: 24),

                    // Down Payment %
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.translate('down_payment_slider'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_downPaymentPct.toInt()}% = ${AppLocalizations.formatPrice(downPaymentAmount, currencySymbol: "ج.م", isArabic: isArabic)}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: primaryColor,
                        thumbColor: primaryColor,
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _downPaymentPct,
                        min: 5.0,
                        max: 40.0,
                        divisions: 7,
                        onChanged: (val) => setState(() => _downPaymentPct = val),
                      ),
                    ),

                    const Divider(height: 24),

                    // Installment Duration (Years)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.translate('years_slider'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: secondaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isArabic ? '$_years سنوات (${_years * 12} شهر)' : '$_years Years (${_years * 12} Mos)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: secondaryColor),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: secondaryColor,
                        thumbColor: secondaryColor,
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _years.toDouble(),
                        min: 3.0,
                        max: 10.0,
                        divisions: 7,
                        onChanged: (val) => setState(() => _years = val.round()),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Cadence Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _showQuarterly = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: !_showQuarterly ? primaryColor : theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: !_showQuarterly ? primaryColor : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        l10n.translate('monthly_installment'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: !_showQuarterly ? Colors.black : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _showQuarterly = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _showQuarterly ? primaryColor : theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _showQuarterly ? primaryColor : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        l10n.translate('quarterly_installment'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _showQuarterly ? Colors.black : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Calculated Installment Highlight Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF1B2433),
                            const Color(0xFF141C2B),
                          ]
                        : [
                            const Color(0xFFF7F4ED),
                            Colors.white,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.45),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black45 : const Color(0x100F1B2B),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _showQuarterly
                              ? l10n.translate('quarterly_installment')
                              : l10n.translate('monthly_installment'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _financingMode == 0
                                ? (isArabic ? 'بدون فوائد 0%' : '0% Interest')
                                : (isArabic ? 'فائدة متناقصة 8%' : '8% Bank APR'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppLocalizations.formatPrice(
                          _showQuarterly ? quarterlyPayment : monthlyPayment,
                          currencySymbol: 'ج.م',
                          isArabic: isArabic,
                          isMonthly: !_showQuarterly,
                        ),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 14),

                    // Metrics Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.translate('down_payment'),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  AppLocalizations.formatPrice(
                                    downPaymentAmount,
                                    currencySymbol: 'ج.م',
                                    isArabic: isArabic,
                                  ),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 28, color: theme.dividerColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.translate('remaining_amount'),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  AppLocalizations.formatPrice(
                                    remainingPrincipal,
                                    currencySymbol: 'ج.م',
                                    isArabic: isArabic,
                                  ),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 28, color: theme.dividerColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.translate('maintenance_fee'),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '8% (${AppLocalizations.formatPrice(maintenanceDeposit, currencySymbol: "ج.م", isArabic: isArabic)})',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Cash Upfront Incentive Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF14241C) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flash_on_rounded, color: Color(0xFF2E7D32), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'خيار السداد كاش (خصم 25% فوري)' : 'Cash Payment Option (25% Instant Discount)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isArabic
                                ? 'ادفع كاش ووفر ${AppLocalizations.formatPrice(cashSavings, currencySymbol: "ج.م", isArabic: true)} (السعر بعد الخصم: ${AppLocalizations.formatPrice(cashPrice, currencySymbol: "ج.م", isArabic: true)})'
                                : 'Pay cash and save ${AppLocalizations.formatPrice(cashSavings, currencySymbol: "EGP")} (Cash price: ${AppLocalizations.formatPrice(cashPrice, currencySymbol: "EGP")})',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : const Color(0xFF1B5E20)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Lead Generation Buttons
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () => _openWhatsAppAdvisor(context),
                icon: const Icon(Icons.chat_bubble_rounded, size: 20),
                label: Text(
                  l10n.translate('consult_mortgage_expert'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor, width: 1.4),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _callAdvisor(context),
                icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                label: Text(
                  isArabic ? 'اتصال مباشر بمستشار التمويل العقاري' : 'Direct Call to Mortgage Advisor',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
