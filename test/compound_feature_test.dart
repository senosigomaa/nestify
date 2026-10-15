import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/core/theme/app_theme.dart';
import 'package:nestify/features/chat/data/chat_mock_service.dart';
import 'package:nestify/features/marketplace/data/mock_compounds_data.dart';
import 'package:nestify/features/marketplace/presentation/views/all_compounds_screen.dart';
import 'package:nestify/features/marketplace/presentation/views/compound_details_screen.dart';

void main() {
  group('Off-Plan & New Compounds Data & Domain Tests', () {
    test('MockCompoundsData supplies high-fidelity Egyptian real estate projects', () {
      final compounds = MockCompoundsData.compounds;
      expect(compounds.length, greaterThanOrEqualTo(5));

      final crown = compounds.firstWhere((c) => c.id == 'compound_palm_hills_crown');
      expect(crown.name, equals('Palm Hills The Crown'));
      expect(crown.nameAr, contains('بالم هيلز ذا كراون'));
      expect(crown.developerName, contains('Palm Hills'));
      expect(crown.deliveryYear, equals(2026));
      expect(crown.cashDiscountPercent, equals(30));
      expect(crown.startingPrice, equals(14200000.0));
      expect(crown.contactPhone, equals('+201206667376'));

      final sodic = compounds.firstWhere((c) => c.id == 'compound_sodic_vye');
      expect(sodic.name, equals('SODIC VYE New Zayed'));
      expect(sodic.deliveryYear, equals(2026));

      final mv = compounds.firstWhere((c) => c.id == 'compound_mv_icity_lagoon');
      expect(mv.name, contains('Mountain View'));
      expect(mv.deliveryYear, equals(2027));
    });

    test('CompoundUnitType exposes precise Egyptian property breakdowns', () {
      final compound = MockCompoundsData.compounds.first;
      expect(compound.availableUnitTypes.isNotEmpty, isTrue);

      final unit = compound.availableUnitTypes.first;
      expect(unit.startingPrice, greaterThan(0));
      expect(unit.startingAreaSqm, greaterThan(50));
      expect(unit.finishingAr, isNotEmpty);
      expect(unit.formattedPrice(true), contains('ج.م'));
    });

    test('CompoundEntity unitTypesSummary and formatting helper works in AR and EN', () {
      final compound = MockCompoundsData.compounds.first;
      final summaryAr = compound.unitTypesSummary(true);
      final summaryEn = compound.unitTypesSummary(false);

      expect(summaryAr, isNotEmpty);
      expect(summaryEn, isNotEmpty);
      expect(compound.formattedStartingPrice(true), contains('ج.م'));
    });

    test('ChatMockService.startCompoundInquiry registers EOI inquiry and generates chat conversation', () {
      final compound = MockCompoundsData.compounds.first;
      final conv = ChatMockService.instance.startCompoundInquiry(
        compound: compound,
        clientName: 'أحمد الشناوي',
        clientPhone: '+201206667376',
        selectedUnitType: 'فلل مستقلة فاخرة',
        notes: 'مطلوب استلام 2026 وأقساط 8 سنوات',
      );

      expect(conv.id, startsWith('conv_compound_'));
      expect(conv.developerOrAgency, contains('Palm Hills'));
      expect(conv.messages.length, greaterThanOrEqualTo(2));
      expect(conv.messages.first.text, contains('+201206667376'));
      expect(conv.messages[1].text, contains('أحمد الشناوي'));
      expect(conv.agentName, contains('مستشار مبيعات'));
    });
  });

  group('Off-Plan & New Compounds Widget Tests', () {
    testWidgets('CompoundDetailsScreen renders compound overview, delivery badge, and EOI CTA in Nordic Light Mode', (tester) async {
      final compound = MockCompoundsData.compounds.first;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.getNordicLightTheme(isArabic: true),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: CompoundDetailsScreen(compound: compound),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Compound Name rendered
      expect(find.text(compound.nameAr), findsWidgets);

      // Verify EOI Action CTA Button rendered
      expect(find.text('سجل اهتمامك / طلب حجز (EOI)'), findsWidgets);

      // Verify Available Unit Types heading
      expect(find.text('نماذج الوحدات والأسعار المتاحة'), findsOneWidget);

      // Verify Master Plan heading
      expect(find.text('المخطط العام للكمبوند (Master Plan)'), findsOneWidget);
    });

    testWidgets('AllCompoundsScreen renders all compounds and filter chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.getNordicLightTheme(isArabic: true),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: const AllCompoundsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('كمبوندات جديدة ومشروعات تحت الإنشاء'), findsOneWidget);
      expect(find.text('جميع المناطق'), findsOneWidget);
      expect(find.text('الشيخ زايد'), findsOneWidget);
      expect(find.text('التجمع الخامس'), findsOneWidget);
    });
  });
}
