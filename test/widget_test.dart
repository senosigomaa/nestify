import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/core/localization/locale_bloc/locale_bloc.dart';
import 'package:nestify/core/localization/locale_bloc/locale_event.dart';
import 'package:nestify/core/network/mock_properties_data.dart';
import 'package:nestify/core/theme/theme_bloc/theme_bloc.dart';
import 'package:nestify/core/theme/theme_bloc/theme_event.dart';
import 'package:nestify/features/co_living/presentation/bloc/co_living_bloc.dart';
import 'package:nestify/features/co_living/presentation/bloc/co_living_event.dart';
import 'package:nestify/features/co_living/presentation/bloc/co_living_state.dart';
import 'package:nestify/features/explore_feed/data/models/property_model.dart';
import 'package:nestify/features/explore_feed/presentation/widgets/match_score_badge.dart';

void main() {
  group('Nestify Clean Architecture Unit & Widget Tests', () {
    test('PropertyModel deserializes mock data and formats price accurately', () {
      final raw = MockPropertiesData.rawProperties.first;
      final model = PropertyModel.fromJson(raw);

      expect(model.id, 'prop_001');
      expect(model.title, 'Palm Hills Sky Penthouse (بنتهاوس بالم هيلز)');
      expect(model.vibeMatchPercentage, 98);
      expect(model.noiseLevelDb, 34);
      expect(model.formattedPrice, '1,450,000 EGP');
      expect(model.pricePerSqFt, closeTo(1450000 / 2450, 0.01));
      expect(model.developerName, 'Palm Hills Developments');
      expect(model.rentalYieldPct, 12.8);
      expect(model.hasVirtualTour360, isTrue);
      expect(model.styleVariants.containsKey('Minimalist Japandi'), isTrue);
      expect(model.styleVariants.containsKey('Cyberpunk Loft'), isTrue);

      final json = model.toJson();
      expect(json['id'], 'prop_001');
      expect(json['price'], 1450000.0);
      expect(json['developerName'], 'Palm Hills Developments');
    });

    test('CoLivingBloc calculates down payments and monthly splits correctly', () async {
      final bloc = CoLivingBloc();

      // Default state has $1,450,000 with 3 co-buyers, 20% down payment
      expect(bloc.state.totalDownPayment, 1450000.0 * 0.20);
      expect(bloc.state.downPaymentPerPerson, (1450000.0 * 0.20) / 3);
      expect(bloc.state.equitySharePercentage, closeTo(33.33, 0.01));

      // Update to 4 co-buyers
      bloc.add(const UpdateCoBuyersCountEvent(4));
      await expectLater(
        bloc.stream,
        emits(predicate<CoLivingState>((s) => s.coBuyersCount == 4)),
      );
      expect(bloc.state.coBuyersCount, 4);
      expect(bloc.state.equitySharePercentage, 25.0);
      expect(bloc.state.downPaymentPerPerson, (1450000.0 * 0.20) / 4);

      // Switch to co-rent mode
      bloc.add(const ToggleSplitModeEvent(SplitMode.coRent));
      await expectLater(
        bloc.stream,
        emits(predicate<CoLivingState>((s) => s.splitMode == SplitMode.coRent)),
      );
      expect(bloc.state.splitMode, SplitMode.coRent);

      await bloc.close();
    });

    test('LocaleBloc toggles between English and Arabic seamlessly', () async {
      final bloc = LocaleBloc();
      expect(bloc.state.isArabic, isFalse);
      expect(bloc.state.locale.languageCode, 'en');

      bloc.add(const ToggleLocaleEvent());
      await expectLater(
        bloc.stream,
        emits(predicate((s) => bloc.state.locale.languageCode == 'ar')),
      );
      expect(bloc.state.isArabic, isTrue);

      bloc.add(const ToggleLocaleEvent());
      await expectLater(
        bloc.stream,
        emits(predicate((s) => bloc.state.locale.languageCode == 'en')),
      );
      expect(bloc.state.isArabic, isFalse);

      await bloc.close();
    });

    test('ThemeBloc toggles between Dark luxury and Nordic Minimalist light mode', () async {
      final themeBloc = ThemeBloc();
      expect(themeBloc.state.isDark, isTrue);
      expect(themeBloc.state.themeMode, ThemeMode.dark);

      themeBloc.add(const ToggleThemeEvent());
      await expectLater(
        themeBloc.stream,
        emits(predicate((s) => !themeBloc.state.isDark && themeBloc.state.themeMode == ThemeMode.light)),
      );
      expect(themeBloc.state.isDark, isFalse);

      themeBloc.add(const ToggleThemeEvent());
      await expectLater(
        themeBloc.stream,
        emits(predicate((s) => themeBloc.state.isDark && themeBloc.state.themeMode == ThemeMode.dark)),
      );
      expect(themeBloc.state.isDark, isTrue);

      await themeBloc.close();
    });

    test('AppLocalizations provides accurate Arabic RTL translations', () {
      final arL10n = AppLocalizations(const Locale('ar'));
      expect(arL10n.isArabic, isTrue);
      expect(arL10n.translate('app_name'), 'نيستيفاي');
      expect(arL10n.translate('nav_explore'), 'اكتشف');
      expect(arL10n.translate('roi_title'), 'تحليل العائد الاستثماري والنمو');
      expect(arL10n.translate('nav_marketplace'), 'السوق العقاري');
      expect(arL10n.translate('vibe_radar_title'), 'رادار الطابع المعيشي للحي');
      expect(arL10n.translate('ambient_acoustic'), 'قياس العزل الصوتي المحيط');
      expect(arL10n.translate('quiet_library'), 'هدوء يشبه المكتبات (زجاج عازل للصوت)');
      expect(arL10n.translate('down_payment_person'), 'الدفعة الأولى لكل شريك');
      expect(arL10n.translate('mortgage_share'), 'قسط التمويل الشهري للشخص');

      // Test Arabic Currency Formatting with Eastern Arabic Numerals & EGP (ج.م)
      final formattedArabicMonthly =
          AppLocalizations.formatPrice(4200, isArabic: true, isMonthly: true);
      expect(formattedArabicMonthly, '٤،٢٠٠ ج.م / شهرياً');

      final formattedArabicTotal =
          AppLocalizations.formatPrice(1450000, isArabic: true, isMonthly: false);
      expect(formattedArabicTotal, '١،٤٥٠،٠٠٠ ج.م');

      final enL10n = AppLocalizations(const Locale('en'));
      expect(enL10n.isArabic, isFalse);
      expect(enL10n.translate('app_name'), 'NESTIFY');
      expect(enL10n.translate('nav_explore'), 'Discover');
      expect(enL10n.translate('nav_marketplace'), 'Marketplace');
      expect(enL10n.translate('vibe_radar_title'), 'NEIGHBORHOOD VIBE RADAR');
      expect(
        AppLocalizations.formatPrice(4200, isArabic: false, isMonthly: true),
        '4,200 EGP/mo',
      );
      expect(
        AppLocalizations.formatPrice(1450000, isArabic: false, isMonthly: false),
        '1,450,000 EGP',
      );
    });

    testWidgets('MatchScoreBadge renders score and label correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchScoreBadge(score: 98, animate: false),
          ),
        ),
      );

      // Verify widget renders text and icon
      expect(find.text('98% VIBE'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });
  });
}
