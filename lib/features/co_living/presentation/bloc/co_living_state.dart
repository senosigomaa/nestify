import 'dart:math';
import 'package:equatable/equatable.dart';
import 'co_living_event.dart';

class CoLivingState extends Equatable {
  final double propertyPrice;
  final int coBuyersCount;
  final double downPaymentPercentage;
  final int loanTenureYears;
  final double annualInterestRate;
  final double monthlyUtilities;
  final SplitMode splitMode;

  const CoLivingState({
    this.propertyPrice = 1450000.0,
    this.coBuyersCount = 3,
    this.downPaymentPercentage = 0.20,
    this.loanTenureYears = 30,
    this.annualInterestRate = 0.058, // 5.8%
    this.monthlyUtilities = 450.0,
    this.splitMode = SplitMode.coBuy,
  });

  /// Total upfront down payment required
  double get totalDownPayment => propertyPrice * downPaymentPercentage;

  /// Down payment split per co-buyer/investor
  double get downPaymentPerPerson =>
      coBuyersCount > 0 ? totalDownPayment / coBuyersCount : 0.0;

  /// Financed principal loan amount
  double get loanPrincipal => propertyPrice - totalDownPayment;

  /// Monthly mortgage installment (Principal + Interest)
  double get totalMonthlyMortgage {
    if (loanPrincipal <= 0) return 0.0;
    final r = annualInterestRate / 12.0;
    final n = loanTenureYears * 12;
    if (r == 0) return loanPrincipal / n;
    final powFactor = pow(1 + r, n);
    return loanPrincipal * (r * powFactor) / (powFactor - 1);
  }

  /// Monthly housing installment per person (mortgage or rent share)
  double get monthlyInstallmentPerPerson {
    if (splitMode == SplitMode.coBuy) {
      return coBuyersCount > 0 ? totalMonthlyMortgage / coBuyersCount : 0.0;
    } else {
      // Co-Rent mode: propertyPrice represents monthly rental
      return coBuyersCount > 0 ? propertyPrice / coBuyersCount : 0.0;
    }
  }

  /// Maintenance, smart home utilities, and HOA per person
  double get utilitiesPerPerson =>
      coBuyersCount > 0 ? monthlyUtilities / coBuyersCount : 0.0;

  /// Complete all-inclusive monthly commitment per co-buyer
  double get totalMonthlyOutflowPerPerson =>
      monthlyInstallmentPerPerson + utilitiesPerPerson;

  /// Legal equity ownership share percentage
  double get equitySharePercentage =>
      coBuyersCount > 0 ? 100.0 / coBuyersCount : 0.0;

  CoLivingState copyWith({
    double? propertyPrice,
    int? coBuyersCount,
    double? downPaymentPercentage,
    int? loanTenureYears,
    double? annualInterestRate,
    double? monthlyUtilities,
    SplitMode? splitMode,
  }) {
    return CoLivingState(
      propertyPrice: propertyPrice ?? this.propertyPrice,
      coBuyersCount: coBuyersCount ?? this.coBuyersCount,
      downPaymentPercentage:
          downPaymentPercentage ?? this.downPaymentPercentage,
      loanTenureYears: loanTenureYears ?? this.loanTenureYears,
      annualInterestRate: annualInterestRate ?? this.annualInterestRate,
      monthlyUtilities: monthlyUtilities ?? this.monthlyUtilities,
      splitMode: splitMode ?? this.splitMode,
    );
  }

  @override
  List<Object?> get props => [
        propertyPrice,
        coBuyersCount,
        downPaymentPercentage,
        loanTenureYears,
        annualInterestRate,
        monthlyUtilities,
        splitMode,
      ];
}
