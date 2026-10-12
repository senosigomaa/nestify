import '../../domain/entities/property_entity.dart';

/// Data layer model extending PropertyEntity with JSON serialization.
class PropertyModel extends PropertyEntity {
  const PropertyModel({
    required super.id,
    required super.title,
    required super.neighborhood,
    required super.price,
    super.priceType,
    required super.images,
    required super.vibeMatchPercentage,
    required super.noiseLevelDb,
    required super.coffeeShopProximityMins,
    required super.petFriendly,
    required super.bedrooms,
    required super.bathrooms,
    required super.squareFeet,
    required super.isVerified,
    required super.description,
    required super.commuteTechHubMins,
    required super.walkScore,
    required super.greenScore,
    required super.nightlifeScore,
    required super.sunOrientation,
    required super.amenities,
    required super.styleVariants,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Luxury Loft',
      neighborhood: json['neighborhood'] as String? ?? 'Downtown Tech District',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      priceType: json['priceType'] as String? ?? 'buy',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      vibeMatchPercentage: (json['vibeMatchPercentage'] as num?)?.toInt() ?? 90,
      noiseLevelDb: (json['noiseLevelDb'] as num?)?.toInt() ?? 35,
      coffeeShopProximityMins:
          (json['coffeeShopProximityMins'] as num?)?.toInt() ?? 3,
      petFriendly: json['petFriendly'] as bool? ?? true,
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 2,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 2,
      squareFeet: (json['squareFeet'] as num?)?.toInt() ?? 1200,
      isVerified: json['isVerified'] as bool? ?? true,
      description: json['description'] as String? ?? '',
      commuteTechHubMins: (json['commuteTechHubMins'] as num?)?.toInt() ?? 10,
      walkScore: (json['walkScore'] as num?)?.toInt() ?? 95,
      greenScore: (json['greenScore'] as num?)?.toInt() ?? 90,
      nightlifeScore: (json['nightlifeScore'] as num?)?.toInt() ?? 88,
      sunOrientation: json['sunOrientation'] as String? ?? 'South-Facing',
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      styleVariants: (json['styleVariants'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'neighborhood': neighborhood,
      'price': price,
      'priceType': priceType,
      'images': images,
      'vibeMatchPercentage': vibeMatchPercentage,
      'noiseLevelDb': noiseLevelDb,
      'coffeeShopProximityMins': coffeeShopProximityMins,
      'petFriendly': petFriendly,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'squareFeet': squareFeet,
      'isVerified': isVerified,
      'description': description,
      'commuteTechHubMins': commuteTechHubMins,
      'walkScore': walkScore,
      'greenScore': greenScore,
      'nightlifeScore': nightlifeScore,
      'sunOrientation': sunOrientation,
      'amenities': amenities,
      'styleVariants': styleVariants,
    };
  }

  factory PropertyModel.fromEntity(PropertyEntity entity) {
    return PropertyModel(
      id: entity.id,
      title: entity.title,
      neighborhood: entity.neighborhood,
      price: entity.price,
      priceType: entity.priceType,
      images: entity.images,
      vibeMatchPercentage: entity.vibeMatchPercentage,
      noiseLevelDb: entity.noiseLevelDb,
      coffeeShopProximityMins: entity.coffeeShopProximityMins,
      petFriendly: entity.petFriendly,
      bedrooms: entity.bedrooms,
      bathrooms: entity.bathrooms,
      squareFeet: entity.squareFeet,
      isVerified: entity.isVerified,
      description: entity.description,
      commuteTechHubMins: entity.commuteTechHubMins,
      walkScore: entity.walkScore,
      greenScore: entity.greenScore,
      nightlifeScore: entity.nightlifeScore,
      sunOrientation: entity.sunOrientation,
      amenities: entity.amenities,
      styleVariants: entity.styleVariants,
    );
  }

  PropertyModel copyWith({
    String? id,
    String? title,
    String? neighborhood,
    double? price,
    String? priceType,
    List<String>? images,
    int? vibeMatchPercentage,
    int? noiseLevelDb,
    int? coffeeShopProximityMins,
    bool? petFriendly,
    int? bedrooms,
    int? bathrooms,
    int? squareFeet,
    bool? isVerified,
    String? description,
    int? commuteTechHubMins,
    int? walkScore,
    int? greenScore,
    int? nightlifeScore,
    String? sunOrientation,
    List<String>? amenities,
    Map<String, String>? styleVariants,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      neighborhood: neighborhood ?? this.neighborhood,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
      images: images ?? this.images,
      vibeMatchPercentage: vibeMatchPercentage ?? this.vibeMatchPercentage,
      noiseLevelDb: noiseLevelDb ?? this.noiseLevelDb,
      coffeeShopProximityMins:
          coffeeShopProximityMins ?? this.coffeeShopProximityMins,
      petFriendly: petFriendly ?? this.petFriendly,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      squareFeet: squareFeet ?? this.squareFeet,
      isVerified: isVerified ?? this.isVerified,
      description: description ?? this.description,
      commuteTechHubMins: commuteTechHubMins ?? this.commuteTechHubMins,
      walkScore: walkScore ?? this.walkScore,
      greenScore: greenScore ?? this.greenScore,
      nightlifeScore: nightlifeScore ?? this.nightlifeScore,
      sunOrientation: sunOrientation ?? this.sunOrientation,
      amenities: amenities ?? this.amenities,
      styleVariants: styleVariants ?? this.styleVariants,
    );
  }
}
