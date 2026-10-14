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
  });
}
