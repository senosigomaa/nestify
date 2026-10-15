import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/core/network/mock_properties_data.dart';
import 'package:nestify/features/explore_feed/data/models/property_model.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';
import 'package:nestify/features/marketplace/presentation/views/add_property_listing_screen.dart';

void main() {
  group('Add Property Listing Domain & Model Alignment Tests', () {
    test('Constructing PropertyModel aligns exactly with PropertyEntity domain fields', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final propertyId = 'user_prop_$now';

      const price = 8500000.0;
      const downPayment = 850000.0;
      const installmentYears = 8;
      const areaSqm = 185.0;
      final squareFeet = (areaSqm * 10.7639).round();

      final monthlyInstallment = PropertyEntity.calculateInstallment(
        price: price,
        years: installmentYears,
        downPaymentRatio: downPayment / price,
      ).toDouble();

      final property = PropertyModel(
        id: propertyId,
        title: 'شقة فاخرة للبيع في التجمع الخامس (ماونتن فيو)',
        neighborhood: 'التجمع الخامس (New Cairo) - شارع التسعين الجنوبي',
        price: price,
        priceType: 'buy',
        images: const [
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
        ],
        vibeMatchPercentage: 96,
        noiseLevelDb: 34,
        coffeeShopProximityMins: 3,
        petFriendly: true,
        bedrooms: 3,
        bathrooms: 2,
        squareFeet: squareFeet,
        isVerified: true,
        description: 'شقة بإطلالة مفتوحة على السنترال بارك، تشطيب ألترا سوبر لوكس.',
        commuteTechHubMins: 10,
        walkScore: 92,
        greenScore: 88,
        nightlifeScore: 85,
        sunOrientation: 'بحري (North-Facing)',
        amenities: const [
          'مصعد (Elevator)',
          'جولة افتراضية 360°',
          'أمن وحراسة 24/7',
        ],
        styleVariants: const {
          'AR_Title': 'شقة فاخرة للبيع في التجمع الخامس (ماونتن فيو)',
          'EN_Title': 'Luxury Apartment for Sale in New Cairo (Mountain View)',
          'floor': 'الدور الثالث (Third Floor)',
          'publisher': 'ساري المنصور',
        },
        developerName: 'Mountain View iCity',
        downPaymentPrice: downPayment,
        monthlyInstallmentPrice: monthlyInstallment,
        installmentYears: installmentYears,
        deliveryYear: 2026,
        isFurnished: false,
        rentalYieldPct: 9.8,
        hasVirtualTour360: true,
        contactPhone: '+201206667376',
        contactWhatsApp: '+201206667376',
        category: 'apartment',
        currencySymbol: 'EGP',
        finishing: 'fully_finished',
        delivery: 'ready_to_move',
        maintenanceRatio: 0.08,
        offeringType: 'resale',
        cashDiscountPercent: 20,
        compoundName: 'Mountain View iCity',
        isCashOnly: false,
        isInvestmentOpportunity: true,
        securityDepositMonths: 0,
        minLeaseYears: 0,
        rentalTerms: const [],
      );

      expect(property.id, startsWith('user_prop_'));
      expect(property.category, equals('apartment'));
      expect(property.hasInstallments, isTrue);
      expect(property.forRent, isFalse);
      expect(property.hasVirtualTour360, isTrue);
      expect(property.contactPhone, equals('+201206667376'));
      expect(property.contactWhatsApp, equals('+201206667376'));
      expect(property.monthlyInstallmentPrice, greaterThan(0));
      expect(property.maintenanceRatio, equals(0.08));
    });

    test('MockPropertiesData.addProperty adds to top of rawProperties and notifies listeners', () {
      int notifyCount = 0;
      void listener() => notifyCount++;
      MockPropertiesData.propertyChangeNotifier.addListener(listener);

      final now = DateTime.now().millisecondsSinceEpoch;
      final newId = 'user_prop_test_$now';
      final propertyJson = {
        'id': newId,
        'title': 'فيلا مستقلة للبيع في الشيخ زايد (SODIC)',
        'neighborhood': 'الشيخ زايد (Sheikh Zayed)',
        'compoundName': 'SODIC VYE Sheikh Zayed',
        'price': 18500000.0,
        'priceType': 'buy',
        'category': 'villa',
        'bedrooms': 5,
        'bathrooms': 5,
        'squareFeet': 4500,
        'isVerified': true,
        'description': 'فيلا فاخرة بحمام سباحة خاص',
        'images': [
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
        ],
        'vibeMatchPercentage': 98,
        'noiseLevelDb': 28,
        'coffeeShopProximityMins': 3,
        'petFriendly': true,
        'commuteTechHubMins': 15,
        'walkScore': 90,
        'greenScore': 95,
        'nightlifeScore': 80,
        'sunOrientation': 'بحري',
        'amenities': ['حمام سباحة خاص', 'حديقة واسعة'],
        'styleVariants': {},
        'developerName': 'SODIC VYE Sheikh Zayed',
        'downPaymentPrice': 1850000.0,
        'monthlyInstallmentPrice': 173437.0,
        'installmentYears': 8,
        'deliveryYear': 2026,
        'isFurnished': false,
        'rentalYieldPct': 10.5,
        'hasVirtualTour360': true,
        'contactPhone': '+201206667376',
        'contactWhatsApp': '+201206667376',
        'currencySymbol': 'EGP',
        'finishing': 'fully_finished',
        'delivery': 'ready_to_move',
        'maintenanceRatio': 0.08,
        'offeringType': 'resale',
        'cashDiscountPercent': 25,
        'isCashOnly': false,
        'isInvestmentOpportunity': true,
        'securityDepositMonths': 0,
        'minLeaseYears': 0,
        'rentalTerms': const [],
      };

      MockPropertiesData.addProperty(propertyJson);

      expect(notifyCount, greaterThan(0));
      expect(MockPropertiesData.rawProperties.first['id'], equals(newId));

      final myListings = MockPropertiesData.getMyPublishedListings();
      expect(myListings.any((p) => p['id'] == newId), isTrue);

      MockPropertiesData.propertyChangeNotifier.removeListener(listener);
    });

    test('Rent property configuration preserves security deposit and lease period', () {
      final rentProp = PropertyModel(
        id: 'user_prop_rent_01',
        title: 'شقة فاخرة للإيجار في مدينتي',
        neighborhood: 'مدينتي (Madinaty)',
        price: 35000.0,
        priceType: 'rent',
        images: const ['https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80'],
        vibeMatchPercentage: 92,
        noiseLevelDb: 30,
        coffeeShopProximityMins: 2,
        petFriendly: true,
        bedrooms: 3,
        bathrooms: 2,
        squareFeet: 1750,
        isVerified: true,
        description: 'مفروشة بالكامل ألترا لوكس، فيو وايد جاردن.',
        commuteTechHubMins: 20,
        walkScore: 88,
        greenScore: 94,
        nightlifeScore: 75,
        sunOrientation: 'بحري',
        amenities: const ['مفروش بالكامل', 'أمن 24/7'],
        styleVariants: const {},
        developerName: 'Madinaty Talaat Moustafa',
        downPaymentPrice: 0.0,
        monthlyInstallmentPrice: 0.0,
        installmentYears: 0,
        deliveryYear: 2026,
        isFurnished: true,
        rentalYieldPct: 12.5,
        hasVirtualTour360: true,
        contactPhone: '+201206667376',
        contactWhatsApp: '+201206667376',
        category: 'apartment',
        currencySymbol: 'EGP',
        finishing: 'furnished',
        delivery: 'ready_to_move',
        maintenanceRatio: 0.08,
        offeringType: 'resale',
        cashDiscountPercent: 0,
        compoundName: 'Madinaty Talaat Moustafa',
        isCashOnly: false,
        isInvestmentOpportunity: false,
        securityDepositMonths: 2,
        minLeaseYears: 1,
        rentalTerms: const ['عائلات فقط', 'شامل الصيانة', 'مفروش ومكيف'],
      );

      expect(rentProp.forRent, isTrue);
      expect(rentProp.hasInstallments, isFalse);
      expect(rentProp.securityDepositMonths, equals(2));
      expect(rentProp.securityDepositAmount, equals(70000.0));
      expect(rentProp.minLeaseYears, equals(1));
      expect(rentProp.rentalTerms, contains('عائلات فقط'));
      expect(rentProp.isFurnished, isTrue);
    });
  });

  group('AddPropertyListingScreen Widget UI Tests', () {
    Widget createWidgetUnderTest() {
      return const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: [Locale('ar'), Locale('en')],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: AddPropertyListingScreen(),
        ),
      );
    }

    testWidgets('renders all 3 transaction types and property categories', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Transaction types
      expect(find.text('للبيع كاش'), findsOneWidget);
      expect(find.text('للبيع بالتقسيط'), findsOneWidget);
      expect(find.text('للإيجار الشهري'), findsOneWidget);

      // Property Categories
      expect(find.text('شقة'), findsOneWidget);
      expect(find.text('فيلا مستقلة'), findsOneWidget);
      expect(find.text('تاون هاوس'), findsOneWidget);
      expect(find.text('دوبلكس'), findsOneWidget);
      expect(find.text('بنتهاوس'), findsOneWidget);

      // Verify Compound & Location
      expect(find.text('المشروع والكمبوند'), findsOneWidget);
      expect(find.text('Mountain View iCity'), findsOneWidget);
      expect(find.text('التجمع الخامس (New Cairo)'), findsOneWidget);

      // Verify Specifications & Finishing
      expect(find.text('تشطيب كامل'), findsOneWidget);
      expect(find.text('نصف تشطيب'), findsOneWidget);
      expect(find.text('بدون تشطيب'), findsOneWidget);
      expect(find.text('مفروش'), findsOneWidget);

      // Verify VR / 360 tour card
      expect(find.text('جولة واقع افتراضي 360°'), findsOneWidget);

      // Verify Bilingual fields
      expect(find.text('عنوان الإعلان بالعربية *'), findsOneWidget);
      expect(find.text('Title in English (باللغة الإنجليزية)'), findsOneWidget);

      // Bottom bar
      expect(find.text('المتابعة لاختيار باقة النشر ->'), findsOneWidget);
    });

    testWidgets('switching transaction type updates conditional financials', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Default is installment sale: shows installment simulator
      expect(find.text('البيانات المالية للبيع بالتقسيط'), findsOneWidget);
      expect(find.text('السعر الإجمالي للعقار (ج.م)'), findsOneWidget);
      expect(find.text('المقدم المطلوب (ج.م)'), findsOneWidget);
      expect(find.text('سنوات السداد'), findsOneWidget);

      // Switch to Rent
      await tester.tap(find.text('للإيجار الشهري'));
      await tester.pumpAndSettle();

      expect(find.text('البيانات المالية للإيجار'), findsOneWidget);
      expect(find.text('قيمة الإيجار الشهري (ج.م)'), findsOneWidget);
      expect(find.text('مبلغ التأمين (شهور)'), findsOneWidget);
      expect(find.text('الحد الأدنى للعقد'), findsOneWidget);

      // Switch to Cash Sale
      await tester.tap(find.text('للبيع كاش'));
      await tester.pumpAndSettle();

      expect(find.text('البيانات المالية للبيع كاش'), findsOneWidget);
      expect(find.text('إجمالي السعر قبل الخصم (ج.م)'), findsOneWidget);
      expect(find.text('نسبة الخصم الفوري للكاش'), findsOneWidget);
      expect(find.text('صافي سعر الكاش النهائي:'), findsOneWidget);
    });
  });
}
