import 'package:flutter_test/flutter_test.dart';
import 'package:nestify/core/network/mock_properties_data.dart';
import 'package:nestify/features/explore_feed/data/models/property_model.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';

void main() {
  group('Egyptian Category & Listing Suite', () {
    late List<PropertyEntity> properties;

    setUp(() {
      properties = MockPropertiesData.rawProperties
          .map((json) => PropertyModel.fromJson(json))
          .toList();
    });

    test('MockPropertiesData has 10 high-fidelity Cairo/Giza properties', () {
      expect(properties.length, greaterThanOrEqualTo(10));
    });

    test('Properties are categorized correctly into sales and rentals', () {
      final forSale = properties.where((p) => p.priceType == 'buy').toList();
      final forRent = properties.where((p) => p.priceType == 'rent').toList();

      expect(forSale.isNotEmpty, isTrue);
      expect(forRent.isNotEmpty, isTrue);

      final apartmentsSale = properties
          .where((p) => p.category == 'apartment' && p.priceType == 'buy')
          .toList();
      final apartmentsRent = properties
          .where((p) => p.category == 'apartment' && p.priceType == 'rent')
          .toList();
      final villasSale = properties
          .where((p) => (p.category == 'villa' || p.category == 'townhouse') && p.priceType == 'buy')
          .toList();
      final villasRent = properties
          .where((p) => (p.category == 'villa' || p.category == 'townhouse') && p.priceType == 'rent')
          .toList();

      expect(apartmentsSale.isNotEmpty, isTrue);
      expect(apartmentsRent.isNotEmpty, isTrue);
      expect(villasSale.isNotEmpty, isTrue);
      expect(villasRent.isNotEmpty, isTrue);
    });

    test('All properties link to broker WhatsApp/phone (+201206667376)', () {
      for (final p in properties) {
        expect(p.contactPhone, contains('201206667376'));
        expect(p.contactWhatsApp, contains('201206667376'));
      }
    });

    test('Egyptian financial attributes format accurately', () {
      final prop = properties.first;
      expect(prop.price, greaterThan(0));
      expect(prop.localizedPrice(true), contains('ج.م'));
      expect(prop.localizedDownPayment(true), contains('ج.م'));
      expect(prop.localizedFinishing(true).isNotEmpty, isTrue);
      expect(prop.localizedDelivery(true).isNotEmpty, isTrue);
    });

    test('Strict Business Logic Segregation (Rent vs Cash vs Installments vs ROI)', () {
      final rentalProps = properties.where((p) => p.forRent).toList();
      expect(rentalProps.isNotEmpty, isTrue);
      for (final r in rentalProps) {
        expect(r.hasInstallments, isFalse);
        expect(r.securityDepositMonths, greaterThanOrEqualTo(1));
        expect(r.securityDepositAmount, greaterThan(0));
        expect(r.minLeaseYears, greaterThanOrEqualTo(1));
        expect(r.rentalTerms.isNotEmpty, isTrue);
      }

      final cashOnlyProps = properties.where((p) => p.isCashOnly).toList();
      expect(cashOnlyProps.isNotEmpty, isTrue);
      for (final c in cashOnlyProps) {
        expect(c.forRent, isFalse);
        expect(c.hasInstallments, isFalse);
        expect(c.transferFeeAmount, equals(c.price * 0.025));
      }

      final installmentProps = properties.where((p) => p.hasInstallments).toList();
      expect(installmentProps.isNotEmpty, isTrue);
      for (final inst in installmentProps) {
        expect(inst.forRent, isFalse);
        expect(inst.isCashOnly, isFalse);
        expect(inst.installmentYears, greaterThan(0));
      }

      final investmentOpportunities = properties.where((p) => p.isInvestmentOpportunity).toList();
      expect(investmentOpportunities.isNotEmpty, isTrue);
    });
  });
}
