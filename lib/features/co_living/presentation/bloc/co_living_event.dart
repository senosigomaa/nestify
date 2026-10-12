import 'package:equatable/equatable.dart';

enum SplitMode { coBuy, coRent }

abstract class CoLivingEvent extends Equatable {
  const CoLivingEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCalculatorEvent extends CoLivingEvent {
  final double propertyPrice;
  final SplitMode mode;

  const InitializeCalculatorEvent({
    required this.propertyPrice,
    this.mode = SplitMode.coBuy,
  });

  @override
  List<Object?> get props => [propertyPrice, mode];
}

class UpdateCoBuyersCountEvent extends CoLivingEvent {
  final int count;

  const UpdateCoBuyersCountEvent(this.count);

  @override
  List<Object?> get props => [count];
}

class UpdateDownPaymentPercentageEvent extends CoLivingEvent {
  final double percentage;

  const UpdateDownPaymentPercentageEvent(this.percentage);

  @override
  List<Object?> get props => [percentage];
}

class UpdateLoanTenureYearsEvent extends CoLivingEvent {
  final int years;

  const UpdateLoanTenureYearsEvent(this.years);

  @override
  List<Object?> get props => [years];
}

class UpdateInterestRateEvent extends CoLivingEvent {
  final double rate;

  const UpdateInterestRateEvent(this.rate);

  @override
  List<Object?> get props => [rate];
}

class ToggleSplitModeEvent extends CoLivingEvent {
  final SplitMode mode;

  const ToggleSplitModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}
