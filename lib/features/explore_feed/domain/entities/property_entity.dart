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

  // Egyptian Real Estate Attributes
  final String finishing; // 'core_and_shell', 'semi_finished', 'fully_finished', 'ultra_lux'
  final String delivery; // 'ready_to_move', '2026', '2027', '2028'
  final double maintenanceRatio; // e.g. 0.08 (8%)
  final String offeringType; // 'primary' (من المطور مباشرة) or 'resale' (إعادة بيع)
  final int cashDiscountPercent; // e.g. 25 (%)
  final String compoundName;

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
    this.contactPhone = '+201206667376',
    this.contactWhatsApp = '+201206667376',
    this.category = 'apartment',
    this.currencySymbol = 'EGP',
    this.finishing = 'fully_finished',
    this.delivery = 'ready_to_move',
    this.maintenanceRatio = 0.08,
    this.offeringType = 'primary',
    this.cashDiscountPercent = 25,
    this.compoundName = 'Palm Hills',
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

  /// Quarterly installment amount
  double get quarterlyInstallmentPrice {
    final effectiveMonthly = monthlyInstallmentPrice > 0
        ? monthlyInstallmentPrice
        : (price * 0.90) / (installmentYears * 12);
    return effectiveMonthly * 3;
  }

  /// Formatted localized Quarterly installment
  String localizedQuarterlyInstallment(bool isArabic) {
    return AppLocalizations.formatPrice(
      quarterlyInstallmentPrice,
      currencySymbol: currencySymbol == '\$' ? 'EGP' : currencySymbol,
      isArabic: isArabic,
      isMonthly: false,
    );
  }

  /// Cash price after upfront discount
  double get cashPrice => price * (1.0 - (cashDiscountPercent / 100.0));

  /// Formatted localized Cash Price
  String localizedCashPrice(bool isArabic) {
    return AppLocalizations.formatPrice(
      cashPrice,
      currencySymbol: currencySymbol == '\$' ? 'EGP' : currencySymbol,
      isArabic: isArabic,
      isMonthly: false,
    );
  }

  /// Localized finishing condition
  String localizedFinishing(bool isArabic) {
    switch (finishing) {
      case 'core_and_shell':
        return isArabic ? 'بدون تشطيب (طوب أحمر)' : 'Core & Shell';
      case 'semi_finished':
        return isArabic ? 'نصف تشطيب (محارة)' : 'Semi-Finished';
      case 'ultra_lux':
        return isArabic ? 'ألترا سوبر لوكس' : 'Ultra Super Lux';
      case 'fully_finished':
      default:
        return isArabic ? 'تشطيب كامل سوبر لوكس' : 'Fully Finished';
    }
  }

  /// Localized delivery timeline
  String localizedDelivery(bool isArabic) {
    if (delivery == 'ready_to_move') {
      return isArabic ? 'استلام فوري' : 'Ready to Move';
    }
    return isArabic ? 'استلام $delivery' : 'Delivery $delivery';
  }

  /// Localized offering type
  String localizedOfferingType(bool isArabic) {
    if (offeringType == 'resale') {
      return isArabic ? 'إعادة بيع (Resale)' : 'Resale';
    }
    return isArabic ? 'من المطور مباشرة (Primary)' : 'Primary Developer';
  }

  /// Localized maintenance deposit
  String localizedMaintenance(bool isArabic) {
    final pct = (maintenanceRatio * 100).toInt();
    final amount = price * maintenanceRatio;
    final formattedAmt = AppLocalizations.formatPrice(
      amount,
      currencySymbol: currencySymbol == '\$' ? 'EGP' : currencySymbol,
      isArabic: isArabic,
      isMonthly: false,
    );
    return isArabic ? '$pct% ($formattedAmt)' : '$pct% ($formattedAmt)';
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
        finishing,
        delivery,
        maintenanceRatio,
        offeringType,
        cashDiscountPercent,
        compoundName,
      ];
}
