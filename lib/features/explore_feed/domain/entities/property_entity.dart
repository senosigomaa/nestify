import 'package:equatable/equatable.dart';
import 'package:nestify/core/localization/app_localizations.dart';

/// Clean Architecture Domain Entity representing a property listing with
/// commercial real estate attributes (developer, installments, 360 VR, rental yield).
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

  // Commercial Marketplace Extensions
  final String developerName;
  final double downPaymentPrice;
  final double monthlyInstallmentPrice;
  final int installmentYears;
  final int deliveryYear;
  final bool isFurnished;
  final double rentalYieldPct;
  final bool hasVirtualTour360;
  final String contactPhone;
  final String contactWhatsApp;
  final String category; // 'villa', 'apartment', 'townhouse', 'studio', 'commercial'
  final String currencySymbol;

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
    this.developerName = 'Emaar Misr / Palm Hills',
    this.downPaymentPrice = 0.0,
    this.monthlyInstallmentPrice = 0.0,
    this.installmentYears = 8,
    this.deliveryYear = 2026,
    this.isFurnished = false,
    this.rentalYieldPct = 11.8,
    this.hasVirtualTour360 = true,
    this.contactPhone = '+201009876543',
    this.contactWhatsApp = '+201009876543',
    this.category = 'apartment',
    this.currencySymbol = 'EGP',
  });

  /// Formatted price with commas (e.g. 14,500,000 EGP)
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
    final sym = currencySymbol == '\$' ? 'EGP' : currencySymbol;
    return priceType == 'rent' ? '$formatted $sym/mo' : '$formatted $sym';
  }

  /// Formatted localized price supporting Arabic Eastern numerals
  String localizedPrice(bool isArabic) {
    return AppLocalizations.formatPrice(
      price,
      currencySymbol: currencySymbol == '\$' ? 'EGP' : currencySymbol,
      isArabic: isArabic,
      isMonthly: priceType == 'rent',
    );
  }

  /// Formatted Down payment
  String get formattedDownPayment {
    final effectiveDown = downPaymentPrice > 0 ? downPaymentPrice : price * 0.10;
    final sym = currencySymbol == '\$' ? 'EGP' : currencySymbol;
    return '${_formatNum(effectiveDown)} $sym';
  }

  /// Formatted localized Down payment
  String localizedDownPayment(bool isArabic) {
    final effectiveDown = downPaymentPrice > 0 ? downPaymentPrice : price * 0.10;
    return AppLocalizations.formatPrice(
      effectiveDown,
      currencySymbol: currencySymbol == '\$' ? 'EGP' : currencySymbol,
      isArabic: isArabic,
      isMonthly: false,
    );
  }

  /// Formatted Monthly installment
  String get formattedMonthlyInstallment {
    final effectiveMonthly = monthlyInstallmentPrice > 0
        ? monthlyInstallmentPrice
        : (price * 0.90) / (installmentYears * 12);
    final sym = currencySymbol == '\$' ? 'EGP' : currencySymbol;
    return '${_formatNum(effectiveMonthly)} $sym/mo';
  }

  /// Formatted localized Monthly installment
  String localizedMonthlyInstallment(bool isArabic) {
    final effectiveMonthly = monthlyInstallmentPrice > 0
        ? monthlyInstallmentPrice
        : (price * 0.90) / (installmentYears * 12);
    return AppLocalizations.formatPrice(
      effectiveMonthly,
      currencySymbol: currencySymbol == '\$' ? 'EGP' : currencySymbol,
      isArabic: isArabic,
      isMonthly: true,
    );
  }

  String _formatNum(double numVal) {
    final str = numVal.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write(',');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  /// Area in Square Meters (Sqm)
  int get areaSqm => (squareFeet * 0.092903).round();

  /// Price per square foot calculation
  double get pricePerSqFt => squareFeet > 0 ? price / squareFeet : 0.0;

  /// Price per square meter calculation
  double get pricePerSqm => areaSqm > 0 ? price / areaSqm : 0.0;

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
        developerName,
        downPaymentPrice,
        monthlyInstallmentPrice,
        installmentYears,
        deliveryYear,
        isFurnished,
        rentalYieldPct,
        hasVirtualTour360,
        contactPhone,
        contactWhatsApp,
        category,
        currencySymbol,
      ];
}
