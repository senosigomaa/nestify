import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nestify/core/network/mock_properties_data.dart';
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
      expect(model.title, 'The Obsidian Zenith Penthouse');
      expect(model.vibeMatchPercentage, 98);
      expect(model.noiseLevelDb, 34);
      expect(model.formattedPrice, '\$1,450,000');
      expect(model.pricePerSqFt, closeTo(1450000 / 1820, 0.01));
      expect(model.styleVariants.containsKey('Minimalist Japandi'), isTrue);
      expect(model.styleVariants.containsKey('Cyberpunk Loft'), isTrue);

      final json = model.toJson();
      expect(json['id'], 'prop_001');
      expect(json['price'], 1450000.0);
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
