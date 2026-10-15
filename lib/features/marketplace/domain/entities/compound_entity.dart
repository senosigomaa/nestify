import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nestify/core/localization/app_localizations.dart';

/// Clean Architecture Entity representing an individual unit type breakdown within a Compound.
class CompoundUnitType extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final double startingPrice;
  final int startingAreaSqm;
  final String bedrooms;
  final String finishingAr;
  final String finishingEn;
  final IconData icon;

  const CompoundUnitType({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.startingPrice,
    required this.startingAreaSqm,
    required this.bedrooms,
    required this.finishingAr,
    required this.finishingEn,
    this.icon = Icons.home_work_rounded,
  });

  String localizedName(bool isArabic) => isArabic ? nameAr : nameEn;
  String localizedFinishing(bool isArabic) =>
      isArabic ? finishingAr : finishingEn;

  String formattedPrice(bool isArabic) {
    return AppLocalizations.formatPrice(
      startingPrice,
      currencySymbol: 'ج.م',
      isArabic: isArabic,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        startingPrice,
        startingAreaSqm,
        bedrooms,
        finishingAr,
        finishingEn,
      ];
}

/// Clean Architecture Domain Entity representing an off-plan / new compound real estate project in Egypt.
class CompoundEntity extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final String developerName;
  final String developerLogo;
  final String locationAr;
  final String locationEn;
  final String deliveryStatusAr;
  final String deliveryStatusEn;
  final int deliveryYear;
  final String paymentPlanHighlightAr;
  final String paymentPlanHighlightEn;
  final int cashDiscountPercent;
  final double startingPrice;
  final String coverImage;
  final List<String> galleryImages;
  final String masterPlanImage;
  final String overviewAr;
  final String overviewEn;
  final List<String> amenitiesAr;
  final List<String> amenitiesEn;
  final List<CompoundUnitType> availableUnitTypes;
  final double areaAcres;
  final String contactPhone;
  final String contactWhatsApp;

  const CompoundEntity({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.developerName,
    required this.developerLogo,
    required this.locationAr,
    required this.locationEn,
    required this.deliveryStatusAr,
    required this.deliveryStatusEn,
    required this.deliveryYear,
    required this.paymentPlanHighlightAr,
    required this.paymentPlanHighlightEn,
    required this.cashDiscountPercent,
    required this.startingPrice,
    required this.coverImage,
    required this.galleryImages,
    required this.masterPlanImage,
    required this.overviewAr,
    required this.overviewEn,
    required this.amenitiesAr,
    required this.amenitiesEn,
    required this.availableUnitTypes,
    this.areaAcres = 200,
    this.contactPhone = '+201206667376',
    this.contactWhatsApp = '+201206667376',
  });

  String localizedName(bool isArabic) => isArabic ? nameAr : name;
  String localizedLocation(bool isArabic) =>
      isArabic ? locationAr : locationEn;
  String localizedDelivery(bool isArabic) =>
      isArabic ? deliveryStatusAr : deliveryStatusEn;
  String localizedPaymentPlan(bool isArabic) =>
      isArabic ? paymentPlanHighlightAr : paymentPlanHighlightEn;
  String localizedOverview(bool isArabic) =>
      isArabic ? overviewAr : overviewEn;

  List<String> localizedAmenities(bool isArabic) =>
      isArabic ? amenitiesAr : amenitiesEn;

  String formattedStartingPrice(bool isArabic) {
    return AppLocalizations.formatPrice(
      startingPrice,
      currencySymbol: 'ج.م',
      isArabic: isArabic,
    );
  }

  String unitTypesSummary(bool isArabic) {
    if (availableUnitTypes.isEmpty) return '';
    return availableUnitTypes
        .map((u) => u.localizedName(isArabic))
        .take(3)
        .join(' • ');
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        developerName,
        developerLogo,
        locationAr,
        locationEn,
        deliveryStatusAr,
        deliveryStatusEn,
        deliveryYear,
        paymentPlanHighlightAr,
        paymentPlanHighlightEn,
        cashDiscountPercent,
        startingPrice,
        coverImage,
        galleryImages,
        masterPlanImage,
        overviewAr,
        overviewEn,
        amenitiesAr,
        amenitiesEn,
        availableUnitTypes,
        areaAcres,
        contactPhone,
        contactWhatsApp,
      ];
}
