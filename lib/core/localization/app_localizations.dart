import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// AppLocalizations handles full bilingual localization (English & Arabic)
/// with automatic RTL directionality support for commercial-grade PropTech.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  bool get isArabic => locale.languageCode == 'ar';

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App branding
      'app_name': 'NESTIFY',
      'app_tagline': 'PROPTECH MARKETPLACE',

      // Navigation
      'nav_marketplace': 'Marketplace',
      'nav_explore': 'Discover',
      'nav_map': 'Map & Radar',
      'nav_coliving': 'Co-Invest',
      'nav_portfolio': 'Portfolio',
      'nav_profile': 'Profile',

      // Marketplace & Header
      'for_sale': 'For Sale',
      'for_rent': 'For Rent',
      'search_placeholder': 'Search compounds, areas, developers...',
      'mode_switch_swipe': 'Swipe Mode',
      'mode_switch_market': 'Marketplace Mode',
      'select_location': 'Select Location',
      'new_cairo': 'New Cairo (5th Settlement)',
      'sheikh_zayed': 'Sheikh Zayed & October',
      'new_capital': 'New Administrative Capital',
      'riyadh': 'Riyadh (Al Malqa & KAFD)',
      'dubai': 'Dubai (Marina & Downtown)',

      // Categories
      'cat_all': 'All Units',
      'cat_villas': 'Standalone Villas',
      'cat_apartments': 'Penthouses',
      'cat_townhouse': 'Townhouses',
      'cat_studios': 'Youth Studios',
      'cat_commercial': 'Commercial & Offices',

      // Hero Compound Launches
      'exclusive_launches': 'Exclusive Compound Launches',
      'discount_cash': '30% Cash Discount',
      'zero_down': '0% Down Payment',
      'delivery_2026': 'Delivery 2026',
      'installments_8y': 'Up to 8 Yrs Installments',

      // Marketplace Sections
      'section_for_sale': 'Featured Properties for Sale',
      'section_for_rent': 'Turnkey Luxury Rentals',
      'section_hot_deals': 'Hot High-Yield Investment Deals',
      'view_all': 'View All',

      // Property & Financial Specs
      'down_payment': 'Down Payment',
      'monthly_installment': 'Monthly Installment',
      'developer': 'Developer',
      'furnished': 'Furnished',
      'unfurnished': 'Unfurnished',
      'lease_min': 'Min. Lease',
      'months': 'Months',
      'utilities_included': 'Utilities Included',
      'yield_roi': 'Expected Yield',
      'per_month': '/ mo',
      'sqm': 'm²',

      // Direct Connect (WhatsApp & Call)
      'whatsapp_chat': 'WhatsApp',
      'call_now': 'Direct Call',
      'chat_initiated': 'Opening WhatsApp chat with authorized spatial agent...',
      'call_initiated': 'Dialing authorized developer representative...',

      // Side-by-Side Comparison
      'compare_properties': 'Compare Units',
      'select_to_compare': 'Compare',
      'compare_btn': 'Side-by-Side Comparison',
      'comparing_units': 'Commercial Direct Comparison',
      'clear_compare': 'Clear',
      'metric_price': 'Total Price',
      'metric_price_sqm': 'Price per m²',
      'metric_down_payment': 'Down Payment',
      'metric_monthly': 'Monthly Note',
      'metric_delivery': 'Delivery Date',
      'metric_acoustic': 'Noise Level',
      'metric_yield': 'Rental Yield',

      // Badges
      'verified_100': '100% Verified Title',
      'virtual_tour_360': '360° Virtual Tour Available',
      'verified_badge': 'VERIFIED ARCHITECTURE',
      'vibe_match': 'VIBE',
      'vibe_match_title': 'Vibe Match',
      'beds': 'Beds',
      'baths': 'Baths',
      'noise': 'dB Noise',
      'coffee': 'm Coffee',
      'pet_friendly': 'Pet Friendly',
      'tap_details': 'Tap for Sun-Path & Virtual Style Switcher',
      'all_hubs': 'All Hubs',
      'filter_by_hub': 'Filter by Architectural Hub',
      'all_caught_up': 'All Caught Up!',
      'all_caught_up_desc':
          'You have explored all architectural listings in this sector. Reset your deck to re-evaluate, or check your saved portfolio.',
      'recharge_deck': 'Recharge Feed Deck',
      'saved_portfolio': 'Saved Portfolio',
      'no_saved_properties': 'No saved properties yet',
      'no_saved_desc': 'Swipe right on properties you love to save them here.',
      'properties_count': 'PROPERTIES',
      'like': 'LIKE',
      'pass': 'PASS',

      // Sun-path & Style
      'sun_path_title': 'Sun-Path Simulator',
      'morning_preset': 'Morning (08:00)',
      'noon_preset': 'Noon (12:00)',
      'sunset_preset': 'Golden Hour (17:00)',
      'shadow_factor': 'Shadow',
      'virtual_style_title': 'Virtual Style Switcher',
      'ai_rendering': 'AI RENDERING',

      // Co-Living & Calculator
      'smart_split_title': 'Smart Split Calculator',
      'co_buy': 'CO-BUY',
      'co_rent': 'CO-RENT',
      'co_investors': 'Co-Investors / Buyers',
      'roommates_sharing': 'Roommates Sharing',
      'persons': 'PERSONS',
      'each': 'EACH',
      'down_payment_target': 'Down Payment Target',
      'down_payment_person': 'Down Payment Per Person',
      'mortgage_share': 'Mortgage Note Share',
      'base_rent_split': 'Base Rent Split',
      'smart_utilities': 'Smart Utilities & Fiber',
      'total_monthly_person': 'TOTAL MONTHLY / PERSON',
      'all_inclusive_desc': 'All-inclusive housing commitment',
      'generate_term_sheet': 'Generate Co-Ownership Term Sheet',
      'share_split': 'Share Co-Living Split with Friends',
      'invite_copied': 'Co-Investment invite link copied to clipboard!',

      // Property Details
      'sqft': 'Sq Ft',
      'price_per_sqft': '/ sq ft',
      'acoustic_overview': 'Architectural Overview',
      'acoustic_diagnostic': 'Acoustic & Vibe Diagnostic',
      'book_vip_tour': 'Book VIP Tour',
      'coinvest_offer': 'Co-Invest / Offer',
      'offer_initialized': 'Smart Co-Offer protocol initialized!',
      'saved_to_portfolio': 'Saved to your Nestify portfolio!',

      // ROI & Investment
      'roi_title': 'Investment & Yield Analysis',
      'gross_yield': 'Gross Rental Yield',
      'annual_cashflow': 'Net Annual Cashflow',
      'capital_appreciation': '5-Yr Capital Growth',
      'breakeven': 'Break-Even Period',
      'years': 'Years',
      'expected_rent': 'Expected Monthly Rent',
      'occupancy_rate': 'Annual Occupancy Rate',
      'equity_growth_projected': 'Projected 5-Year Equity Value',

      // Booking Sheet
      'book_tour_title': 'Schedule Private Tour & VR Experience',
      'book_tour_subtitle':
          'Experience the property physically or via ultra-high fidelity spatial VR headset.',
      'tour_mode': 'Tour Format',
      'mode_physical': 'In-Person VIP Tour',
      'mode_vr': 'Immersive VR Walkthrough',
      'select_date': 'Select Date',
      'time_slot': 'Select Time Slot',
      'chauffeur_option': 'Private Luxury Chauffeur Escort',
      'chauffeur_desc': 'Mercedes EQS or Lucid Air pickup from your location',
      'vr_kit_option': 'Deliver Spatial VR Headset Kit',
      'vr_kit_desc': 'Pre-loaded Vision Pro kit delivered to your residence',
      'confirm_booking': 'Confirm Tour Reservation',
      'booking_confirmed': 'VIP Tour Confirmed! Details synced to calendar.',

      // Map Hub
      'map_title': 'Live Acoustic & Radar Map',
      'map_subtitle': 'Interactive neighborhood intelligence',
      'filter_quiet': 'Ultra-Quiet (<40 dB)',
      'filter_coffee': 'Specialty Coffee (<3m)',
      'filter_metro': 'Metro Transit (<5m)',
      'view_property': 'View Architecture',

      // Co-Invest Roommate Hub
      'coliving_hub_title': 'Co-Invest & Roommate Hub',
      'coliving_hub_subtitle': 'Verified partners co-purchasing luxury properties',
      'filter_all_partners': 'All Partners',
      'filter_remote_workers': 'Remote Workers',
      'filter_pet_lovers': 'Pet Lovers',
      'filter_founders': 'Tech Founders',
      'equity_target': 'Equity Target',
      'connect_partner': 'Connect & Join Group',
      'group_request_sent': 'Co-Investment group partnership request sent!',

      // Portfolio
      'tab_saved': 'Saved Properties',
      'tab_tours': 'Scheduled Tours',
      'tour_in': 'In',
      'days': 'Days',
      'chauffeur_assigned': 'VIP Chauffeur Assigned',
      'vr_kit_dispatched': 'VR Kit Dispatched',
      'cancel_tour': 'Cancel Tour',
      'reschedule': 'Reschedule',

      // Profile & Settings
      'profile_title': 'Profile & Preferences',
      'verified_investor': 'Verified PropTech Investor',
      'membership_tier': 'Black Card Member • Escrow Ready',
      'language_setting': 'App Language',
      'language_ar': 'العربية (Arabic)',
      'language_en': 'English',
      'noise_tolerance': 'Max Ambient Noise Tolerance',
      'preferred_style': 'Preferred Design Aesthetic',
      'contact_concierge': 'Contact Private Wealth Concierge',
      'hotline_call': 'Connecting to licensed private spatial advisor...',
    },
    'ar': {
      // App branding
      'app_name': 'نيستيفاي',
      'app_tagline': 'منصة العقارات الذكية الرائدة',

      // Navigation
      'nav_marketplace': 'السوق العقاري',
      'nav_explore': 'اكتشف',
      'nav_map': 'الخريطة والرادار',
      'nav_coliving': 'شريك السكن',
      'nav_portfolio': 'المحفظة',
      'nav_profile': 'حسابي',

      // Marketplace & Header
      'for_sale': 'للبيع',
      'for_rent': 'للإيجار',
      'search_placeholder': 'ابحث بالكمبوند، المنطقة، أو اسم المطور...',
      'mode_switch_swipe': 'سوايپ تفاعلي',
      'mode_switch_market': 'السوق الشامل',
      'select_location': 'اختر المنطقة',
      'new_cairo': 'التجمع الخامس (القاهرة الجديدة)',
      'sheikh_zayed': 'الشيخ زايد وأكتوبر',
      'new_capital': 'العاصمة الإدارية الجديدة',
      'riyadh': 'الرياض (الملقا ومركز الملك عبدالله)',
      'dubai': 'دبي (المارينا ووسط المدينة)',

      // Categories
      'cat_all': 'جميع الوحدات',
      'cat_villas': 'فلل مستقلة',
      'cat_apartments': 'شقق وبنتهاوس',
      'cat_townhouse': 'تاون هاوس',
      'cat_studios': 'استوديوهات شبابية',
      'cat_commercial': 'مكاتب إدارية وتجارية',

      // Hero Compound Launches
      'exclusive_launches': 'مشاريع حصرية ومجمعات كبرى',
      'discount_cash': 'خصم كاش 30%',
      'zero_down': 'بدون مقدم 0%',
      'delivery_2026': 'استلام 2026',
      'installments_8y': 'أقساط تصل 8 سنوات',

      // Marketplace Sections
      'section_for_sale': 'عقارات فاخرة للبيع',
      'section_for_rent': 'عقارات راقية للإيجار',
      'section_hot_deals': 'صفقات استثمارية ساخنة (عائد > 11%)',
      'view_all': 'عرض الكل',

      // Property & Financial Specs
      'down_payment': 'المقدم',
      'monthly_installment': 'القسط الشهري',
      'developer': 'المطور العقاري',
      'furnished': 'مفروش بالكامل',
      'unfurnished': 'غير مفروش',
      'lease_min': 'أدنى مدة تعاقد',
      'months': 'أشهر',
      'utilities_included': 'شامل الفواتير والإنترنت',
      'yield_roi': 'العائد الإيجاري المتوقع',
      'per_month': '/ شهر',
      'sqm': 'م²',

      // Direct Connect (WhatsApp & Call)
      'whatsapp_chat': 'واتساب فوري',
      'call_now': 'اتصال مباشر',
      'chat_initiated': 'جارٍ فتح محادثة واتساب مشفرة مع الوكيل المعتمد...',
      'call_initiated': 'جارٍ الاتصال المباشر بممثل المطور المعتمد...',

      // Side-by-Side Comparison
      'compare_properties': 'مقارنة العقارات',
      'select_to_compare': 'مقارنة',
      'compare_btn': 'مقارنة تفصيلية جنباً إلى جنب',
      'comparing_units': 'المقارنة التجارية الشاملة',
      'clear_compare': 'إلغاء المقارنة',
      'metric_price': 'السعر الإجمالي',
      'metric_price_sqm': 'سعر المتر²',
      'metric_down_payment': 'المقدم المطلوب',
      'metric_monthly': 'القسط الشهري',
      'metric_delivery': 'تاريخ الاستلام',
      'metric_acoustic': 'مستوى الهدوء الصوتي',
      'metric_yield': 'العائد الاستثماري',

      // Badges
      'verified_100': 'عقار موثق 100%',
      'virtual_tour_360': 'جولة افتراضية 360° متاحة',
      'verified_badge': 'عقار معماري موثق',
      'vibe_match': 'توافق',
      'vibe_match_title': 'نسبة توافق الأجواء',
      'beds': 'غرف',
      'baths': 'حمامات',
      'noise': 'ديسيبل ضوضاء',
      'coffee': 'د قهوة',
      'pet_friendly': 'مناسب للحيوانات',
      'tap_details': 'اضغط لمحاكي الشمس ومغير الطراز الافتراضي',
      'all_hubs': 'جميع المدن',
      'filter_by_hub': 'تصفية حسب المركز المعماري',
      'all_caught_up': 'تم استعراض الكل!',
      'all_caught_up_desc':
          'لقد شاهدت جميع العقارات المعمارية في هذا القطاع. أعد شحن القائمة للمراجعة أو استعرض محفظتك المحفوظة.',
      'recharge_deck': 'إعادة شحن قائمة العرض',
      'saved_portfolio': 'المحفظة العقارية المحفوظة',
      'no_saved_properties': 'لا توجد عقارات محفوظة بعد',
      'no_saved_desc': 'اسحب لليمين على العقارات التي تعجبك لحفظها هنا.',
      'properties_count': 'عقارات',
      'like': 'إعجاب',
      'pass': 'تخطي',

      // Sun-path & Style
      'sun_path_title': 'محاكي مسار الشمس والضوء',
      'morning_preset': 'الصباح (08:00)',
      'noon_preset': 'الظهيرة (12:00)',
      'sunset_preset': 'الساعة الذهبية (17:00)',
      'shadow_factor': 'الظل',
      'virtual_style_title': 'محاكي الطراز الافتراضي (ذكاء اصطناعي)',
      'ai_rendering': 'توليد ذكاء اصطناعي',

      // Co-Living & Calculator
      'smart_split_title': 'حاسبة التقسيم والاستثمار المشترك',
      'co_buy': 'شراء مشترك',
      'co_rent': 'إيجار مشترك',
      'co_investors': 'شركاء الشراء والاستثمار',
      'roommates_sharing': 'شركاء السكن المشترك',
      'persons': 'أشخاص',
      'each': 'لكل فرد',
      'down_payment_target': 'نسبة الدفعة الأولى المستهدفة',
      'down_payment_person': 'الدفعة الأولى لكل شريك',
      'mortgage_share': 'قسط التمويل الشهري للشخص',
      'base_rent_split': 'حصة الإيجار الأساسي',
      'smart_utilities': 'المرافق الذكية والإنترنت السريع',
      'total_monthly_person': 'إجمالي الالتزام الشهري / للفرد',
      'all_inclusive_desc': 'التزام سكني شامل المرافق والخدمات',
      'generate_term_sheet': 'إصدار اتفاقية الشراكة القانونية',
      'share_split': 'مشاركة تفاصيل التقسيم مع الأصدقاء',
      'invite_copied': 'تم نسخ رابط دعوة الشراكة الاستثمارية إلى الحافظة!',

      // Property Details
      'sqft': 'قدم²',
      'price_per_sqft': '/ قدم²',
      'acoustic_overview': 'النظرة المعمارية العامة',
      'acoustic_diagnostic': 'الفحص الصوتي وأجواء الحي',
      'book_vip_tour': 'حجز جولة VIP خاصة',
      'coinvest_offer': 'استثمار مشترك / تقديم عرض',
      'offer_initialized': 'تم بدء بروتوكول العرض الاستثماري المشترك!',
      'saved_to_portfolio': 'تم الحفظ في محفظتك في نيستيفاي!',

      // ROI & Investment
      'roi_title': 'تحليل العائد الاستثماري والنمو',
      'gross_yield': 'العائد الإيجاري الإجمالي',
      'annual_cashflow': 'صافي التدفق النقدي السنوي',
      'capital_appreciation': 'نمو رأس المال لـ 5 سنوات',
      'breakeven': 'فترة استرداد رأس المال',
      'years': 'سنوات',
      'expected_rent': 'الإيجار الشهري المتوقع',
      'occupancy_rate': 'نسبة الإشغال السنوية',
      'equity_growth_projected': 'القيمة المتوقعة لحقوق الملكية بعد 5 سنوات',

      // Booking Sheet
      'book_tour_title': 'جدولة جولة خاصة وتجربة الواقع الافتراضي',
      'book_tour_subtitle':
          'عايش العقار ميدانياً أو عبر نظارات الواقع الافتراضي المكانية فائقة الدقة.',
      'tour_mode': 'نوع الجولة',
      'mode_physical': 'جولة ميدانية VIP',
      'mode_vr': 'جولة واقع افتراضي مكاني (VR)',
      'select_date': 'تحديد التاريخ',
      'time_slot': 'تحديد الموعد',
      'chauffeur_option': 'مرافقة سيارة فاخرة مع سائق خاص',
      'chauffeur_desc': 'توصيل بسيارة مرسيدس EQS أو لوسيد إير من موقعك',
      'vr_kit_option': 'توصيل طقم نظارة الواقع الافتراضي',
      'vr_kit_desc': 'توصيل نظارة Apple Vision Pro مهيأة إلى مكان إقامتك',
      'confirm_booking': 'تأكيد حجز الجولة VIP',
      'booking_confirmed': 'تم تأكيد حجز الجولة VIP بنجاح! تمت المزامنة مع التقويم.',

      // Map Hub
      'map_title': 'خريطة الرادار الصوتي والمكاني',
      'map_subtitle': 'معلومات ذكية تفاعلية عن الأحياء',
      'filter_quiet': 'هدوء فائق (<40 ديسيبل)',
      'filter_coffee': 'قهوة مختصة (<3د)',
      'filter_metro': 'محطة المترو (<5د)',
      'view_property': 'استعراض العقار',

      // Co-Invest Roommate Hub
      'coliving_hub_title': 'بوابة شركاء السكن والاستثمار',
      'coliving_hub_subtitle': 'شركاء موثقون للاستحواذ المشترك على عقارات فاخرة',
      'filter_all_partners': 'جميع الشركاء',
      'filter_remote_workers': 'عمل عن بعد',
      'filter_pet_lovers': 'محبو الحيوانات',
      'filter_founders': 'رواد تقنية',
      'equity_target': 'حصة التملك',
      'connect_partner': 'تواصل وانضم للمجموعة',
      'group_request_sent': 'تم إرسال طلب الانضمام لمجموعة الاستثمار المشترك!',

      // Portfolio
      'tab_saved': 'العقارات المحفوظة',
      'tab_tours': 'الجولات المجدولة',
      'tour_in': 'خلال',
      'days': 'أيام',
      'chauffeur_assigned': 'تم تعيين السائق الخاص VIP',
      'vr_kit_dispatched': 'تم إرسال طقم الواقع الافتراضي',
      'cancel_tour': 'إلغاء الجولة',
      'reschedule': 'تغيير الموعد',

      // Profile & Settings
      'profile_title': 'الملف الشخصي والتفضيلات',
      'verified_investor': 'مستثمر موثق في نيستيفاي',
      'membership_tier': 'عضوية البلاك كارد • جاهز للضمان البنكي',
      'language_setting': 'لغة التطبيق',
      'language_ar': 'العربية (RTL)',
      'language_en': 'English (الإنجليزية)',
      'noise_tolerance': 'الحد الأقصى المسموح للضوضاء',
      'preferred_style': 'الطراز المعماري المفضل',
      'contact_concierge': 'التواصل مع مستشار إدارة الثروات العقارية',
      'hotline_call': 'جارٍ الاتصال بمستشار المساحات العقارية المعتمد...',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String key) => AppLocalizations.of(this).translate(key);
}
