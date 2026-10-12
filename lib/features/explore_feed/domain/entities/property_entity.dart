import 'package:equatable/equatable.dart';

/// Clean Architecture Domain Entity representing a property listing.
class PropertyEntity extends Equatable {
  final String id;
  final String title;
  final String neighborhood;
  final double price;
  final String priceType; // 'buy' or 'rent'
  final List<String> images;
  final int vibeMatchPercentage;
  final int noiseLevelDb;
  final int coffeeShopProximityMins;
  final bool petFriendly;
  final int bedrooms;
  final int bathrooms;
  final int squareFeet;
  final bool isVerified;
  final String description;
  final int commuteTechHubMins;
  final int walkScore;
  final int greenScore;
  final int nightlifeScore;
  final String sunOrientation;
  final List<String> amenities;
  final Map<String, String> styleVariants;

  const PropertyEntity({
    required this.id,
    required this.title,
    required this.neighborhood,
    required this.price,
    this.priceType = 'buy',
    required this.images,
    required this.vibeMatchPercentage,
    required this.noiseLevelDb,
    required this.coffeeShopProximityMins,
    required this.petFriendly,
    required this.bedrooms,
    required this.bathrooms,
    required this.squareFeet,
    required this.isVerified,
    required this.description,
    required this.commuteTechHubMins,
    required this.walkScore,
    required this.greenScore,
    required this.nightlifeScore,
    required this.sunOrientation,
    required this.amenities,
    required this.styleVariants,
  });

  /// Formatted price with commas (e.g. $1,450,000)
  String get formattedPrice {
    final str = price.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write(',');
      }
    }
    final formatted = buffer.toString().split('').reversed.join('');
    return priceType == 'rent' ? '\$$formatted/mo' : '\$$formatted';
  }

  /// Price per square foot calculation
  double get pricePerSqFt => squareFeet > 0 ? price / squareFeet : 0.0;

  @override
  List<Object?> get props => [
        id,
        title,
        neighborhood,
        price,
        priceType,
        images,
        vibeMatchPercentage,
        noiseLevelDb,
        coffeeShopProximityMins,
        petFriendly,
        bedrooms,
        bathrooms,
        squareFeet,
        isVerified,
        description,
        commuteTechHubMins,
        walkScore,
        greenScore,
        nightlifeScore,
        sunOrientation,
        amenities,
        styleVariants,
      ];
}
