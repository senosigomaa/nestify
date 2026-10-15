import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// High-fidelity mock property dataset tailored specifically for the Egyptian real estate market.
/// Enriched with premier Cairo & Giza compounds (New Cairo, Sheikh Zayed, New Capital),
/// genuine developers, authentic payment plans, finishing types, delivery dates, and cash discounts.
class MockPropertiesData {
  MockPropertiesData._();

  static final ValueNotifier<int> propertyChangeNotifier = ValueNotifier<int>(0);

  /// Add a newly published property to in-memory list and Hive storage
  static void addProperty(Map<String, dynamic> propertyJson) {
    rawProperties.removeWhere((p) => p['id'] == propertyJson['id']);
    rawProperties.insert(0, propertyJson);

    try {
      if (Hive.isBoxOpen('nestify_my_listings')) {
        final box = Hive.box('nestify_my_listings');
        box.put(propertyJson['id'], propertyJson);
      }
    } catch (_) {}

    propertyChangeNotifier.value++;
  }

  /// Initialize and prepend any previously saved listings from Hive
  static void initFromHive() {
    try {
      if (Hive.isBoxOpen('nestify_my_listings')) {
        final box = Hive.box('nestify_my_listings');
        for (final k in box.keys) {
          final val = box.get(k);
          if (val != null) {
            final Map<String, dynamic> map = val is Map
                ? Map<String, dynamic>.from(val)
                : Map<String, dynamic>.from(jsonDecode(val as String));
            if (!rawProperties.any((p) => p['id'] == map['id'])) {
              rawProperties.insert(0, map);
            }
          }
        }
      }
    } catch (_) {}
  }

  /// Retrieve user-published listings
  static List<Map<String, dynamic>> getMyPublishedListings() {
    final List<Map<String, dynamic>> results = [];
    try {
      if (Hive.isBoxOpen('nestify_my_listings')) {
        final box = Hive.box('nestify_my_listings');
        for (final k in box.keys) {
          final val = box.get(k);
          if (val != null) {
            final Map<String, dynamic> map = val is Map
                ? Map<String, dynamic>.from(val)
                : Map<String, dynamic>.from(jsonDecode(val as String));
            results.add(map);
          }
        }
      }
    } catch (_) {}

    // Also include any user-created properties currently in memory
    for (final p in rawProperties) {
      final id = p['id'] as String? ?? '';
      if (id.startsWith('user_prop_') && !results.any((r) => r['id'] == id)) {
        results.add(p);
      }
    }

    return results;
  }

  static final List<Map<String, dynamic>> rawProperties = [
    {
      'id': 'prop_001',
      'title': 'بنتهاوس فاخر في بالم هيلز (Sky Penthouse)',
      'neighborhood': 'التجمع الخامس، المربع الذهبي (New Cairo)',
      'compoundName': 'Palm Hills New Cairo',
      'price': 14500000.0,
      'priceType': 'buy',
      'images': [
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b?auto=format&fit=crop&w=1200&q=80',
      ],
      'vibeMatchPercentage': 98,
      'noiseLevelDb': 32,
      'coffeeShopProximityMins': 2,
      'petFriendly': true,
      'bedrooms': 4,
      'bathrooms': 4,
      'squareFeet': 3100, // ~288 sqm
      'isVerified': true,
      'description':
          'بنتهاوس راقٍ بإطلالة بانورامية مفتوحة على لاندسكيب المربع الذهبي، روف خاص مع حمام سباحة، وتجهيزات سمارت هوم. خطة سداد ميسرة 8 سنوات بدون فوائد مع خصم نقدي فوري 25%.',
      'commuteTechHubMins': 5,
      'walkScore': 98,
      'greenScore': 94,
      'nightlifeScore': 96,
      'sunOrientation': 'بحري صريح (North-Facing)',
      'developerName': 'بالم هيلز للتعمير (Palm Hills)',
      'downPaymentPrice': 1450000.0, // 10%
      'monthlyInstallmentPrice': 135937.0,
      'installmentYears': 8,
      'deliveryYear': 2026,
      'isFurnished': false,
      'rentalYieldPct': 12.8,
      'hasVirtualTour360': true,
      'category': 'apartment',
      'currencySymbol': 'ج.م',
      'contactPhone': '+201206667376',
      'contactWhatsApp': '+201206667376',
      'finishing': 'fully_finished',
      'delivery': 'ready_to_move',
      'maintenanceRatio': 0.08,
      'offeringType': 'primary',
      'cashDiscountPercent': 25,
      'isCashOnly': false,
      'isInvestmentOpportunity': true,
      'securityDepositMonths': 2,
      'minLeaseYears': 1,
      'rentalTerms': <String>[],
      'amenities': [
        'روف خاص بحمام سباحة',
        'إطلالة بحري مفتوحة',
        'كلوب هاوس وملاعب بادل',
        'جراج خاص تحت الأرض',
        'أمن وحراسة 24/7 وبوابات إلكترونية',
      ],
      'styleVariants': {
        'التصميم المودرن الفاخر':
            'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=1200&q=80',
        'التصميم النيوليبرالي العصري':
            'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=1200&q=80',
        'الطابع النوردي الدافئ':
            'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=1200&q=80',
        'الأرت ديكو الفندقي':
            'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=1200&q=80',
      },
    },
    {
      'id': 'prop_002',
      'title': 'فيلا مستقلة مودرن كمبوند سوديك فاي (SODIC VYE)',
      'neighborhood': 'الشيخ زايد الجديدة (New Zayed)',
      'compoundName': 'VYE SODIC',
      'price': 24000000.0,
      'priceType': 'buy',
      'images': [
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1200&q=80',
      ],
      'vibeMatchPercentage': 96,
      'noiseLevelDb': 26,
      'coffeeShopProximityMins': 4,
      'petFriendly': true,
      'bedrooms': 5,
      'bathrooms': 6,
      'squareFeet': 4200, // ~390 sqm
      'isVerified': true,
      'description':
          'فيلا مستقلة نموذج فريد في قلب الحزام الأخضر كمبوند VYE الشيخ زايد، حديقة خاصة 280م مع حمام سباحة انفينيتي، ومحطة طاقة شمسية. تسليم فوري كاش فقط نصف تشطيب.',
      'commuteTechHubMins': 7,
      'walkScore': 95,
      'greenScore': 99,
      'nightlifeScore': 87,
      'sunOrientation': 'واجهة قبلية بحرية',
      'developerName': 'سوديك للتطوير العقاري (SODIC)',
      'downPaymentPrice': 0.0,
      'monthlyInstallmentPrice': 0.0,
      'installmentYears': 0,
      'deliveryYear': 2026,
      'isFurnished': false,
      'rentalYieldPct': 11.2,
      'hasVirtualTour360': true,
      'category': 'villa',
      'currencySymbol': 'ج.م',
      'contactPhone': '+201206667376',
      'contactWhatsApp': '+201206667376',
      'finishing': 'semi_finished',
      'delivery': 'ready_to_move',
      'maintenanceRatio': 0.08,
      'offeringType': 'resale',
      'cashDiscountPercent': 22,
      'isCashOnly': true,
      'isInvestmentOpportunity': false,
      'securityDepositMonths': 2,
      'minLeaseYears': 1,
      'rentalTerms': <String>[],
      'amenities': [
        'حديقة خاصة واسعة 280م',
        'حمام سباحة إنفينيتي خاص',
        'طاقة شمسية وشاحن سيارة كهربائية',
        'غرفة سائق وغرفة خادمة ماستر',
        'خدمات فندقية وكلوب هاوس سوديك',
      ],
      'styleVariants': {
        'التصميم المودرن الفاخر':
            'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=1200&q=80',
        'التصميم النيوليبرالي العصري':
            'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=1200&q=80',
        'الطابع النوردي الدافئ':
            'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=1200&q=80',
        'الأرت ديكو الفندقي':
            'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=1200&q=80',
      },
    },
    {
      'id': 'prop_003',
      'title': 'شقة لاجون بيتش ماونتن فيو أي سيتي (iCity Lagoon)',
      'neighborhood': 'التجمع الخامس، القاهرة الجديدة (New Cairo)',
      'compoundName': 'Mountain View iCity',
      'price': 8900000.0,
      'priceType': 'buy',
      'images': [
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
      ],
      'vibeMatchPercentage': 97,
      'noiseLevelDb': 30,
      'coffeeShopProximityMins': 1,
      'petFriendly': true,
      'bedrooms': 3,
      'bathrooms': 3,
      'squareFeet': 1950, // ~180 sqm
      'isVerified': true,
      'description':
          'شقة بإطلالة مباشرة ومميزة على البحيرة الرملية الكريستالية (Crystal Lagoon). تشطيب كامل سوبر لوكس من ماونتن فيو، مع مقدم 10% وقسط ممتد 8 سنوات.',
      'commuteTechHubMins': 3,
      'walkScore': 97,
      'greenScore': 96,
      'nightlifeScore': 92,
      'sunOrientation': 'بحري على اللاجون',
      'developerName': 'ماونتن فيو للتنمية والاستثمار',
      'downPaymentPrice': 890000.0, // 10%
      'monthlyInstallmentPrice': 83437.0,
      'installmentYears': 8,
      'deliveryYear': 2027,
      'isFurnished': false,
      'rentalYieldPct': 13.4,
      'hasVirtualTour360': true,
      'category': 'apartment',
      'currencySymbol': 'ج.م',
      'contactPhone': '+201206667376',
      'contactWhatsApp': '+201206667376',
      'finishing': 'fully_finished',
      'delivery': '2027',
      'maintenanceRatio': 0.08,
      'offeringType': 'primary',
      'cashDiscountPercent': 27,
      'isCashOnly': false,
      'isInvestmentOpportunity': false,
      'securityDepositMonths': 2,
      'minLeaseYears': 1,
      'rentalTerms': <String>[],
      'amenities': [
        'إطلالة مباشرة على الكريستال لاجون',
        'شاطئ رملي خاص وممشى سياحي',
        'مرافق رياضية وملاعب بادل',
        'نظام جزيرة السيارات بدون ضوضاء',
        'منطقة مطاعم وكافيهات عالمية',
      ],
      'styleVariants': {
        'التصميم المودرن الفاخر':
            'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=1200&q=80',
        'التصميم النيوليبرالي العصري':
            'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=1200&q=80',
        'الطابع النوردي الدافئ':
            'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=1200&q=80',
        'الأرت ديكو الفندقي':
            'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=1200&q=80',
      },
    },
    {
      'id': 'prop_004',
      'title': 'دوبلكس فاخر بكمبوند البوسكو الغابة الرأسية (Il Bosco)',
      'neighborhood': 'الحي السكني R7، العاصمة الإدارية (New Capital)',
      'compoundName': 'Il Bosco New Capital',
      'price': 6800000.0,
      'priceType': 'buy',
      'images': [
        'https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1200&q=80',
      ],
      'vibeMatchPercentage': 95,
      'noiseLevelDb': 28,
      'coffeeShopProximityMins': 2,
      'petFriendly': true,
      'bedrooms': 3,
      'bathrooms': 3,
      'squareFeet': 2300, // ~215 sqm
      'isVerified': true,
      'description':
          'دوبلكس بإطلالة مباشرة على النهر الأخضر ومحور بن زايد في كمبوند البوسكو الشهير بالغابات الرأسية، ألترا سوبر لوكس، قسط مريح على 9 سنوات وخصم كاش يصل لـ 30%.',
      'commuteTechHubMins': 3,
      'walkScore': 96,
      'greenScore': 98,
      'nightlifeScore': 90,
      'sunOrientation': 'بحري غربي على النهر الأخضر',
      'developerName': 'مصر إيطاليا العقارية (Misr Italia)',
      'downPaymentPrice': 680000.0, // 10%
      'monthlyInstallmentPrice': 56666.0,
      'installmentYears': 9,
      'deliveryYear': 2026,
      'isFurnished': false,
      'rentalYieldPct': 13.8,
      'hasVirtualTour360': true,
      'category': 'townhouse',
      'currencySymbol': 'ج.م',
      'contactPhone': '+201206667376',
      'contactWhatsApp': '+201206667376',
      'finishing': 'ultra_lux',
      'delivery': '2026',
      'maintenanceRatio': 0.09,
      'offeringType': 'primary',
      'cashDiscountPercent': 30,
      'isCashOnly': false,
      'isInvestmentOpportunity': true,
      'securityDepositMonths': 2,
      'minLeaseYears': 1,
      'rentalTerms': <String>[],
      'amenities': [
        'إطلالة بانورامية على النهر الأخضر',
        'قريب جداً من محطة المونوريل والحي الدبلوماسي',
        'تراس كبير وغابات معلقة',
        'كلوب هاوس سنترال بارك',
        'سمارت هوم متكامل',
      ],
      'styleVariants': {
        'التصميم المودرن الفاخر':
            'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=1200&q=80',
        'التصميم النيوليبرالي العصري':
            'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=1200&q=80',
        'الطابع النوردي الدافئ':
            'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=1200&q=80',
        'الأرت ديكو الفندقي':
            'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=1200&q=80',
      },
    },
    {
      'id': 'prop_005',
      'title': 'شقة فندقية فاخرة في أبراج زد الشيخ زايد (Zed Towers)',
      'neighborhood': 'الحديقة المركزية، الشيخ زايد (Sheikh Zayed)',
      'compoundName': 'Zed Towers Sheikh Zayed',
      'price': 16500000.0,
      'priceType': 'buy',
      'images': [
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
      ],
      'vibeMatchPercentage': 97,
      'noiseLevelDb': 33,
      'coffeeShopProximityMins': 1,
      'petFriendly': true,
      'bedrooms': 3,
      'bathrooms': 3,
      'squareFeet': 2100, // ~195 sqm
      'isVerified': true,
      'description':
          'شقة تشطيب كامل بأعلى معايير الفخامة العالمية بالتكييفات وخزائن المطبخ في أبراج زد، إطلالة مباشرة على حديقة الشيخ زايد المركزية. البيع كاش فقط شامل وديعة الصيانة ورسوم التنازل.',
      'commuteTechHubMins': 2,
      'walkScore': 99,
      'greenScore': 97,
      'nightlifeScore': 95,
      'sunOrientation': 'واجهة بحرية على الحديقة المركزية',
      'developerName': 'أورا للتطوير العقاري (ORA Developers)',
      'downPaymentPrice': 0.0,
      'monthlyInstallmentPrice': 0.0,
      'installmentYears': 0,
      'deliveryYear': 2026,
      'isFurnished': true,
      'rentalYieldPct': 14.5,
      'hasVirtualTour360': true,
      'category': 'apartment',
      'currencySymbol': 'ج.م',
      'contactPhone': '+201206667376',
      'contactWhatsApp': '+201206667376',
      'finishing': 'fully_finished',
      'delivery': 'ready_to_move',
      'maintenanceRatio': 0.10,
      'offeringType': 'resale',
      'cashDiscountPercent': 20,
      'isCashOnly': true,
      'isInvestmentOpportunity': false,
      'securityDepositMonths': 2,
      'minLeaseYears': 1,
      'rentalTerms': <String>[],
      'amenities': [
        'تشطيب فندقي متكامل بالتكييفات',
        'إطلالة غير محجوبة على حديقة زد 65 فدان',
        'كونسيرج وخدمات فندقية 24 ساعة',
        'مصاعد فائقة السرعة وجراج خاص',
        'مطاعم ومحلات تجارية راقية بالأبراج',
      ],
      'styleVariants': {
        'التصميم المودرن الفاخر':
            'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=1200&q=80',
        'التصميم النيوليبرالي العصري':
            'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=1200&q=80',
        'الطابع النوردي الدافئ':
            'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=1200&q=80',
        'الأرت ديكو الفندقي':
            'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=1200&q=80',
      },
    },
    {
      'id': 'prop_006',
      'title': 'تاون هاوس سيجنتشر هايد بارك (Hyde Park Signature)',
      'neighborhood': 'شارع التسعين، التجمع الخامس (Golden Square)',
      'compoundName': 'Hyde Park New Cairo',
      'price': 13200000.0,
      'priceType': 'buy',
      'images': [
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1200&q=80',
      ],
      'vibeMatchPercentage': 94,
      'noiseLevelDb': 29,
      'coffeeShopProximityMins': 3,
      'petFriendly': true,
      'bedrooms': 4,
      'bathrooms': 4,
      'squareFeet': 2950, // ~274 sqm
      'isVerified': true,
      'description':
          'تاون هاوس كورنر على الحديقة المركزية مباشرة بمساحة 141 فدان في كمبوند هايد بارك التجمع الخامس. بدون تشطيب (Core & Shell) لتصممه على ذوقك الخاص، بمقدم 5% فقط وأقساط متساوية 8 سنوات.',
      'commuteTechHubMins': 6,
      'walkScore': 94,
      'greenScore': 99,
      'nightlifeScore': 91,
      'sunOrientation': 'بحري شرقي على البارك',
      'developerName': 'هايد بارك للتطوير العقاري (Hyde Park)',
      'downPaymentPrice': 660000.0, // 5%
      'monthlyInstallmentPrice': 130625.0,
      'installmentYears': 8,
      'deliveryYear': 2027,
      'isFurnished': false,
      'rentalYieldPct': 12.1,
      'hasVirtualTour360': true,
      'category': 'townhouse',
      'currencySymbol': 'ج.م',
      'contactPhone': '+201206667376',
      'contactWhatsApp': '+201206667376',
      'finishing': 'core_and_shell',
      'delivery': '2027',
      'maintenanceRatio': 0.08,
      'offeringType': 'primary',
      'cashDiscountPercent': 25,
      'isCashOnly': false,
      'isInvestmentOpportunity': false,
      'securityDepositMonths': 2,
      'minLeaseYears': 1,
      'rentalTerms': <String>[],
      'amenities': [
        'إطلالة مباشرة على هايد بارك 141 فدان',
        'حديقة خاصة وتراس روف واسع',
        'مسار مشي وركوب دراجات خاص',
        'أكاديميات رياضية وملاعب بادل',
        'بوابات أمن ذكية 24/7',
      ],
      'styleVariants': {
        'التصميم المودرن الفاخر':
            'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=1200&q=80',
        'التصميم النيوليبرالي العصري':
            'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=1200&q=80',
        'الطابع النوردي الدافئ':
            'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=1200&q=80',
        'الأرت ديكو الفندقي':
            'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=1200&q=80',
      },
    },
    {
      'id': 'prop_007',
      'title': 'شقة مفروشة ألترا لوكس للإيجار في مدينتي B8',
      'neighborhood': 'منطقة B8 الفاخرة، مدينتي (Madinaty)',
      'compoundName': 'Madinaty Talaat Moustafa',
      'price': 45000.0,
      'priceType': 'rent',
      'images': [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=1200&q=80',
      ],
      'vibeMatchPercentage': 96,
      'noiseLevelDb': 27,
      'coffeeShopProximityMins': 3,
      'petFriendly': true,
      'bedrooms': 3,
      'bathrooms': 2,
      'squareFeet': 1750, // ~162 sqm
      'isVerified': true,
      'description':
          'شقة مفروشة بالكامل بأثاث ومفروشات ألترا مودرن جديدة لم تسكن من قبل، مكيفة بالكامل مع جميع الأجهزة الكهربائية الحديثة، إطلالة مفتوحة على الوايد جاردن والممشى السياحي بمدينتي.',
      'commuteTechHubMins': 5,
      'walkScore': 95,
      'greenScore': 98,
      'nightlifeScore': 85,
      'sunOrientation': 'بحري صريح على الحدائق',
      'developerName': 'مجموعة طلعت مصطفى (TMG)',
      'downPaymentPrice': 0.0,
      'monthlyInstallmentPrice': 0.0,
      'installmentYears': 0,
      'deliveryYear': 2026,
      'isFurnished': true,
      'rentalYieldPct': 15.2,
      'hasVirtualTour360': true,
      'category': 'apartment',
      'currencySymbol': 'ج.م',
      'contactPhone': '+201206667376',
      'contactWhatsApp': '+201206667376',
      'finishing': 'fully_finished',
      'delivery': 'ready_to_move',
      'maintenanceRatio': 0.0,
      'offeringType': 'resale',
      'cashDiscountPercent': 0,
      'isCashOnly': false,
      'isInvestmentOpportunity': false,
      'securityDepositMonths': 2,
      'minLeaseYears': 1,
      'rentalTerms': [
        'عائلات فقط (Families Only)',
        'شامل مصاريف الصيانة والأمن',
        'مفروشة بالكامل ومكيفة بأحدث الأجهزة',
        'عقد إيجار سنوي موثق قابل للتجديد',
      ],
      'amenities': [
        'مفروشة بالكامل أثاث إيطالي فاخر',
        'جميع الأجهزة الكهربائية وشاشات سمارت',
        'إنترنت ألياف ضوئية فائق السرعة',
        'جراج سيارات خاص بالبلوك',
        'قريبة من الساوث بارك ومسجد مدينتي',
      ],
      'styleVariants': {
        'التصميم المودرن الفاخر':
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1200&q=80',
      },
    },
    {
      'id': 'prop_008',
      'title': 'دوبلكس فندقي بجاردن للإيجار في ووتر واي (The Waterway)',
      'neighborhood': 'التجمع الخامس، شارع التسعين الشمالي (New Cairo)',
      'compoundName': 'The Waterway New Cairo',
      'price': 85000.0,
      'priceType': 'rent',
      'images': [
        'https://images.unsplash.com/photo-1600585154526-990dced4db0d?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600566752355-35792bedcfea?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600607687644-c7171b42498f?auto=format&fit=crop&w=1200&q=80',
      ],
      'vibeMatchPercentage': 99,
      'noiseLevelDb': 31,
      'coffeeShopProximityMins': 1,
      'petFriendly': true,
      'bedrooms': 3,
      'bathrooms': 4,
      'squareFeet': 2700, // ~250 sqm
      'isVerified': true,
      'description':
          'دوبلكس أرضي مع حديقة خاصة 90م في أرقى كمبوند فندقي بالقاهرة الجديدة (ووتر واي)، حمام سباحة خاص، تشطيب كونسيبت عالمي مع تكييف مركزي ومطبخ مستورد مجهز بالكامل.',
      'commuteTechHubMins': 2,
      'walkScore': 99,
      'greenScore': 96,
      'nightlifeScore': 98,
      'sunOrientation': 'واجهة بحرية غربية',
      'developerName': 'إكويتي للتطوير العقاري (Equity - The Waterway)',
      'downPaymentPrice': 0.0,
      'monthlyInstallmentPrice': 0.0,
      'installmentYears': 0,
      'deliveryYear': 2026,
      'isFurnished': true,
      'rentalYieldPct': 14.8,
      'hasVirtualTour360': true,
      'category': 'apartment',
      'currencySymbol': 'ج.م',
      'contactPhone': '+201206667376',
      'contactWhatsApp': '+201206667376',
      'finishing': 'ultra_lux',
      'delivery': 'ready_to_move',
      'maintenanceRatio': 0.0,
      'offeringType': 'resale',
      'cashDiscountPercent': 0,
      'isCashOnly': false,
      'isInvestmentOpportunity': false,
      'securityDepositMonths': 2,
      'minLeaseYears': 1,
      'rentalTerms': [
        'عائلات ودبلوماسيين فقط',
        'شامل مصاريف الصيانة والحديقة الخاصة',
        'مفروشة ألترا لوكس بالكامل',
        'الحد الأدنى للتعاقد سنة واحدة',
      ],
      'amenities': [
        'حديقة خاصة 90م مع باربيكيو زون',
        'تكييف مركزي متكامل ونظام صوتي',
        'ووتر واي ستريب مول ومطاعم فاخرة',
        'أمن حراسة كونسيرج 24/7',
        'حمام سباحة خاص بالجاردن',
      ],
      'styleVariants': {
        'التصميم المودرن الفاخر':
            'https://images.unsplash.com/photo-1600585154526-990dced4db0d?auto=format&fit=crop&w=1200&q=80',
      },
    },
    {
      'id': 'prop_009',
      'title': 'فيلا ستاند ألون فاخرة للإيجار في بالم هيلز الشيخ زايد',
      'neighborhood': 'بالم هيلز، الشيخ زايد (Sheikh Zayed)',
      'compoundName': 'Palm Hills Golf Views Zayed',
      'price': 160000.0,
      'priceType': 'rent',
      'images': [
        'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
      ],
      'vibeMatchPercentage': 98,
      'noiseLevelDb': 24,
      'coffeeShopProximityMins': 3,
      'petFriendly': true,
      'bedrooms': 5,
      'bathrooms': 6,
      'squareFeet': 5200, // ~483 sqm
      'isVerified': true,
      'description':
          'فيلا مستقلة صف أول مباشر على ملاعب الجولف العالمية في بالم هيلز الشيخ زايد. حديقة واسعة 600م مع حمام سباحة مدفأ، غرفة سينما منزلية، أجنحة ماستر للمعيشة الفاخرة.',
      'commuteTechHubMins': 5,
      'walkScore': 93,
      'greenScore': 99,
      'nightlifeScore': 89,
      'sunOrientation': 'بحري صريح على الجولف',
      'developerName': 'بالم هيلز للتعمير (Palm Hills)',
      'downPaymentPrice': 0.0,
      'monthlyInstallmentPrice': 0.0,
      'installmentYears': 0,
      'deliveryYear': 2026,
      'isFurnished': true,
      'rentalYieldPct': 10.9,
      'hasVirtualTour360': true,
      'category': 'villa',
      'currencySymbol': 'ج.م',
      'contactPhone': '+201206667376',
      'contactWhatsApp': '+201206667376',
      'finishing': 'ultra_lux',
      'delivery': 'ready_to_move',
      'maintenanceRatio': 0.0,
      'offeringType': 'resale',
      'cashDiscountPercent': 0,
      'isCashOnly': false,
      'isInvestmentOpportunity': false,
      'securityDepositMonths': 3,
      'minLeaseYears': 1,
      'rentalTerms': [
        'عائلات وسفارات فقط',
        'شامل صيانة حمام السباحة ولاندسكيب الجاردن',
        'مفروشة بالكامل أثاث فندقي فاخر',
        'تأمين تعاقدي 3 أشهر مسترد عند انتهاء العقد',
      ],
      'amenities': [
        'إطلالة مباشرة غير محجوبة على ملاعب الجولف',
        'حمام سباحة خاص مدفأ إنفينيتي',
        'حديقة خاصة منسقة بنظام ري أوتوماتيك',
        'سكن مستقل للسائق والخادمة',
        'اشتراك كلوب هاوس بالم هيلز',
      ],
      'styleVariants': {
        'التصميم المودرن الفاخر':
            'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&w=1200&q=80',
      },
    },
    {
      'id': 'prop_010',
      'title': 'فيلا ستاند ألون للبيع في سوان ليك التجمع (Swan Lake)',
      'neighborhood': 'التجمع الأول، محور السادات (First Settlement)',
      'compoundName': 'Swan Lake Residences',
      'price': 36000000.0,
      'priceType': 'buy',
      'images': [
        'https://images.unsplash.com/photo-1613490493576-7fde63acd811?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
      ],
      'vibeMatchPercentage': 99,
      'noiseLevelDb': 25,
      'coffeeShopProximityMins': 2,
      'petFriendly': true,
      'bedrooms': 6,
      'bathrooms': 7,
      'squareFeet': 6200, // ~575 sqm
      'isVerified': true,
      'description':
          'قصر سكني مصغر في كمبوند سوان ليك ريزيدنس التجمع الأول من حسن علام، موقع استراتيجي قرب الرحاب ومحور السادات، حديقة هائلة وبحيرات كريستالية خاصة، استلام فوري بمقدم 10% وتقسيط 7 سنوات.',
      'commuteTechHubMins': 4,
      'walkScore': 96,
      'greenScore': 99,
      'nightlifeScore': 92,
      'sunOrientation': 'بحري قبلي بانورامي',
      'developerName': 'حسن علام للمقاولات والتطوير (Hassan Allam Properties)',
      'downPaymentPrice': 3600000.0, // 10%
      'monthlyInstallmentPrice': 385714.0,
      'installmentYears': 7,
      'deliveryYear': 2026,
      'isFurnished': false,
      'rentalYieldPct': 11.5,
      'hasVirtualTour360': true,
      'category': 'villa',
      'currencySymbol': 'ج.م',
      'contactPhone': '+201206667376',
      'contactWhatsApp': '+201206667376',
      'finishing': 'semi_finished',
      'delivery': 'ready_to_move',
      'maintenanceRatio': 0.08,
      'offeringType': 'primary',
      'cashDiscountPercent': 26,
      'isCashOnly': false,
      'isInvestmentOpportunity': true,
      'securityDepositMonths': 2,
      'minLeaseYears': 1,
      'rentalTerms': <String>[],
      'amenities': [
        'أرقى مجمع سكني من حسن علام',
        'مساحات خضراء وبحيرات كريستالية طبيعية',
        'مصعد داخلي خاص للفيلا',
        'جراج يسع 4 سيارات',
        'خدمات أمن وحراسة مشددة 24 ساعة',
      ],
      'styleVariants': {
        'التصميم المودرن الفاخر':
            'https://images.unsplash.com/photo-1613490493576-7fde63acd811?auto=format&fit=crop&w=1200&q=80',
      },
    },
  ];
}
